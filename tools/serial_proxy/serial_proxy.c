/*

serial_proxy - a utility which proxys a serial port to a a telnet or raw tcpip port.

It was written to support PropForth6, and provide the advanced flow control required.

There is no support for xon/xoff flow control, RTS/CTS, or any configuration other than
8 bits, 1 stop bit.

It has been tested on a variety of systems, and cross-compiled and tested on OpenWrt.

Debugging options allow the monitoring of the serial and or tcpip ports.

Normal use:

	serial_proxy --serial_device=/dev/ttyS8 --baud=115200 --port=4000 --expand_cr
*/
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>
#include <pthread.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/time.h>
#include <arpa/inet.h>
#include <termios.h>
//	#include <termio.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <signal.h>
#include <unistd.h>

// IOS FIX
#include <sys/ioctl.h>

static char* usage_str=" [OPTION]...\n\tProxies a serial port to tcp-ip. If this program is invoked with no parameters\n\
\t./serial_proxy.conf is used for parameters. or if not found\n\
\t/etc/serial_proxy.conf is used for parameters.\n\n\
\t-h, --help\t\t\tHelp.\n\
\t-L, --logfile=\t\t\tlogfile\n\
\t-q, --quiet\t\t\tTurns on quiet mode. All information & debug to console is supppressed. (off)\n\
\t-S, --debug_serial\t\tTurns on serial port debugging. (off)\n\
\t-l, --loopback\t\t\tTurns on loopback, serial port is not used. (off)\n\
\t-s, --serial_device=\t\tSerial port to use. (/dev/ttyUSB0)\n\
\t-b, --baud=\t\t\tBaud rate 230400 | 115200 | 57600 | 19200 | 9600 | 1200 | nonstandard. (230400)\n\
\t-d, --line_delay=\t\tDelay upon receipt of CR from telnet in microseconds. (00)\n\
\t-a, --advanced_flow_control\tTurns on advanced flow control. (off)\n\
\t-A, --debug_afc\t\t\tTurns on advanced flow control debugging. (off)\n\
\t-T, --debug_telnet\t\tTurns on telnet control debugging. (off)\n\
\t-p, --port=\t\t\tTcp-ip port. (4000)\n\
\t-r, --raw\t\t\tTreat tcp-ip port as a raw port, otherwise as a telnet port. (off)\n\
\t-e, --expand_cr\t\t\tIf a telnet port, expand cr to cf lf. (off)\n\
\t-P, --debug_port\t\tTurns on tcp-ip port debugging. (off)\n\n";


#define AFC_ACK_SIZE 256 // value fixed by protocol definition
#define AFC_BUF_SIZE 511 // value fixed by protocol definition
#define AFC_ACK_QUEUE_SIZE 4 // max needed should be 3

#define SERIAL_BUF_SIZE  512  // shoud be AFC_BUF_SIZE or slightly greater
#define SERIAL_QUEUE_SIZE SERIAL_BUF_SIZE

#define PORT_BUF_SIZE 1024 // should be at least 1024
#define PORT_QUEUE_SIZE 2048 // should be at least 2* PORT_BUF_SIZE

// Globals - reflect command line options
char *program_name="";
int quiet_mode=0;
int debug_serial = 0;
int loopback_mode = 0;
char *serial_device = "/dev/ttyUSB0";
char *logfile = "";
int baud = 230400;
int advanced_flow_control=0;
int debug_afc=0;
int port = 4000;
int raw_mode = 0;
int expand_cr_mode = 0;
int debug_port = 0;
int line_delay = 0;
FILE* logfileFp = NULL;

// this mutex is used to keep debugging output from multiple threads readable
pthread_mutex_t	debug_mutex;

// once multiple threads are started, access this routine only with debug_mutex locked

char __my_print__buf[ 16384];
void __my_print( const char *format, va_list arg_list) {
	if( !quiet_mode || logfileFp != NULL) {
		vsprintf( __my_print__buf, format, arg_list);
	}
	if(!quiet_mode) {
		fputs(__my_print__buf, stdout);
	}
	if( logfileFp != NULL) {
		fputs(__my_print__buf, logfileFp);
		fflush(logfileFp);
	}
}
// once multiple threads are started, access this routine only with _debug_mutex locked
void my_print( const char *format, ...) {
	va_list arg_list;
	va_start(arg_list, format);
	__my_print(format, arg_list);
	va_end( arg_list);
}

// some higher level debug output routines
unsigned long get_microsec( ) {
	struct timeval t;
	if( gettimeofday( &t, NULL)) {
		return 0;
	} else {
		return ( ((unsigned long) 1000000) * (unsigned long) t.tv_sec) + (unsigned long) t.tv_usec;
	}
}

// once multiple threads are started, access this routine only with _debug_mutex locked
unsigned long last_debug_ticks;
void my_printbuf( int direction, char *name, char*buf, int count) {
	int i, clen;
	char c, dbuf[128];
	unsigned long now = get_microsec();
	unsigned long elapsed = now - last_debug_ticks;
	last_debug_ticks = now;
	
	if( direction) {
		my_print("%6s-> %16lu %10lu (%03u)::[", name, now, elapsed, count);
	} else {
		my_print("<-%6s %16lu %10lu (%03u)::[", name, now, elapsed, count);
	}
	for( i = 0; i < count; ) {
		for(clen = 0; clen < (sizeof(dbuf) - 6) && i < count; i++, clen++) {
			c = buf[i];
			if( c < ' ' || c > '~' || c == ']') {
				sprintf(&dbuf[clen], "{%02X}", 0xFF & c);
				clen += 3;
			} else {
				dbuf[clen] = c;
			}
		}
		dbuf[clen]= '\0';
		if( count - i > 12) {
			my_print("%s]\n                                            [", dbuf);
		} else {		
			my_print("%s", dbuf);
		}
		//my_print( dbuf);
	}
	my_print( "] ");
}
// thread safe
void my_debug( int flag, const char *format, ...) {
	if( flag) {
		pthread_mutex_lock( &debug_mutex);
		unsigned long now = get_microsec();
		unsigned long elapsed = now - last_debug_ticks;
		last_debug_ticks = now;
		my_print("-------- %16lu %10lu      ::", now, elapsed);
		va_list arg_list;
		va_start(arg_list, format);
		__my_print(format, arg_list);
		va_end( arg_list);
		pthread_mutex_unlock( &debug_mutex);
	}
}
// thread safe
void my_log( const char *format, ...) {
	pthread_mutex_lock( &debug_mutex);
	unsigned long now = get_microsec();
	unsigned long elapsed = now - last_debug_ticks;
	last_debug_ticks = now;
	my_print("-------- %16lu %10lu      ::", now, elapsed);
	va_list arg_list;
	va_start(arg_list, format);
	__my_print(format, arg_list);
	va_end( arg_list);
	pthread_mutex_unlock( &debug_mutex);
}


