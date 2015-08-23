package serafcFilter
// This package provides a protocol filter for the serafc driver.
// The basics are - it is assumed the other side has a 511 byte buffer,
// and an ack will be sent every 256 bytes. Binary bytes are ok, the filter will
// encode decode them.
//
// Flow Protocol
// 0x01 - ack - 256 bytes received and out of the buffer
// 0x02 - restart - the driver has restarted
// 0x03 - escape - the next byte should be anded with 0x7F 
//
//
//

import (
	"fmt"
	"time"
)

func ProtocolFilter( fromSer chan byte, toSer chan byte, conLog chan string, debug bool ) (chan byte, chan byte) {
	peerQuit := make(chan bool)
	bufCtl := make(chan byte, 3)
	fromProtocol := make( chan byte, 500000)
	toProtocol := make( chan byte, 500000)

	go func() {
		bufAvailable := 511
		for q := false; q == false; {
			if bufAvailable > 0 {
				select {
				case c := <-bufCtl:
					switch c {
					case 0x01:
						bufAvailable += 256
						if debug {
							conLog <- fmt.Sprintf("  %s bufACK  Avail %d\n",time.Now().Local(), bufAvailable)
						}
					case 0x02:
						bufAvailable = 511
						if debug {
							conLog <- fmt.Sprintf("  %s Driver restart\n",time.Now().Local())
						}
					}

				case d := <-toProtocol:
					if d >= 0x0 && d <= 0x03 {
						toSer <- 0x03
						toSer <- 0x80 | d
					} else {
						toSer<- d
					}
					bufAvailable--
				}
			} else {
				if debug {
					conLog <- fmt.Sprintf("  %s Waiting for bufACK  Avail %d\n",time.Now().Local(), bufAvailable)
				}
				switch <- bufCtl {
				case 0x01:
					bufAvailable += 256
					if debug {
						conLog <- fmt.Sprintf("  %s bufACK  Avail %d\n",time.Now().Local(), bufAvailable)
					}
				case 0x02:
					bufAvailable = 511
					if debug {
						conLog <- fmt.Sprintf("  %s Driver restart\n",time.Now().Local())
					}
				}
			}
		}
		peerQuit<- true
	}()
	go func() {
		bytesRec := 0
		mask := byte(0xFF)
		toSer <- 0x02
		for q := false; q == false; {
			select {
			case q = <-peerQuit:
			case data := <-fromSer:
				if data == 0x01 {
					bufCtl <-data
				} else if data == 0x02  {
					bytesRec = 0
					mask = 0xFF
					bufCtl <-data
				} else if data == 0x03  {
					mask = 0x7F
				} else {
					fromProtocol <- data & mask
					bytesRec++
					mask = 0xFF
					if bytesRec >= 256 {
						bytesRec = 0
						toSer <- 0x01
						if debug {
							conLog <- fmt.Sprintf("  %s Sending ACK\n",time.Now().Local())
						}
					}
				}
			}
		}
	}()
	return fromProtocol, toProtocol
}

