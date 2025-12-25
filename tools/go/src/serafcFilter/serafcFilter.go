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

var Debug bool
var LogChan chan string
var BufSize int

func init() {
	BufSize = 512
}

func chanArrayToByte(array chan []byte, out chan byte) {
	go func() {
		for {
			t := <-array
			if len(t) > 0 {
				for i := 0; i < len(t); i++ {
					out <- t[i]
				}
			}
		}
	}()
}
func chanByteToArray(in chan byte, out chan []byte) {
	go func() {
		for {
			t := <-in
			le := len(in)
			aout := make([]byte, le+1)
			aout[0] = t
			for i := 0; i < le; i++ {
				aout[i+1] = <-in
			}
			out <- aout
		}
	}()
}

func AfcFilter(fromPhy, toPhy, fromAfc, toAfc chan []byte) {
	bufCtl := make(chan byte, 3)
	toPhyByte := make(chan byte, 2*BufSize)
	toAfcByte := make(chan byte, 2*BufSize)
	chanArrayToByte(toAfc, toAfcByte)
	chanByteToArray(toPhyByte, toPhy)
	fromPhyByte := make(chan byte, 2*BufSize)
	fromAfcByte := make(chan byte, 2*BufSize)
	chanArrayToByte(fromPhy, fromPhyByte)
	chanByteToArray(fromAfcByte, fromAfc)

	go func() {
		bufAvailable := (BufSize - 1)
		for {
			if bufAvailable > 0 {
				select {
				case c := <-bufCtl:
					switch c {
					case 0x01:
						bufAvailable += (BufSize / 2)
						if bufAvailable > (BufSize - 1) {
							bufAvailable = (BufSize - 1)
						}
						if Debug && LogChan != nil {
							LogChan <- fmt.Sprintf("serafc %s bufACK  Avail %d\n", time.Now().Local(), bufAvailable)
						}
					case 0x02:
						bufAvailable = (BufSize - 1)
						if Debug && LogChan != nil {
							LogChan <- fmt.Sprintf("serafc %s Driver restart\n", time.Now().Local())
						}
					}

				case d := <-toAfcByte:
					if d == 0x03 || d == 0x02 || d == 0x01 {
						toPhyByte <- 0x03
						toPhyByte <- 0x80 | d
					} else {
						toPhyByte <- d
					}
					bufAvailable--
				}
			} else {
				if Debug && LogChan != nil {
					LogChan <- fmt.Sprintf("serafc %s Waiting for bufACK  Avail %d\n", time.Now().Local(), bufAvailable)
				}
				switch <-bufCtl {
				case 0x01:
					bufAvailable += (BufSize / 2)
					if bufAvailable > (BufSize - 1) {
						bufAvailable = (BufSize - 1)
					}
					if Debug && LogChan != nil {
						LogChan <- fmt.Sprintf("serafc %s bufACK  Avail %d\n", time.Now().Local(), bufAvailable)
					}
				case 0x02:
					bufAvailable = (BufSize - 1)
					if Debug && LogChan != nil {
						LogChan <- fmt.Sprintf("serafc %s Driver restart\n", time.Now().Local())
					}
				}
			}
		}
	}()
	go func() {
		bytesRec := 0
		mask := byte(0xFF)
		toPhyByte <- 0x02
		for {
			data := <-fromPhyByte
			if Debug && LogChan != nil {
				LogChan <- fmt.Sprintf("serafc bytesRec: %d data %02X\n", bytesRec, data)
			}
			if data == 0x01 {
				bufCtl <- data
			} else if data == 0x02 {
				bytesRec = 0
				mask = 0xFF
				bufCtl <- data
			} else if data == 0x03 {
				mask = 0x7F
			} else {
				fromAfcByte <- data & mask
				bytesRec++
				mask = 0xFF
				if bytesRec >= (BufSize / 2) {
					bytesRec = 0
					toPhyByte <- 0x01
					if Debug && LogChan != nil {
						LogChan <- fmt.Sprintf("serafc %s Sending ACK\n", time.Now().Local())
					}
				}
			}
		}
	}()
}

func ProtocolFilter(fromSer, toSer chan byte) (chan byte, chan byte) {
	peerQuit := make(chan bool)
	bufCtl := make(chan byte, 3)
	fromProtocol := make(chan byte, 1000)
	toProtocol := make(chan byte, 1000)

	go func() {
		bufAvailable := 511
		for q := false; !q; {
			if bufAvailable > 0 {
				select {
				case c := <-bufCtl:
					switch c {
					case 0x01:
						bufAvailable += 256
						if Debug && LogChan != nil {
							LogChan <- fmt.Sprintf("  %s bufACK  Avail %d\n", time.Now().Local(), bufAvailable)
						}
					case 0x02:
						bufAvailable = 511
						if Debug && LogChan != nil {
							LogChan <- fmt.Sprintf("  %s Driver restart\n", time.Now().Local())
						}
					}

				case d := <-toProtocol:
					if d == 0x03 || d == 0x02 || d == 0x01 {
						toSer <- 0x03
						toSer <- 0x80 | d
					} else {
						toSer <- d
					}
					bufAvailable--
				}
			} else {
				if Debug && LogChan != nil {
					LogChan <- fmt.Sprintf("  %s Waiting for bufACK  Avail %d\n", time.Now().Local(), bufAvailable)
				}
				switch <-bufCtl {
				case 0x01:
					bufAvailable += 256
					if Debug && LogChan != nil {
						LogChan <- fmt.Sprintf("  %s bufACK  Avail %d\n", time.Now().Local(), bufAvailable)
					}
				case 0x02:
					bufAvailable = 511
					if Debug && LogChan != nil {
						LogChan <- fmt.Sprintf("  %s Driver restart\n", time.Now().Local())
					}
				}
			}
		}
		peerQuit <- true
	}()
	go func() {
		bytesRec := 0
		mask := byte(0xFF)
		toSer <- 0x02
		for q := false; !q; {
			select {
			case q = <-peerQuit:
			case data := <-fromSer:
				if Debug && LogChan != nil {
					LogChan <- fmt.Sprintf("\n  bytesRec: %d data %02X\n", bytesRec, data)
				}
				if data == 0x01 {
					bufCtl <- data
				} else if data == 0x02 {
					bytesRec = 0
					mask = 0xFF
					bufCtl <- data
				} else if data == 0x03 {
					mask = 0x7F
				} else {
					fromProtocol <- data & mask
					bytesRec++
					mask = 0xFF
					if bytesRec >= 256 {
						bytesRec = 0
						toSer <- 0x01
						if Debug && LogChan != nil {
							LogChan <- fmt.Sprintf("  %s Sending ACK\n", time.Now().Local())
						}
					}
				}
			}
		}
	}()
	return fromProtocol, toProtocol
}