// error then die
void my_error( const char *format,...) {
	pthread_mutex_lock( &debug_mutex);
	va_list arg_list;
	va_start(arg_list, format);
	if(errno == 0) {
		my_print("ERROR::");
	} else {
		my_print("ERROR::errno = %d %s:: ", errno, strerror(errno));
	}
	__my_print( format, arg_list);
	va_end( arg_list);
	pthread_mutex_unlock( &debug_mutex);
	exit(-1);
}

void usage( ) {
	my_print("Usage::%s %s", program_name, usage_str);
	exit( -1);
}
// structures and routines for processing command line options
struct option long_options[] = {
	{"help",		no_argument, 0, 'h'},
	{"logfile",		required_argument, 0, 'L'},
	{"quiet",		no_argument, &quiet_mode, 1},
	{"debug_serial",	no_argument, &debug_serial, 1},
	{"loopback",		no_argument, &loopback_mode, 1},
	{"serial_device",	required_argument, 0, 's'},
	{"baud",		required_argument, 0, 'b'},
	{"line_delay",		required_argument, 0, 'd'},
	{"advanced_flow_control",	no_argument, &advanced_flow_control, 1},
	{"debug_afc",	no_argument, &debug_afc, 1},
	{"port",		required_argument,	0, 'p'},
	{"raw",			no_argument, &raw_mode, 1},
	{"expand_cr",		no_argument, &expand_cr_mode, 1},
	{"debug_port",		no_argument, &debug_port, 1},
	{0, 0, 0, 0}
};

int cmdlinetoi(char* val) {
	char *p;
	long rc = strtol(val, &p, 10);
	if(*p != '\0') {
		usage();
	}
	return ((int) rc);
}

void parse_options(int argc, char *argv[]) {
	int c, option_index = 0;
	while (-1 != (c = getopt_long (argc, argv, "hL:qSls:b:d:aAp:reP", long_options, &option_index))) {
		switch (c) {
			case 'h':
			case '?':
				usage();
			break;
			case 'L':
				logfile= optarg;
			break;
			case 'q':
				quiet_mode = 1;
			break;
			case 'S':
				debug_serial=1;
			break;
			case 'l':
				loopback_mode = 1;
			break;
			case 's':
				serial_device= optarg;
			break;
			case 'b':
				baud= cmdlinetoi(optarg);
				baud = (baud < 0) ? 0: baud;
			break;
			case 'd':
				line_delay= cmdlinetoi(optarg);
				line_delay = (line_delay < 0) ? 0: line_delay;
			break;
			case 'a':
				advanced_flow_control = 1;
			break;
			case 'A':
				debug_afc = 1;
			break;
			case 'p':
				port= cmdlinetoi(optarg);
			break;
			case 'r':
				raw_mode=1;
			break;
			case 'e':
				expand_cr_mode=1;
			break;
			case 'P':
				debug_port=1;
			break;
			case 0:
			break;
			default:
				my_error("option unknown with value: %s\n",optarg);
		}
	}
}
// thread safe blocking queues, used for inter thread communications
// __bq*() routines are internal, only be called with the mutex locked
typedef struct struct_ByteQueue {
	pthread_cond_t	bqCondSpaceAvailable, bqCondDataAvailable;
	pthread_mutex_t	bqMutex;
	char	*bqData;
	int	bqSize, bqHead, bqTail;
} ByteQueue;
void bq_init(ByteQueue *S, int size) {
	S->bqHead = 0;
	S->bqTail = 0;
	if( size <= 1) {
		S->bqSize = 2;
	} else if ( size >= 65535) {
		S->bqSize = 65536;
	} else {
		S->bqSize = size + 1;
	}
	if( NULL == (S->bqData = malloc(S->bqSize)) ){
		my_error( "memory allocation failed.\n");	
	}
	pthread_mutex_init(&S->bqMutex, NULL);
	pthread_cond_init(&S->bqCondSpaceAvailable, NULL);
	pthread_cond_init(&S->bqCondDataAvailable, NULL);
}
int bq_size( ByteQueue *S) {
	return S->bqSize - 1;
}
void __bq_inc_head(  ByteQueue *S) {
	if((++S->bqHead) >= S->bqSize) {
		S->bqHead = 0;
	}
}
void __bq_inc_tail(  ByteQueue *S) {
	if((++S->bqTail) >= S->bqSize) {
		S->bqTail = 0;
	}
}
void __bq_dec_head(  ByteQueue *S) {
	if((--S->bqHead) < 0) {
		S->bqHead = S->bqSize-1;
	}
}
void __bq_dec_tail(  ByteQueue *S) {
	if((--S->bqTail) < 0) {
		S->bqTail = S->bqSize-1;
	}
}
int __bq_data_available( ByteQueue *S) {
	int rc;
	if( S->bqHead >= S->bqTail) {
		rc = S->bqHead - S->bqTail;
	} else {
		rc = (S->bqSize - S->bqTail) + S->bqHead;
	}
	return rc;
}
int __bq_space_available( ByteQueue *S) {
	return bq_size(S) - __bq_data_available(S);
}
int __bq_is_space_available( ByteQueue *S) {
	return __bq_space_available(S) > 0;
}
int __bq_is_data_available( ByteQueue *S) {
	return __bq_data_available(S) > 0;
}
void __bq_wait_space_available_n(  ByteQueue *S, int len) {
	while( __bq_space_available(S) < len ){
		pthread_cond_signal( &S->bqCondDataAvailable);
		pthread_cond_wait( &S->bqCondSpaceAvailable, &S->bqMutex);
	}
}
void __bq_wait_space_available(  ByteQueue *S) {
	__bq_wait_space_available_n( S, 1);
}
void __bq_wait_data_available(  ByteQueue *S) {
	while( ! __bq_is_data_available(S)) {
		pthread_cond_signal( &S->bqCondSpaceAvailable);
		pthread_cond_wait( &S->bqCondDataAvailable, &S->bqMutex);
	}
}
void bq_append(ByteQueue *S, char c) {
	pthread_mutex_lock( &S->bqMutex);
	__bq_wait_space_available( S);
	S->bqData[S->bqHead] = c;
	__bq_inc_head( S);
	pthread_cond_signal( &S->bqCondDataAvailable);
	pthread_mutex_unlock( &S->bqMutex);
}
void bq_appendbuf(ByteQueue *S, char* P, int len) {
	if( len > 0) {
		pthread_mutex_lock( &S->bqMutex);
		while( len--) {
			__bq_wait_space_available( S);
			S->bqData[S->bqHead] = *P++;
			__bq_inc_head( S);
		}
		pthread_cond_signal( &S->bqCondDataAvailable);
		pthread_mutex_unlock( &S->bqMutex);
	}
}
void bq_appendbuf_atomic(ByteQueue *S, char* P, int len) {
	if( len > 0) {
		pthread_mutex_lock( &S->bqMutex);
		__bq_wait_space_available_n( S, len);
		while( len--) {
			S->bqData[S->bqHead] = *P++;
			__bq_inc_head( S);
		}
		pthread_cond_signal( &S->bqCondDataAvailable);
		pthread_mutex_unlock( &S->bqMutex);
	}
}
void bq_push(ByteQueue *S, char c) {
	int newHead;
	pthread_mutex_lock( &S->bqMutex);
	__bq_wait_space_available( S);
	__bq_dec_tail( S);
	S->bqData[S->bqTail] = c;
	pthread_cond_signal( &S->bqCondDataAvailable);
	pthread_mutex_unlock( &S->bqMutex);
}
char bq_pop(ByteQueue *S) {
	char rc;
	pthread_mutex_lock( &S->bqMutex);
	__bq_wait_data_available( S);
	rc = S->bqData[S->bqTail];
	__bq_inc_tail( S);
	pthread_cond_signal( &S->bqCondSpaceAvailable);
	pthread_mutex_unlock( &S->bqMutex);
	return( rc);
}
void bq_clear(ByteQueue *S) {
	pthread_mutex_lock( &S->bqMutex);
	S->bqHead = S->bqTail = 0;
	pthread_cond_signal( &S->bqCondSpaceAvailable);
	pthread_mutex_unlock( &S->bqMutex);
}
int __bq_popbuf(ByteQueue *S, char *P, int len, int flag) {
	int bytes_popped = 0;
	if( flag) {
		__bq_wait_data_available( S);
	}
	for( bytes_popped = 0; bytes_popped < len && __bq_is_data_available(S); bytes_popped++ ) {
		*P++ = S->bqData[S->bqTail];
		__bq_inc_tail( S);
	}
	return bytes_popped;
}
int bq_popbuf(ByteQueue *S, char *P, int len, int flag) {
	int bytes_popped = 0;
	if( len > 0) {
		pthread_mutex_lock( &S->bqMutex);
		bytes_popped = __bq_popbuf( S, P, len, flag);
		pthread_cond_signal( &S->bqCondSpaceAvailable);
		pthread_mutex_unlock( &S->bqMutex);
	}
	return bytes_popped;
}
int bq_popbuf_wait(ByteQueue *S, char *P, int len) {
	return bq_popbuf(S, P, len, 1);
}
int bq_popbuf_nowait(ByteQueue *S, char *P, int len) {
	return bq_popbuf(S, P, len, 0);
}
int bq_data_available( ByteQueue *S) {
	int rc;
	pthread_mutex_lock( &S->bqMutex);
	rc = __bq_data_available(S);
	pthread_mutex_unlock( &S->bqMutex);
	return rc;
}
int bq_space_available( ByteQueue *S) {
	int rc;
	pthread_mutex_lock( &S->bqMutex);
	rc = __bq_space_available(S);
	pthread_mutex_unlock( &S->bqMutex);
	return rc;
}

