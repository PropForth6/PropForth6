package chanIp

import (
	"fmt"
	"net"
	"strconv"
	"time"
)

var MaxDataPerRead int
var MaxDataPerWrite int
var Debug bool
var LogChan chan string

var chanId int
var last time.Time

func init() {
	MaxDataPerRead = 1024
	MaxDataPerWrite = 1024
	Debug = false
	last = time.Now()
}

func elapsedTime() string {
	d := time.Since(last)
	last = time.Now()
	return fmt.Sprintf("%04d-%02d-%02d-%02d:%02d:%02d:%03d::%06d", last.Year(), last.Month(), last.Day(), last.Hour(), last.Minute(), last.Second(), last.Nanosecond()/1000000, d.Milliseconds())
}

func nextConnectDelay(delay int64) int64 {
	if delay == 0 {
		delay = 200
	} else {
		if delay < 1000 {
			delay += 200
		} else if delay < 4000 {
			delay += 500
		} else if delay < 20000 {
			delay += 2000
		}
	}
	return delay
}

func tryConnect(host string, port int) *net.TCPConn {
	rc := (*net.TCPConn)(nil)
	dest := host + ":" + strconv.Itoa(port)
	addr, err := net.ResolveTCPAddr("tcp", dest)
	if err != nil {
		if LogChan != nil {
			LogChan <- fmt.Sprintf("%s chanIp_tryConnect: Could not resolve tcp address %v %v ERROR [%s]\n", elapsedTime(), host, port, err.Error())
		}
	} else {
		if LogChan != nil {
			LogChan <- fmt.Sprintf("%s chanIp_tryConnect: Connecting to [%v]\n", elapsedTime(), dest)
		}
		connection, err := net.DialTCP("tcp", nil, addr)
		if err != nil {
			if LogChan != nil {
				LogChan <- fmt.Sprintf("%s chanIp_tryConnect: Connection failed [%v] ERROR [%s]\n", elapsedTime(), dest, err.Error())
			}
		} else {
			if LogChan != nil {
				LogChan <- fmt.Sprintf("%s chanIp_tryConnect: Connected [%v] Debug [%v]\n", elapsedTime(), dest, Debug)
			}
			rc = connection
		}
	}
	return rc
}
func Connect(host string, port int, writeChan, readChan chan []byte) {
	connectDelay := int64(0)
	for {
		ok := false
		connection := tryConnect(host, port)
		if connection != nil {
			chanId++
			rb, wb, tu := connectionLoop(connection, writeChan, readChan, chanId)
			ok = rb != 0 || wb != 0 || tu > 3
		}
		if !ok {
			connectDelay = nextConnectDelay(connectDelay)
			time.Sleep(time.Duration(connectDelay) * time.Millisecond)
		} else {
			connectDelay = 0
		}
	}
}

