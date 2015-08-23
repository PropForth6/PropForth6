package main

import (
	"cogCommandProcessor"
	"fmt"
	"io"
	"net"
	"os"
	"runtime"
	"serial"
	"serafcFilter"
	"strconv"
	"time"
)

var debug int = 0

func main() {
	var err error
	var baud, cmdIndex int
	var chanFromSerial, chanToSerial chan byte
	var chanFromSer, chanToSer chan byte
	var chanDTRSerial, chanQuitSerial, chanQuitTcp chan bool
	var conn *net.TCPConn
	var tcpaddr *net.TCPAddr

	runtime.GOMAXPROCS(runtime.NumCPU())
//	runtime.GOMAXPROCS(1)

	cp := new( cogCommandProcessor.CogCommandProcessor)
	cp.SetReceiveTimeout( time.Duration(3e9))
	cp.SetCps( 20000)


	if len(os.Args) > 1 {
		tcpaddr, err = net.ResolveTCPAddr( "tcp", os.Args[1])
		if err == nil {
			conn,err = net.DialTCP( "tcp", nil, tcpaddr)
			if err == nil {
				chanFromSerial, chanToSerial, chanQuitTcp = cp.TcpChan( conn)
			}
		}
		cmdIndex = 2
	}


	conLog := make( chan string)
	go func() {
		for s := range  conLog {
			fmt.Print( s)
		}
	}()


	if chanFromSerial == nil && len(os.Args) > 3 {
		b, errc := strconv.ParseInt( os.Args[2], 10, 32)
		err = errc
		baud = int( b)
		fc := int(0)
		if err == nil {
			f, errd := strconv.ParseInt( os.Args[3], 10, 32)
			err = errd
			fc = int( f)
			if fc&6 != 0 {
				debug = fc
			}
		}
		if err == nil {
			chanFromSer, chanToSer, chanDTRSerial, chanQuitSerial, err = serial.SerialChannels( os.Args[1], baud, conLog, debug&2 != 0)
			if fc != 0 {
				chanFromSerial, chanToSerial = serafcFilter.ProtocolFilter( chanFromSer, chanToSer, conLog, debug&4 !=0)
			} else {
				chanFromSerial, chanToSerial = chanFromSer, chanToSer
			}
			cmdIndex = 4
		}
	}


	if err != nil || chanFromSerial == nil {
		fmt.Printf( "error: %s\nusage: %s [ipaddr:port | com_port baud flowcontrol[0|1]] [commands]*\n%s", err, os.Args[0], cogCommandProcessor.Help)
		return
	}
	
	var sName string
	if len(os.Args) > cmdIndex {
		sName = "LINE COMMANDS"
	} else {
		sName = "USER INPUT"
	}

	time.Sleep( cp.GetReceiveTimeout())

	chanCommand := cp.CommandProcessor( sName, chanFromSerial, chanToSerial, chanDTRSerial, conLog)

	if len(os.Args) > cmdIndex {
		for _,s := range( os.Args[cmdIndex:]) {
			fmt.Println( s)
			for _,c := range( s) {
				chanCommand <- byte(c)
			}
			chanCommand <- byte(0x20)
		} 
		chanCommand <- byte( 0x0D)
		chanCommand <- byte( 0x0D)
		close(chanCommand)
		time.Sleep( cp.GetReceiveTimeout())
	} else {

		chanCommand <- byte( 'h')
		chanCommand <- byte( 0x0D)
		d := make( []byte, 2048)
		for {
			c, e := os.Stdin.Read( d)
			for _,ch := range( d[:c]) {
				if ch == byte(0x0A) {
					ch = byte(0x0D)
				}
				chanCommand <- ch
				if ch == byte(0x0D) {
					break
				}
			}
			time.Sleep( 10)

			if chanQuitTcp != nil {
				select {
				case <- chanQuitTcp:
					e = io.EOF
				default:
				}
			}

			if e == io.EOF {
				break
			}
		}
	}
	if chanQuitSerial != nil {
		chanQuitSerial <- true
	}
	if chanQuitTcp != nil {
		
	}
	time.Sleep( cp.GetReceiveTimeout())
	close( conLog)
}