// structure to encapsulate parameters for the threads talking to the tcpip port
typedef struct struct_PortThreadParameters {
	ByteQueue	*from, *to;
	char		*name;
	int		listenfd, fd, raw, expand_cr, debug, port;
	pthread_t 	portReadThread, portWriteThread;
} PortThreadParameters;

/*
Telnet controls used
FF - IAC
FE - DONT
FD - DO
FC - WONT
FB - WILL
01 - ECHO
03 - Suppress goahead

Telnet sends either 0x0d 0x0a or 0x0d 0x00 - in both cases send only 0x0d

*/

// WILL ECHO, WILL Suppress goahead
char *telnetInit = "\xFF\xFB\x01\xFF\xFB\x03";

// from the queue out to the tcpip port
void portWriteMainCleanup( void *in) {
	PortThreadParameters *tp = (PortThreadParameters*) in;
	pthread_mutex_unlock( &tp->to->bqMutex);
	pthread_mutex_unlock( &debug_mutex);
}
void *portWriteMain(void *in) {
	PortThreadParameters *tp = (PortThreadParameters*) in;
	char	c, *out, buf[PORT_BUF_SIZE], ebuf[2*PORT_BUF_SIZE];
	int	s, d, bytes_read;
	
	pthread_cleanup_push( portWriteMainCleanup, in);
	while(1) {
		bytes_read =bq_popbuf_wait(tp->to, buf, sizeof( buf));
		if( !tp->expand_cr) {
			out = buf;
		} else {
			for( s = 0, d = 0; s < bytes_read; s++, d++) {
				if( '\x0D' == (ebuf[d] = buf[s]) ) {
					ebuf[++d] = '\x0A';
				}
			}
			out = ebuf;
			bytes_read = d;
		}
		if( tp->debug) {
			pthread_mutex_lock( &debug_mutex);
			my_printbuf(-1, tp->name,out, bytes_read);
			my_print(" PORT WRITE\n");
			pthread_mutex_unlock( &debug_mutex);
		}
		write(tp->fd, out, bytes_read);
	}
	pthread_cleanup_pop( 0);
}
// from the tcpip port to the queue
void *portReadMain(void *in) {
	PortThreadParameters *tp = (PortThreadParameters*) in;
	int i,d, opt_val = 1;
	struct sockaddr_in serv_addr, remote_addr;
	socklen_t len;
	size_t bytes_read;
	char ipstr[INET_ADDRSTRLEN], buf[PORT_BUF_SIZE], ebuf[PORT_BUF_SIZE];
	time_t ticks; 
	
	tp->fd = tp->listenfd =  -1;
	if( -1 == (tp->listenfd = socket(AF_INET, SOCK_STREAM, 0))) {
		my_error( "unable to create socket\n");
	}

	if(0 != setsockopt(tp->listenfd, SOL_SOCKET, SO_REUSEADDR, (void*) &opt_val, sizeof(opt_val))) {
		my_error( "unable to set socket option\n");
	}
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
	serv_addr.sin_port = htons(tp->port); 

	if( -1 == bind(tp->listenfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) ) {
		my_error( "unable to bind to socket\n");
	}
	// only allow 1 connection, no sharing a serial port 
	if( -1 == listen(tp->listenfd, 0)) {
		my_error( "unable to listen on socket\n");
	} 
	while(1) {
		tp->fd = accept(tp->listenfd, (struct sockaddr*)NULL, NULL);
		len = sizeof remote_addr;
		getpeername(tp->fd, (struct sockaddr*)&remote_addr, &len);
		inet_ntop(AF_INET, &remote_addr.sin_addr, ipstr, sizeof ipstr); 
		
		ticks = time(NULL);
		my_log("%.24s - Connection from %s : %d\n", ctime(&ticks), ipstr,ntohs(remote_addr.sin_port));
		if( pthread_create(&tp->portWriteThread, NULL, portWriteMain, (void*) tp)) {
			my_error("cannot create port write thread\n");
		}
		if(!tp->raw) {
			// initializes telnet
			bq_appendbuf_atomic(tp->to, telnetInit, strlen(telnetInit));
		}
		
		while( (bytes_read = read(tp->fd, buf, sizeof(buf))) >0 ) {
			if( tp->debug) {
				pthread_mutex_lock( &debug_mutex);
				my_printbuf(0, tp->name, buf, bytes_read);
				my_print(" PORT READ\n");
				pthread_mutex_unlock( &debug_mutex);
			}
			if(tp->raw) {
				bq_appendbuf(tp->from, buf, bytes_read);
			} else {
				// handle telnet control sequences
				for( i = 0, d = 0; i < bytes_read; i++, d++) {
					if( buf[i] == '\xFF' && i+2 < bytes_read) {
						if( buf[i+1] == '\xFB' && buf[i+2] == '\x03') {
							buf[i+1] = '\xFD';
						} else if( buf[i+1] == '\xFD' && buf[i+2] == '\x03') {
							buf[i+1] = '\xFB';
						} else if( buf[i+1] == '\xFD' && buf[i+2] == '\x01') {
							buf[i+1] = '\xFB';
						} else if( buf[i+1] == '\xFC') {
							buf[i+1] = '\xFE';
						} else if( buf[i+1] == '\xFE') {
							buf[i+1] = '\xFC';
						} else {
							buf[i] = '\0';
						}
						if( buf[i] == '\xFF') {
							bq_appendbuf(tp->to, &buf[i], 3);
						}
						i += 2;
						d--;
					} else {
						if( (ebuf[d] = buf[i]) == '\x0D') {
							if( i+1 < bytes_read && (buf[i+1] == '\x00' || buf[i+1] == '\x0A') ) {
								i++;
							}
							if( line_delay > 0) {
								usleep( line_delay);
							}
							bq_appendbuf(tp->from, ebuf, d);
							d = 0;
						}
					}
				}
				bq_appendbuf(tp->from, ebuf, d);
			}
		}
		if( bytes_read == -1) {
			my_error( "recv on socket\n");
		} else {
			pthread_cancel(tp->portWriteThread);
			close(tp->fd);
			tp->fd = -1;
			ticks = time(NULL);
			my_log("%.24s - Connection from %s : %d Closed\n", ctime(&ticks), ipstr,ntohs(remote_addr.sin_port));
		}
	}
	close(tp->listenfd);
	tp->fd = tp->listenfd = -1;
	pthread_exit(NULL);
}
/*
advanced_flow_control

The basics are:
It is assumed the other side has a 511 byte buffer.
An ack will be sent every 256 bytes. This means there 
are at least 256 bytes free in the buffer.
Control Characters (\0x00 - \x03) are not in this count
as they are not buffered.

It is assumed that the port is running in binary.

Byte values \x00 - \x03 are sent over the wire as \x03 \x80 - \x83.
In general any byte following \x03 will be anded with a \x7F, execpt
if the value is 0-3. These are interpreted as control characters.

This means sending binary data with a lot of 0, 1, 2, 3, will
be slower than the transmission of normal data.

Flow Protocol
0x00 - no action
0x01 - ack - 256 bytes received and out of the buffer
0x02 - restart - the driver has restarted
0x03 - escape - the next byte should be anded with 0x7F 

*/