func connectionLoop(conn *net.TCPConn, writeChan, readChan chan []byte, chanId int) (float64, float64, float64) {
	sync := make(chan bool)
	closeChan := make(chan bool, 1)
	startTime := time.Now()
	totalBytesRead := float64(0)
	totalBytesWritten := float64(0)
	go func() {
		currentBytesWritten := float64(0)
		var inbuf []byte
		notClose := true
		for notClose {
			inbuf = []byte{}
			select {
			case inbuf = <-writeChan:
			case notClose = <-closeChan:
				notClose = false
			}
			if Debug {
				if LogChan != nil && len(inbuf) > 0 {
					LogChan <- fmt.Sprintf("%s chanIp_connectionLoop: %03d IP SEND %d bytes [%v]\n", elapsedTime(), chanId, len(inbuf), formatHex(inbuf))
				}
			}
			if notClose {
				lim := len(inbuf)
				for i := 0; i < lim; {
					writeSize, err := conn.Write(inbuf[i:lim])
					if err != nil {
						notClose = false
						break
					}
					i += writeSize
				}
				totalBytesWritten += float64(lim)
				currentBytesWritten += float64(lim)
			}
		}
		conn.Close()
		sync <- true
	}()
	buf := make([]byte, MaxDataPerRead)
	currentBytesRead := float64(0)
	for {
		bytesRead, err := conn.Read(buf)
		if err != nil {
			if LogChan != nil {
				LogChan <- fmt.Sprintf("%s chanIp_connectionLoop: %03d TCP/IP read ERROR [%s]\n", elapsedTime(), chanId, err.Error())
			}
			conn.Close()
			break
		} else if bytesRead == 0 {
			if LogChan != nil {
				LogChan <- fmt.Sprintf("%s chanIp_connectionLoop: %03d TCP/IP read got 0 bytes\n", elapsedTime(), chanId)
			}
		} else {
			totalBytesRead += float64(bytesRead)
			currentBytesRead += float64(bytesRead)
			qbuf := make([]byte, bytesRead)
			copy(qbuf, buf[0:bytesRead])
			readChan <- qbuf
			if Debug {
				if LogChan != nil {
					LogChan <- fmt.Sprintf("%s chanIp_connectionLoop: %03d IP REC %d bytes [%v]\n", elapsedTime(), chanId, len(qbuf), formatHex(qbuf))
				}
			}
		}
	}
	closeChan <- true
	<-sync
	elapsed := time.Since(startTime).Seconds()
	if LogChan != nil {
		LogChan <- fmt.Sprintf("chanIp_connectionLoop %s: %03d IP close sync read [%v] written [%v] seconds up [%v]\n", elapsedTime(), chanId, totalBytesRead, totalBytesWritten, elapsed)
	}
	return totalBytesRead, totalBytesWritten, elapsed
}

func formatHex(b []byte) string {
	s := "["
	t := "["
	for i := 0; i < len(b); i++ {
		s += fmt.Sprintf("0x%02X ", b[i])
		if b[i] >= 0x20 && b[i] <= 0x7E {
			t += fmt.Sprintf("%c", b[i])
		} else {
			t += "."
		}
		if (i % 4) == 3 {
			s += "  "
			t += " "
		}
	}
	s += "]"
	t += "]"
	return s + t
}

func tryListen(port int, writeChan, readChan chan []byte) *net.TCPConn {
	var rc *net.TCPConn
	addr := net.TCPAddr{nil, port, ""}
	ln, err := net.ListenTCP("tcp", &addr)
	defer ln.Close()
	if err != nil {
		if LogChan != nil {
			LogChan <- fmt.Sprintf("%s chanIp_tryListen: Could not listen on port [%v]  ERROR [%s]\n", elapsedTime(), port, err.Error())
		}
	} else {
		if LogChan != nil {
			LogChan <- fmt.Sprintf("%s chanIp_tryListen: Listening on [%v]\n", elapsedTime(), addr)
		}
		conn, err := ln.AcceptTCP()
		if err != nil {
			if LogChan != nil {
				LogChan <- fmt.Sprintf("%s chanIp_tryListen: Could not accept connection  ERROR [%s]\n", elapsedTime(), err.Error())
			}
		} else {
			if LogChan != nil {
				LogChan <- fmt.Sprintf("%s chanIp_tryListen: New connection [%v <--> %v]\n", elapsedTime(), conn.LocalAddr(), conn.RemoteAddr())
			}
			rc = conn
		}
	}
	return rc
}

func Listen(port int, writeChan, readChan chan []byte) {
	listenDelay := int64(0)
	connectDelay := int64(0)
	connected := make(chan bool)
	for {
		go func() {
			for flag := true; flag; {
				select {
				case <-connected:
					flag = false
				case <-time.After(time.Duration(connectDelay) * time.Millisecond):
					connectDelay = nextConnectDelay(connectDelay)
				}
			}
		}()
		ok := false
		conn := tryListen(port, writeChan, readChan)
		connected <- true
		chanId++
		if conn != nil {
			rb, wb, tu := connectionLoop(conn, writeChan, readChan, chanId)
			ok = rb != 0 || wb != 0 || tu > 3
		}
		if !ok {
			listenDelay = nextConnectDelay(listenDelay)
			time.Sleep(time.Duration(listenDelay) * time.Millisecond)
		} else {
			listenDelay = 0
		}
	}
}

