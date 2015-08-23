
package main
//
// If the debug channel is connected first, any characters coming from the serial channel with the high bit set will be  routed
// to the debug channel. Otherwise all characters will be routed to the channel.
// Only one channel at a time can be connected.
//

import (
	"errors"
	"fmt"
	"flag"
	"os"
	"net"
	"runtime"
	"serafcFilter"
	"serial"
	"sort"
	"strconv"
	"strings"
	"telnetFilter"
	"time"
)

type TCPChannels struct {
	to chan byte
	from chan byte
	quit chan bool

	conn *net.TCPConn

	fromSerial chan byte
	toSerial chan byte
}


func main() {
	var err error
	var n int64
	var intargs [3]int
	var chanFromSerial, chanToSerial chan byte
	var tcp *TCPChannels
	var tcpDbg *TCPChannels
	var comPort string
	
	runtime.GOMAXPROCS(runtime.NumCPU())
	var cp string
	var cb int
	flag.StringVar(&cp, "serial_device", "/dev/USB0","Serial device to use (/dev/ttyUSB0)")
	flag.IntVar(&cb, "baud", 230400,"Serial device baud rate. (230400)")
	flag.Parse()
	fmt.Printf( "%s %d\n", cp, cb)
	
	conLog := make( chan string)
	go func() {
		for s := range  conLog {
			fmt.Print( s)
		}
	}()
	
	err = nil;

	conLog <- fmt.Sprintf( "%s Using %d CPUs\n", time.Now().Local(), runtime.GOMAXPROCS(-1))
/*
	if len(os.Args) == 1 {
		comPort = "com130"
		intargs[0] = 230400
		intargs[1] = 3000
		intargs[2] = 0
	} else if len(os.Args) == 2 {
		comPort = "com130"
		intargs[0] = 230400
		intargs[1] = 3000
		n, err = strconv.ParseInt( os.Args[1], 10, 32)
		if err != nil {
			intargs[2]= 0
		} else {
			intargs[2] = int(n)
		}
	} else 
*/
	if len(os.Args) == 5{
		comPort = os.Args[1]
		for i := 0; err == nil && i < 3; i++ {
			n, err = strconv.ParseInt( os.Args[i+2], 10, 32)
			intargs[i] = int(n)
		}
	} else {
		err = errors.New("Incorrect number of arguments")
	}
	fmt.Printf( "Starting: %s %s %d %d %d %d %d\n", os.Args[0], comPort, intargs[0], intargs[1], intargs[1]+100, intargs[1]+200, intargs[2])
	if err == nil {
		chanFromSerial, chanToSerial, _ , _ , err = serial.SerialChannels( comPort, intargs[0], conLog, intargs[2]&2 != 0)
	}
	if err != nil || chanFromSerial == nil {
		conLog <- fmt.Sprintf( "%s error: %s\nusage: %s comPort baud rawPort debug[0-3]\n",
			time.Now().Local(), err, os.Args[0])
		return
	}
	chanFromProtocol, chanToProtocol := serafcFilter.ProtocolFilter( chanFromSerial, chanToSerial, conLog, intargs[2]&1 != 0)
	dataChanFromProtocol := chanFromProtocol
//	chanFromProtocol, chanToProtocol :=  chanFromSerial, chanToSerial
	fmt.Printf( "Started:  %s %s %d Raw:%d Telnet:%d Debug:%d %d\n", os.Args[0], comPort, intargs[0], intargs[1], intargs[1]+100, intargs[1]+200, intargs[2])
	rawChannel := ListenTCPall( intargs[1])
	telnetChannel := ListenTCPall( intargs[1]+ 100)
	debugChannel := ListenTCPall( intargs[1]+ 200)
	for{
		fmt.Printf("%s READY\r\n",  time.Now().Local())
		select {
		case tcp = <- rawChannel:
			tcp.fromSerial = dataChanFromProtocol
			tcp.toSerial = chanToProtocol
			RawServer( tcp)

		case tcp = <- telnetChannel:
			tcp.fromSerial = dataChanFromProtocol
			tcp.toSerial = chanToProtocol
			TelnetServer( tcp)

		case tcpDbg = <- debugChannel:
			debugChanFromProtocol := make( chan byte, 256)
			dataChanFromProtocol = make( chan byte, 256)
			debugChanToProtocol := make( chan byte, 256)
			
			go func() {
				for c := range  chanFromProtocol {
					if c & 0x80 == 0x80 {
						debugChanFromProtocol <- 0x7F & c
					} else {
						dataChanFromProtocol <- c
					}
				}
			}()
			go func() {
				for _ = range  debugChanToProtocol {
				}
			}()
			
			tcpDbg.fromSerial = debugChanFromProtocol
			tcpDbg.toSerial = debugChanToProtocol
			go TelnetServer( tcpDbg)
		}
	}
}

func RawServer(tcpch *TCPChannels) {
	fmt.Printf("%s New Raw Connection %v <--> %v\n", time.Now().Local(),tcpch.conn.LocalAddr(),tcpch.conn.RemoteAddr())
	fp , e := os.Create("rawlog.txt")
	if e != nil {
		fmt.Printf("Log file open error: %s\n", e)
	}
			
	peerQuit := make( chan bool)
	go func() {
		d := make( []byte, 1)
		for q := false; q ==false; {
			select {
			case q = <-peerQuit:
			case d[0] = <-tcpch.fromSerial:
				fp.Write(d)
				tcpch.to<- d[0]
			}
		}
	}()

	for q := false; q == false; {
		select {
		case q = <-tcpch.quit:
			peerQuit<- true
		case d := <-tcpch.from:
			tcpch.toSerial<- d
		}
	}
	fp.Close()
	fmt.Printf("%s Raw Connection Closed %v <--> %v\n" ,time.Now().Local(), tcpch.conn.LocalAddr(),tcpch.conn.RemoteAddr())
}