// structure to encapsulate parameters for the threads talking to the serial port
typedef struct struct_SerialThreadParameters {
	ByteQueue	*serialRawIn, *serialAcks, *serialRawOut, *fromPort, *toPort;
	char		*name, *serDevice;
	int		fd,  debug, debug_afc, loopback, baud, afc;
	pthread_t	serialReadThread, serialRawReadThread, serialWriteThread, serialRawWriteThread;
	// for debugging
	pthread_mutex_t	debug_mutex;
	int		write_count, rec_count, raw_write_count, raw_rec_count, rec_acks, sent_acks, used_acks;
	char		*serialReadStatus, *serialWriteStatus, *serialRawReadStatus, *serialRawWriteStatus;
} SerialThreadParameters;
// debug output for advanced flow control
void my_serial_debug_afc( SerialThreadParameters *tp, const char *format, ...) {
	int write_count, rec_count, raw_write_count, raw_rec_count, rec_acks, sent_acks, used_acks;
	if( tp->afc && tp->debug_afc) {
		pthread_mutex_lock( &tp->debug_mutex);
		write_count = tp->write_count;
		rec_count = tp->rec_count;
		raw_write_count = tp->raw_write_count;
		raw_rec_count = tp->raw_rec_count;
		rec_acks = tp->rec_acks;
		sent_acks = tp->sent_acks;
		used_acks = tp->used_acks;
		pthread_mutex_unlock( &tp->debug_mutex);
			
		pthread_mutex_lock( &debug_mutex);
		unsigned long now = get_microsec();
		unsigned long elapsed = now - last_debug_ticks;
		last_debug_ticks = now;
		my_print("-------- %16lu %10lu      : ", now, elapsed);
		my_print("write_count:%d raw_write_count:%d rec_acks:%d used_acks:%d unacked_sent:%d ",
			write_count,raw_write_count, rec_acks, used_acks, write_count - (256*rec_acks));
		my_print("rec_count:%d raw_rec_count:%d sent_acks:%d unacked_rec:%d ",
			rec_count, raw_rec_count, sent_acks, rec_count - (256*sent_acks));
		va_list arg_list;
		va_start(arg_list, format);
		__my_print(format, arg_list);
		va_end( arg_list);
		pthread_mutex_unlock( &debug_mutex);
	}
}
// from the queue out to the serial port
void serialRawWriteMainCleanup( void *in) {
	SerialThreadParameters *tp = (SerialThreadParameters*) in;
	pthread_mutex_unlock( &tp->serialRawOut->bqMutex);
	pthread_mutex_unlock( &debug_mutex);
	pthread_mutex_unlock( &tp->debug_mutex);
}
void *serialRawWriteMain(void *in) {
	SerialThreadParameters *tp = (SerialThreadParameters*) in;
	char	buf[SERIAL_BUF_SIZE];
	int	i, raw_write_buf_count;
	size_t	bytes_written;
	
	tp->serialRawWriteStatus = "serialRawWriteMain ENTER";
	
	pthread_cleanup_push( serialRawWriteMainCleanup, in);
	while(1) {
		tp->serialRawWriteStatus = "Waiting for data to write\n";
		raw_write_buf_count =bq_popbuf_wait(tp->serialRawOut, buf, sizeof(buf));
		tp->serialRawWriteStatus = "Debug buf out\n";
		if( tp->debug) {
			pthread_mutex_lock( &debug_mutex);
			my_printbuf(0, tp->name, buf, raw_write_buf_count);
			my_print(" raw_write_buf_count:%d RAW WRITE\n", raw_write_buf_count);
			pthread_mutex_unlock( &debug_mutex);
			
			if(tp->afc && tp->debug_afc) {
				pthread_mutex_lock( &tp->debug_mutex);
				tp->raw_write_count += raw_write_buf_count;
				pthread_mutex_unlock( &tp->debug_mutex);
			}
			my_serial_debug_afc(tp, "raw_write_buf_count:%d RAW WRITE\n", raw_write_buf_count);
		}
		tp->serialRawWriteStatus = "Writing data to serial port.\n";
		bytes_written = write(tp->fd, buf, raw_write_buf_count);
		if( bytes_written != raw_write_buf_count) {
			char bbb[256];
			strerror_r(errno, bbb, sizeof(bbb));
			my_log("SERIAL WRITE ERROR: errno:%d [%s] bytes_written:%d raw_write_buf_count=%d\n ", errno, bbb,bytes_written, raw_write_buf_count);
		}
	}
	tp->serialRawWriteStatus = "Dyeing\n";
	pthread_cleanup_pop( 0);
}
// from one queue to another - takes care of advanced flow control on the write side
void serialWriteMainCleanup( void *in) {
	SerialThreadParameters *tp = (SerialThreadParameters*) in;
	pthread_mutex_unlock( &tp->fromPort->bqMutex);
	pthread_mutex_unlock( &debug_mutex);
	pthread_mutex_unlock( &tp->debug_mutex);
	pthread_mutex_unlock( &tp->serialAcks->bqMutex);
	pthread_mutex_unlock( &tp->serialRawOut->bqMutex);
}
void *serialWriteMain(void *in) {
	SerialThreadParameters *tp = (SerialThreadParameters*) in;
	char	c, buf[AFC_ACK_SIZE], ack_buf[ AFC_ACK_QUEUE_SIZE];
	int	i, clen, buf_available = AFC_BUF_SIZE, write_buf_count, raw_write_buf_count, ack_used = 0, ack_buf_count;
	
	tp->serialWriteStatus = "serialWriteMain ENTER";
	pthread_cleanup_push( serialWriteMainCleanup, in);
	while(1) {
		tp->serialWriteStatus = "Waiting for data to write\n";
		write_buf_count = raw_write_buf_count =bq_popbuf_wait(tp->fromPort, buf, sizeof(buf) / 2);
		if(tp->afc) {
			for( i = 0; i < raw_write_buf_count; i++) {
				c = buf[i];
				if( c <='\x03' && c >='\x00') {
					clen = raw_write_buf_count - i;
					if( clen > 0) {
						memmove(&buf[i+1], &buf[i], clen);
					}
					buf[i] = '\x03';
					buf[i+1] = '\x80' | c;
					raw_write_buf_count++;
					i++;
				}
			}
			if( buf_available < write_buf_count) {
				tp->serialWriteStatus = "Waiting for buffer to come available.\n";
				my_serial_debug_afc(tp, "raw_write_buf_count:%d WRITE WAIT\n", raw_write_buf_count);
				ack_buf_count = bq_popbuf_wait(tp->serialAcks, ack_buf, sizeof(ack_buf));
			} else {
				ack_buf_count = bq_popbuf_nowait(tp->serialAcks, ack_buf, sizeof(ack_buf));
			}
			tp->serialWriteStatus = "Waiting processing acks\n";
			for( i = 0; i < ack_buf_count; i++) {
				c = ack_buf[ i];
				if( c == '\x01') {
					buf_available += AFC_ACK_SIZE;
					if( tp->debug_afc) {
						pthread_mutex_lock( &tp->debug_mutex);
						tp->used_acks++;
						pthread_mutex_unlock( &tp->debug_mutex);
						my_serial_debug_afc(tp, "buf_available:%d ACK_USED\n", buf_available);
					}
				} else {
					my_serial_debug_afc(tp, "buf_available:%d HUH:%c\n", buf_available, c);
				}
			}
			buf_available -= write_buf_count;
			if( tp->debug_afc) {
				pthread_mutex_lock( &tp->debug_mutex);
				tp->write_count += write_buf_count;
				pthread_mutex_unlock( &tp->debug_mutex);
				my_serial_debug_afc(tp, "raw_write_buf_count:%d WRITE\n", raw_write_buf_count);
			}
		}
		tp->serialWriteStatus = "Writing to output queue\n";
		bq_appendbuf(tp->serialRawOut, buf, raw_write_buf_count);
	}
	tp->serialWriteStatus = "Dyeing\n";
	pthread_cleanup_pop( 0);
}


