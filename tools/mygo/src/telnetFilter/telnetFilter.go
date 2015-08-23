package telnetFilter
// This package provides a filter for the telnet protocol.
// It assumes the server will echo, and go ahead (flow control) is suppressed
//
//

/*
Telnet control
FF - IAC
FE - DONT
FD - DO
FC - WONT
FB - WILL
01 - ECHO
03 - Suppress goahead

Telnet sends either 0x0d 0x0a or 0x0d 0x00 - in both cases send only 0x0d

*/


func TelnetFilters( from chan byte, to chan byte) (chan byte, chan byte, chan bool) {
	peerQuit := make(chan bool)
	ready := make( chan bool)
	fromTelnetFilter := make( chan byte, 4096)
	toTelnetFilter := make( chan byte, 4096)

	go func() {
		for d := range( toTelnetFilter) {
			to<- d
		}
		peerQuit<- true
	}()

	go func() {
		to <- 0xFF
		to <- 0xFB
		to <- 0x01
		to <- 0xFF
		to <- 0xFB
		to <- 0x03
		ready<- true
		for q := false; q == false; {
			select {
			case q = <-peerQuit:
			case data := <- from:
				if data == 0xFF {
					data1 := byte(0)
					data2 := byte(0)
					select {
					case data1 = <- from:
					case q = <-peerQuit:
					}
					select {
					case data2 = <- from:
					case q = <-peerQuit:
					}
					if data1 == 0xFB && data2 == 0x03 {
						data1 = 0xFD
					} else if data1 == 0xFD && data2 == 0x03 {
						data1 =0xFB
					} else if data1 == 0xFD && data2 == 0x01 {
						data1 =0xFB
					} else if data1 == 0xFC {
						data1 = 0xFE
					} else if data1 == 0xFE {
						data1 = 0xFC
					} else {
						data = 0
					}
					if data == 0xFF {
						to <- data
						to <- data1
						to <- data2
					}
				} else if data == 0x0D  {
					fromTelnetFilter <- data
					data1 := byte(0)
					select {
					case data1 = <- from:
					case q = <-peerQuit:
					}
					if data1 != 0x00 && data1 != 0x0A {
						fromTelnetFilter <- data1
					}
				} else {
					fromTelnetFilter <- data
				}
			}
		}
	}()
	return fromTelnetFilter, toTelnetFilter, ready
}