func udpWrite(conn *net.UDPConn, remoteAddr *net.UDPAddr, delay time.Duration, ch chan []byte) {
	var err error
	select {
	case buf := <-ch:
		t := len(buf)
		if t > MaxDataPerWrite {
			t = MaxDataPerWrite
		}
		qbuf := make([]byte, t)
		copy(qbuf, buf[0:t])
		if remoteAddr != nil {
			_, err = conn.WriteToUDP(qbuf, remoteAddr)
		} else {
			_, err = conn.Write(qbuf)

		}
		if err != nil {
			if LogChan != nil {
				LogChan <- fmt.Sprintf("%s udpWrite: UDP write ERROR [%s]\n", elapsedTime(), err.Error())
			}
		} else {
			if Debug {
				if LogChan != nil {
					LogChan <- fmt.Sprintf("%s udpWrite: UDP SND %d bytes [%v]\n", elapsedTime(), len(qbuf), formatHex(qbuf))
				}
			}

		}
	case <-time.After(delay):
	}
}

func udpRead(conn *net.UDPConn, ch chan []byte) *net.UDPAddr {
	buf := make([]byte, MaxDataPerRead)
	bytesRead, remoteAddr, err := conn.ReadFromUDP(buf)
	if err != nil {
		if LogChan != nil {
			LogChan <- fmt.Sprintf("%s udpRead: ERROR [%s]\n", elapsedTime(), err.Error())
		}
	} else if bytesRead == 0 {
		if LogChan != nil {
			LogChan <- fmt.Sprintf("%s udpRead: ERROR got 0 bytes\n", elapsedTime())
		}
	} else {
		qbuf := make([]byte, bytesRead)
		copy(qbuf, buf[0:bytesRead])
		ch <- qbuf
		if Debug {
			if LogChan != nil {
				LogChan <- fmt.Sprintf("%s udpReadP: UDP REC %d bytes [%v]\n", elapsedTime(), len(qbuf), formatHex(qbuf))
			}
		}
	}
	return remoteAddr
}

func ListenUdp(port int, writeChan, readChan chan []byte) {
	connectDelay := int64(0)
	for {
		addr := net.UDPAddr{nil, port, ""}
		conn, err := net.ListenUDP("udp", &addr)
		if err != nil {
			if LogChan != nil {
				LogChan <- fmt.Sprintf("%s chanIp_ListenUDP: Could not listen on port [%v]  ERROR [%s]\n", elapsedTime(), port, err.Error())
			}
			connectDelay = nextConnectDelay(connectDelay)
			time.Sleep(time.Duration(connectDelay) * time.Millisecond)
		} else {
			for {
				remoteAddr := udpRead(conn, readChan)
				udpWrite(conn, remoteAddr, time.Duration(10*time.Microsecond), writeChan)
			}
		}
	}
}

func ConnectUdp(host string, port int, writeChan, readChan chan []byte) {
	connectDelay := int64(0)
	dest := host + ":" + strconv.Itoa(port)
	remoteAddr, err := net.ResolveUDPAddr("udp", dest)
	for f := true; f; {
		if err != nil {
			if LogChan != nil {
				LogChan <- fmt.Sprintf("chanIp_connectUDP %s: Could not resolve udp address %v %v ERROR [%s]\n", elapsedTime(), host, port, err.Error())
			}
			connectDelay = nextConnectDelay(connectDelay)
			time.Sleep(time.Duration(connectDelay) * time.Millisecond)
			remoteAddr, err = net.ResolveUDPAddr("udp", dest)
		} else {
			f = false
		}
	}
	conn, er2 := net.DialUDP("udp", nil, remoteAddr)
	for f := true; f; {
		if er2 != nil {
			if LogChan != nil {
				LogChan <- fmt.Sprintf("%s chanIp_connectUDP: Connection failed [%v] ERROR [%s]\n", elapsedTime(), dest, er2.Error())
			}
			connectDelay = nextConnectDelay(connectDelay)
			time.Sleep(time.Duration(connectDelay) * time.Millisecond)
			conn, er2 = net.DialUDP("udp", nil, remoteAddr)
		} else {
			f = false
		}
	}
	go func() {
		for {
			_ = udpRead(conn, readChan)
		}
	}()

	for {
		udpWrite(conn, nil, time.Duration(10*time.Microsecond), writeChan)
	}
}