// from the the serial port to the queue
void serialRawReadMainCleanup( void *in) {
	SerialThreadParameters *tp = (SerialThreadParameters*) in;
	pthread_mutex_unlock( &tp->serialRawIn->bqMutex);
	pthread_mutex_unlock( &debug_mutex);
	pthread_mutex_unlock( &tp->debug_mutex);
}
void *serialRawReadMain(void *in) {
	SerialThreadParameters *tp = (SerialThreadParameters*) in;
	int raw_read_buf_count, rc;
	
	char c, buf[SERIAL_BUF_SIZE];
	tp->serialRawReadStatus = "serialRawReadMain ENTER";
	
	pthread_cleanup_push( serialRawReadMainCleanup, in);
	while( 1) {
		tp->serialRawReadStatus = "Waiting for data from serial port\n";
		raw_read_buf_count = read( tp->fd, buf, sizeof( buf));
		if( raw_read_buf_count <= 0) {
			break;
		} else {
			tp->serialRawReadStatus = "Debug buffer out\n";
			if( tp->debug ) {
				pthread_mutex_lock( &tp->debug_mutex);
				tp->raw_rec_count += raw_read_buf_count;
				pthread_mutex_unlock( &tp->debug_mutex);
	
				pthread_mutex_lock( &debug_mutex);
				my_printbuf(-1, tp->name, buf, raw_read_buf_count);
				my_print(" raw_read_buf_count:%d RAW READ\n", raw_read_buf_count);
				pthread_mutex_unlock( &debug_mutex);
			}
			tp->serialRawReadStatus = "Writing to output queue\n";
			bq_appendbuf(tp->serialRawIn, buf, raw_read_buf_count);
		}
	}
	tp->serialRawReadStatus = "Dyeing\n";
	pthread_cleanup_pop( 0);
	if( raw_read_buf_count == -1) {
		my_error( "serial read -1\n");
	} else {
		my_error( "serial read 0\n");
	}
	pthread_exit(NULL);
}
void *serialReadMain(void *);
void *serialRawRWMain(void *);
void initSerialPort(SerialThreadParameters *tp) {
	struct termios tio;
	speed_t speed;
	int nonStandardBaud = 0;
	
	my_debug( -1, "initSerialPort [%s]\n", tp->serDevice);
	if( -1 == (tp->fd = open(tp->serDevice, O_RDWR | O_NOCTTY)) ) {
		my_debug( -1, "initSerialPort error opening [%s]\n", tp->serDevice);
		my_error( "opening serial port\n");
	}
	tcflush(tp->fd, TCIOFLUSH);
	if( -1 == tcgetattr( tp->fd, &tio)) {
		my_error( "getting serial attributes\n");
	}
	tio.c_cflag &= ~CRTSCTS;
	tio.c_cflag |= CLOCAL | CREAD;
	tio.c_iflag |= IGNPAR;
	tio.c_oflag = 0;
	cfmakeraw( &tio);
	tio.c_cc[VMIN] = 1;
	tio.c_cc[VTIME] = 0;
	switch( tp->baud) {
		case 230400:
			speed = B230400;
			break;
		case 115200:
			speed = B115200;
			break;
		case 57600:
			speed = B57600;
			break;
		case 19200:
			speed = B19200;
			break;
		case 9600:
			speed = B9600;
			break;
		case 1200:
			speed = B1200;
			break;
		default:
			my_log( "Non Standard Baud Rate. [%ld]\n", tp->baud);
			nonStandardBaud = -1;
			speed = B230400;
	}
	if( -1 == cfsetispeed(&tio, speed) || -1 ==  cfsetospeed(&tio, speed)){
		my_error( "setting baud rate\n");
	}
	if( -1 == tcsetattr( tp->fd, TCSANOW, &tio)) {
		my_error( "setting serial attributes\n");
	}
	if( nonStandardBaud) {
		// OSX ONLY SOLUTION

		/*
		 * Sets the input speed and output speed to a non-traditional baud rate
		 */
		#define IOSSIOSPEED    _IOW('T', 2, speed_t)
		#define IOSSIOSPEED_32    _IOW('T', 2, user_shspeed_t)
		#define IOSSIOSPEED_64    _IOW('T', 2, user_speed_t)

		speed = tp->baud;
		if( -1 == ioctl (tp->fd, IOSSIOSPEED, &speed, 1)) {
			my_error( "setting non standard baud rate\n");
		}
		
		
		// LINUX SOLUTION - untested
		/*
			struct serial_struct ser;
			ioctl (fd_, TIOCGSERIAL, &ser);
			// set custom divisor
			ser.custom_divisor = ser.baud_base / baudrate_;
			// update flags
			ser.flags &= ~ASYNC_SPD_MASK;
			ser.flags |= ASYNC_SPD_CUST;
			
			if (ioctl (fd_, TIOCSSERIAL, ser) < 0)
			{
			  // error
			}

		*/
	}
	if( pthread_create(&tp->serialWriteThread, NULL, serialWriteMain, (void*) tp)) {
		my_error("cannot create serial port raw read thread\n");
	}
	if( pthread_create(&tp->serialRawReadThread, NULL, serialRawReadMain, (void*) tp)) {
		my_error("cannot create serial port raw write thread\n");
	}
	if( pthread_create(&tp->serialRawWriteThread, NULL, serialRawWriteMain, (void*) tp)) {
		my_error("cannot create serial port raw write thread\n");
	}
	tcflush(tp->fd, TCIOFLUSH);
	my_debug( -1, "initSerialPort DONE [%s]\n", tp->serDevice);
}
// from one queue to another - takes care of advanced flow control on the read side
void *serialReadMain(void *in) {
	SerialThreadParameters *tp = (SerialThreadParameters*) in;
	int i, clen, raw_read_buf_count, read_buf_count, unacked_bytes_received=0, rec_count = 0, ack_sent_count = 0, ack_rec_count = 0;
	char c, mask = '\xFF', buf[SERIAL_BUF_SIZE];
	time_t ticks;
	int initSent = 0;
	
	pthread_mutex_init(&tp->debug_mutex, NULL);
	while( tp->loopback) {
		read_buf_count =bq_popbuf_wait(tp->fromPort, buf, sizeof( buf));
		if( tp->debug) {
			pthread_mutex_lock( &tp->debug_mutex);
			tp->raw_rec_count += raw_read_buf_count;
			pthread_mutex_unlock( &tp->debug_mutex);
			
			pthread_mutex_lock( &debug_mutex);
			my_printbuf(-1, "loop", buf, read_buf_count);
			my_print("raw_read_buf_count:%d\n", raw_read_buf_count);
			pthread_mutex_unlock( &debug_mutex);
		}
		bq_appendbuf(tp->toPort, buf, read_buf_count);
	}
	initSerialPort( tp);
	if(tp->afc) {
		initSent = -1;
		bq_push(tp->serialRawOut, '\x02');
		ticks = time(NULL);
		my_log("%.24s - SERIAL RESTART initiated by %s\n", ctime(&ticks), program_name);
		tp->write_count = tp->raw_write_count = tp->used_acks = tp->rec_count =tp->raw_rec_count = tp->rec_acks = tp->sent_acks = 0;
	}
	while( 1) {
		tp->serialReadStatus = "Waiting for data from input queue\n";
		raw_read_buf_count = read_buf_count=bq_popbuf_wait(tp->serialRawIn, buf, sizeof( buf));
		if(tp->afc) {
			for(i = 0; i < read_buf_count; i++) {
				c = buf[i];
				if( c <='\x03' && c >='\x00') {
					switch(c) {
					case 0:
						my_serial_debug_afc(tp, "NULL RECEIVED\n");
						break;
					case 1:
						tp->serialReadStatus = "Processing received ack\n";
						bq_append(tp->serialAcks, '\x01');
						if( tp->debug_afc) {
							pthread_mutex_lock( &tp->debug_mutex);
							tp->rec_acks++;
							pthread_mutex_unlock( &tp->debug_mutex);
							my_serial_debug_afc(tp, "ACK RECEIVED\n");
						}
						break;
					case 2:
						tp->serialReadStatus = "Processing received restart\n";
						if( initSent ) {
							pthread_cancel(tp->serialRawReadThread);
							pthread_cancel(tp->serialRawWriteThread);
							pthread_cancel(tp->serialWriteThread);
							bq_clear(tp->serialAcks);
							bq_clear(tp->serialRawIn);
							bq_clear(tp->serialRawOut);
							bq_clear(tp->fromPort);
							bq_clear(tp->toPort);
							close(tp->fd);
							initSerialPort( tp);
	
							unacked_bytes_received = 0;
							if( tp->debug_afc) {
								pthread_mutex_lock( &tp->debug_mutex);
								tp->write_count = tp->raw_write_count = tp->used_acks = tp->rec_count = tp->raw_rec_count = tp->rec_acks = tp->sent_acks = 0;
								pthread_mutex_unlock( &tp->debug_mutex);
								my_serial_debug_afc(tp, "RESTART Read\n");
							}
						}
						initSent = 0;
						ticks = time(NULL);
						my_log("%.24s - SERIAL RESTART initiated by remote\n", ctime(&ticks));
						break;
					case 3:
						mask = '\x7F';
						break;
					}
					clen = read_buf_count - (i + 1);
					read_buf_count--;
					if( clen <= 0) {
						break;
					}
					memmove(&buf[i], &buf[i+1], clen);
					i--;
				} else {
					buf[i] &= mask;
					mask = '\xFF';
				}
			}
			if( initSent) {
				initSent = 0;
			}
		}
		tp->serialReadStatus = "Debug buf out\n";
		if( tp->afc && tp->debug_afc) {
			pthread_mutex_lock( &tp->debug_mutex);
			tp->rec_count += read_buf_count;
			pthread_mutex_unlock( &tp->debug_mutex);
			my_serial_debug_afc(tp, "raw_read_buf_count:%d read_buf_count:%d READ\n", raw_read_buf_count, read_buf_count);
		}
		unacked_bytes_received += read_buf_count;
		if( unacked_bytes_received >= AFC_ACK_SIZE) {
			unacked_bytes_received -= AFC_ACK_SIZE;
			if(tp->afc) {
				tp->serialReadStatus = "Processing send ack\n";
				bq_push(tp->serialRawOut, '\x01');
				if( tp->debug_afc) {
					pthread_mutex_lock( &tp->debug_mutex);
					tp->sent_acks++;
					pthread_mutex_unlock( &tp->debug_mutex);
					my_serial_debug_afc(tp, "ACK SENT\n");
				}
			}
		}
		tp->serialReadStatus = "Writing data to output buf\n";
		bq_appendbuf(tp->toPort, buf, read_buf_count);
	}
	tp->serialReadStatus = "Dyeing\n";
	if( read_buf_count == -1) {
		my_error( "serial read -1\n");
	} else {
		my_error( "serial read 0\n");
	}
	pthread_exit(NULL);
}