func TelnetServer(tcpch *TCPChannels) {
	fmt.Printf("%s New Telnet Connection %v <--> %v\n", time.Now().Local(), tcpch.conn.LocalAddr(),tcpch.conn.RemoteAddr())
	fp , e := os.Create("telnetlog.txt")
	if e != nil {
		fmt.Printf("Log file open error: %s\n", e)
	}

	peerQuit := make( chan bool)
	fromTelnetFilter, toTelnetFilter, filterReady := telnetFilter.TelnetFilters( tcpch.from, tcpch.to)
	<-filterReady
	go func() {
		d := make( []byte, 1)
		for q := false; q ==false; {
			select {
			case q = <- peerQuit:

			case d[0] = <-tcpch.fromSerial:
				fp.Write(d)
				toTelnetFilter <- d[0]
			}
		}
	}()

	for q := false; q == false; {
		select {
		case q = <-tcpch.quit:

		case data := <-fromTelnetFilter:
			tcpch.toSerial <- data
		}
	}
	peerQuit <- true
	fp.Close()
	close(toTelnetFilter)
	fmt.Printf("%s Telnet Connection Closed %v <--> %v\n", time.Now().Local(), tcpch.conn.LocalAddr(),tcpch.conn.RemoteAddr())
	tcpch.conn = nil
}
//TODO: update to handle IP6
func ListenTCPall( port int) chan *TCPChannels {
	conn_chan := make( chan *TCPChannels)
	for _, s := range(GetIPs()) {
		addr := net.TCPAddr{ s, port,""}
		listener, err := net.ListenTCP("tcp", &addr)
		if err != nil {
			fmt.Printf( "\n%s Could not listen on %v:%d ERROR: %s\n\n", time.Now().Local(), s, port, err.Error())
		} else {
			fmt.Printf( "%s Listening on %v:%d\n", time.Now().Local(), s, port)
			go func( *net.TCPListener, chan *TCPChannels) {
				for{
					tcp_conn, err := listener.AcceptTCP()
					if tcp_conn == nil || err != nil {
						fmt.Printf("\n%s Could not accept connection. ERROR: %s\n\n", time.Now().Local(), err.Error())
						continue
					}
					conn_chan <- TCPConnectionChannels( tcp_conn)
				}
			}( listener, conn_chan)
		}
	}
	return conn_chan
}
//TODO: update to handle IP6
func GetIPs() []net.IP {
	x, _ := net.InterfaceAddrs()

	var addrs = make([]string, len(x) + 1)
	flag := false

	for i, xx := range x {
		ip1, _, err := net.ParseCIDR(xx.String())
		ip2 := net.ParseIP(xx.String())
		
		if err == nil && ip1 != nil && ip1.String() != "0.0.0.0" {
			addrs[i] = ip1.String()
		} else if ip2 != nil && ip2.String() != "0.0.0.0" {
			addrs[i] = ip2.String()
		}
		if addrs[i] == "127.0.0.1" {
			flag = true
		}
	}
	if !flag {
		addrs[ len(addrs)-1] = "127.0.0.1"
	}
// filter out IPv6 for now
	for i , s := range(addrs) {
		if strings.Contains(s, "::") {
			addrs[ i] = ""
		}
	}
	sort.Strings( addrs)

	var begin int
	for i, s := range(addrs) {
		if s != "" {
			begin = i
			break
		}
		
	}
	var ips = make( []net.IP, len(addrs[begin:]))
	for i , s := range( addrs[ begin:]) {
		ips[i] = net.ParseIP(s)
	}
	return ips
}

func TCPConnectionChannels(client *net.TCPConn)(*TCPChannels) {
	rc := &TCPChannels{ make(chan byte,8192), make(chan byte,8192), make( chan bool), client, nil, nil}

	peerQuit := make( chan bool)
	go func( tcpch *TCPChannels) {
		datain := make( []byte, 1000000)
		for q:= false; q == false; {
			count, err := tcpch.conn.Read( datain)
			if err != nil {
				if err.Error() != "EOF" {
					fmt.Printf( "\n\n%s Connection Read Error: %s\n\n", time.Now().Local(), err.Error())
				}
				tcpch.quit <- true
				peerQuit <- true
				q = true
			}
			din := datain[:count]
			for _,c := range(din) {
				tcpch.from <- c
			}
		}
	}(rc)

	go func(tcpch *TCPChannels) {
		dataout := make( []byte, 1000000)
		var wcount int
		var readflag bool

		for q := false; q == false ; {

			select {
			case dataout[ 0] = <- tcpch.to:
				for readflag, wcount = true, 1; readflag && wcount < 4096; wcount++ {
					select {
					case dataout[wcount] = <- tcpch.to:
					default:
						readflag = false
						wcount--
					}
				}
				dout := dataout[:wcount]

				tcpch.conn.Write( dout)

			case q = <- peerQuit:
			}
				
		}
	}(rc)

	return rc
}