/*
   serial port-->serialRaWReadMain-->serial_raw_in Queue-->serialReadMain------------------>to_port Queue----->portWriteMain --------> tcpip port
           |                                               |   |                              |                                             |
           |                                      <---------   ---->serial_acks Queue-->       <----------------------(telnet control)      |
           |                                     |       (afc control)                  |                             |                     |
           |                                     |                                      |                             |                     | 
           <-----serialRawWriteMain<------serial_raw_out Queue<-------------serialWriteMain<--from_port Queue<------ portReadMain<-----------
*/
void  INThandler(int);

ByteQueue to_port, from_port, serial_acks, serial_raw_out, serial_raw_in;

#define MAX_ARGC  32
#define MAX_ARG_BUFFER 1024
PortThreadParameters port_thread_parameters;
SerialThreadParameters serial_thread_parameters;
char arg_buffer[ MAX_ARG_BUFFER], *fargv[ MAX_ARGC];
int main (int argc, char *argv[]) {
	char *P, buf[256], *rev = "1.03";
	FILE *f;
	
	program_name = argv[0];
	P = strrchr( __FILE__, '_');
	if( argc == 1 && ( (NULL != (f = fopen("./serial_proxy.conf","r"))) || (NULL != (f = fopen("/etc/serial_proxy.conf","r")))  ) ) {
		strcpy( arg_buffer, program_name);
		while( NULL != fgets( buf, sizeof(buf), f)) {
			if(buf[0] != '#' && strlen(buf) < ((MAX_ARG_BUFFER - 2) - strlen(arg_buffer)) ) {
				strcat(arg_buffer, " ");
				strcat(arg_buffer, buf);
			}
		}
		fclose(f);
		for(fargv[0] = strtok(arg_buffer, " \t\n\r"), argc = 1; argc < MAX_ARGC && NULL != (fargv[argc] = strtok( NULL, " \t\n\r")); argc++) { }
		argv = fargv;		
	}
	
	parse_options( argc, argv);
	if( optind != argc) {
		usage();
	}
	if( *logfile != '\0') {
		if( NULL == (logfileFp = fopen(logfile, "a")) ) {
			my_error( "opening logfile\n");
		}
	}
	if( loopback_mode) {
		serial_device = "";
		advanced_flow_control = 0;
		baud = 0;
	}
	if( raw_mode) {
		expand_cr_mode = 0;
	}
	if( logfileFp == NULL && quiet_mode) {
		debug_serial = 0;
		debug_port = 0;
	} else {
		my_print("\n%s  REV %s starting with:\nquiet_mode=%d\nlogfile=%s\ndebug_serial=%d\nloopback_mode=%d\n", program_name, rev, quiet_mode, logfile, debug_serial, loopback_mode);
		if( !loopback_mode) {
			my_print("serial_device=%s\nbaud=%d\nline_delay=%d micro-seconds\nadvanced_flow_control=%d\ndebug_afc=%d\n",
				serial_device, baud, line_delay, advanced_flow_control, debug_afc);
		}
		my_print("port=%d\nraw_mode=%d\n", port, raw_mode);
		if( !raw_mode) {
			my_print("expand_cr_mode=%d\ndebug_port=%d\n", expand_cr_mode, debug_port);
		}
		my_print("\n");
	}
	last_debug_ticks = get_microsec();
	pthread_mutex_init(&debug_mutex, NULL);

	bq_init(&to_port, PORT_QUEUE_SIZE);
	bq_init(&from_port,  PORT_QUEUE_SIZE);
	port_thread_parameters.fd = -1;
	port_thread_parameters.port = port;
	port_thread_parameters.raw = raw_mode;
	port_thread_parameters.expand_cr = expand_cr_mode;
	port_thread_parameters.debug = debug_port;
	port_thread_parameters.name = "port";
	port_thread_parameters.to = &to_port;
	port_thread_parameters.from = &from_port;
	
	bq_init(&serial_acks, AFC_ACK_QUEUE_SIZE);
	bq_init(&serial_raw_in,  SERIAL_QUEUE_SIZE);
	bq_init(&serial_raw_out,  SERIAL_QUEUE_SIZE);
	serial_thread_parameters.fd = -1;
	serial_thread_parameters.debug = debug_serial;
	serial_thread_parameters.name = "ser";
	serial_thread_parameters.baud = baud;
	serial_thread_parameters.afc = advanced_flow_control;
	serial_thread_parameters.debug_afc = debug_afc;
	serial_thread_parameters.loopback = loopback_mode;
	serial_thread_parameters.serDevice = serial_device;
	serial_thread_parameters.toPort = &to_port;
	serial_thread_parameters.fromPort = &from_port;
	serial_thread_parameters.serialAcks = &serial_acks;
	serial_thread_parameters.serialRawIn = &serial_raw_in;
	serial_thread_parameters.serialRawOut = &serial_raw_out;
	
	serial_thread_parameters.serialReadStatus = "";
	serial_thread_parameters.serialWriteStatus = "";
	serial_thread_parameters.serialRawReadStatus = "";
	serial_thread_parameters.serialRawWriteStatus = "";

	if( pthread_create(&port_thread_parameters.portReadThread, NULL, portReadMain, (void*) &port_thread_parameters)) {
		my_error( "creating port thread\n");
	}
	if( pthread_create(&serial_thread_parameters.serialReadThread, NULL, serialReadMain, (void*) &serial_thread_parameters)) {
		my_error( "creating serial thread\n");
	}
	signal(SIGINT, INThandler);
	//for debugging thread hangs
	/*
	while( 1)
	{
		sleep( 2);
		ByteQueue *S;
		char *P;
		S = &to_port;
		my_debug( 1, "to_port: %d %d\n", bq_space_available(S), bq_data_available(S));
		S = &from_port;
		my_debug( 1, "from_port: %d %d\n", bq_space_available(S), bq_data_available(S));
		S = &serial_acks;
		my_debug( 1, "serial_acks: %d %d\n", bq_space_available(S), bq_data_available(S));
		S = &serial_raw_in;
		my_debug( 1, "serial_raw_in: %d %d\n", bq_space_available(S), bq_data_available(S));
		S = &serial_raw_out;
		my_debug( 1, "serial_raw_out: %d %d\n", bq_space_available(S), bq_data_available(S));
		
		P = serial_thread_parameters.serialReadStatus;
		my_debug( 1, "serialReadStatus: %s\n", P);
		P = serial_thread_parameters.serialWriteStatus;
		my_debug( 1, "serialWriteStatus: %s\n", P);
		P = serial_thread_parameters.serialRawReadStatus;
		my_debug( 1, "serialRawReadStatus: %s\n", P);
		P = serial_thread_parameters.serialRawWriteStatus;
		my_debug( 1, "serialRawWriteStatus: %s\n", P);
	}
	*/

	// demonize here
	pthread_join(port_thread_parameters.portReadThread, NULL);
	pthread_join(serial_thread_parameters.serialReadThread, NULL);
	pthread_join(port_thread_parameters.portWriteThread, NULL);
	pthread_join(serial_thread_parameters.serialRawReadThread, NULL);
	pthread_join(serial_thread_parameters.serialRawWriteThread, NULL);
	pthread_join(serial_thread_parameters.serialWriteThread, NULL);
	exit( 0);
}
void  INThandler(int sig) {
	signal(sig, SIG_IGN);
	
	if( port_thread_parameters.fd != -1) {
		close(port_thread_parameters.fd);
		pthread_cancel(port_thread_parameters.portWriteThread);
		pthread_join(port_thread_parameters.portWriteThread, NULL);
	}
	if( port_thread_parameters.listenfd != -1) {
		close(port_thread_parameters.listenfd);
	}
	pthread_cancel(port_thread_parameters.portReadThread);
	pthread_cancel(serial_thread_parameters.serialReadThread);
	pthread_cancel(serial_thread_parameters.serialRawReadThread);
	pthread_cancel(serial_thread_parameters.serialRawWriteThread);
	pthread_cancel(serial_thread_parameters.serialWriteThread);
	
	pthread_join(port_thread_parameters.portReadThread, NULL);
	pthread_join(serial_thread_parameters.serialRawReadThread, NULL);
	pthread_join(serial_thread_parameters.serialRawWriteThread, NULL);
	pthread_join(serial_thread_parameters.serialWriteThread, NULL);
	pthread_join(serial_thread_parameters.serialReadThread, NULL);
	exit(0);
}
