// +build linux darwin

package serial
//
//TODO: update to use conlog, windows version is up to data 2013-12-29
//

// Serial io as raw as possible. 8 bits, no parity 1 stop bit, channel to provide DTR control
//
// comName := "/dev/ttyS1" 
// baudRate := 57600
// debug := false
//
// chanFromSerial, chanToSerial, charDTRSerial, chanQuitSerial, err := SerialChannels( comName, baud, debug)
//
// chanFromSerial = byte data channel from serial
// chanToSerial - byte data channel to serial 
// chanDTRSerial - bool channel to comtrol DTR - logical 1 means DTR active - rs232 level - +3-+15 volts 
// chanQuitSerial - send a bit on this channel to terminate
//
// based on http://code.google.com/p/goserial/
//
// Works with go version 1, tested on Ubuntu 12.04 (64-bit) running on VMworkstation

// #include <termios.h>
// #include <unistd.h>
// #include <sys/ioctl.h>
// #include <fcntl.h>
import "C"

import (
	"errors"
	"fmt"
	"os"
	"syscall"
	"time"
	"unsafe"
)


//
// This was necessary to ensure the serial driver behaves correctly in VirtualBox
//
var SendBlocksize int = 256
var EnableSendBlockDelay bool = false

func SerialChannels( name string, baud int, conLog chan string, debug bool) (chan byte, chan byte, chan bool, chan bool, error) {
	var err error
	var serFile *os.File
	var chFromSerial, chToSerial chan byte
	var chDTRSerial, chQuitSerial chan bool	

	serFile, err = os.OpenFile(name, os.O_RDWR | syscall.O_NOCTTY, 0666)
	if  err == nil {
		fd := C.int(serFile.Fd())
		var st C.struct_termios

		_, err = C.tcgetattr(fd, &st)
		if err == nil {
			if C.isatty(fd) != 1 {
				err = errors.New( "Not a tty")
			}
		}
		
		var speed C.speed_t

		if err == nil {
			switch baud {
			case 230400:
				speed = C.B230400
			case 115200:
				speed = C.B115200
			case 57600:
				speed = C.B57600

			case 19200:
				speed = C.B19200
				
			case 9600:
				speed = C.B9600
				
			default:
				err = errors.New("Invalid baud rate")
			}
		}

		if err == nil {
			_, err = C.cfsetispeed(&st, speed)
			if err == nil {
				_, err = C.cfsetospeed(&st, speed)
			}
		}
	
		if err == nil {
			C.cfmakeraw(&st)
			_, err = C.tcsetattr(fd, C.TCSANOW, &st)
		}

		if err == nil {
			chFromSerial = make( chan byte, 8192)
			chQuitFrom := make( chan bool)
			go func() {
				then := time.Now()
				datain := make( []byte, 8192)
				for q := false; q == false; {
					count, _ := serFile.Read( datain)
					
					din := datain[:count]
	
					if debug && len(din) > 0 {
						now := time.Now()
						ds1 := fmt.Sprintf("(%v(%d)", now.Sub(then), len(din))
						then = now
						for _, c := range( din) {
							if c < byte(0x20) || c > byte(0x7E) {
								ds1 += fmt.Sprintf("{%02X}",c)
							} else {
								ds1 += fmt.Sprintf("%c", c)
							}
						}
						conLog <- ds1+")\n"
					}
					for _, c := range( din) {
						chFromSerial <- c
					}
					select {
					case q = <-chQuitFrom:
					default:
					}
					time.Sleep(10)
				}
			}()
			
			chToSerial = make( chan byte, 8192)
			chQuitTo := make( chan bool)
			go func() {
				/*
				
				dataout := make( []byte, 1)
				for q := false; q == false; {
					dataout[ 0] = <- chToSerial
					if debug {
						if dataout[0] == byte(0x0D) {
							fmt.Print("[\n]")
						} else {
							fmt.Printf("[%c]", dataout[0])
						}
					}
					scount, serr := serFile.Write( dataout)
					if scount != 1 || serr != nil {
						conLog <- fmt.Sprintf( "SERIAL ERROR: write error [%d][%s]\n", scount, serr)
					}
				}
				*/
				dataout := make( []byte, SendBlocksize)
				var charDelay float64 = float64(10e9)/float64(baud) 
				var wcount int
				var readflag bool
				then := time.Now()
				for q := false; q == false; {
					select {
					case q = <- chQuitTo:
						
					case dataout[ 0] = <- chToSerial:
						for readflag, wcount = true, 1; readflag && wcount < SendBlocksize; wcount++ {
							select {                                      
							case dataout[wcount] = <- chToSerial:
							default:
								readflag = false
								wcount--
							}
						}
	
						dout := dataout[:wcount]
						
						if debug {
							now := time.Now()
							ds1 := fmt.Sprintf("\t[%v[%d]",now.Sub(then), len(dout))
							then = now
							for _, c := range( dout) {
								if c < byte(0x20) || c > byte(0x7E) {
									ds1 += fmt.Sprintf("{%02X}",c)
								} else {
									ds1 += fmt.Sprintf("%c", c)
								}
							}
							conLog <- ds1+"]\n"
						}
	
						scount, serr := serFile.Write( dout)
						if scount != len(dout) || serr != nil {
							conLog <- fmt.Sprintf( "SERIAL ERROR: write error [%d][%s]\n", scount, serr)
						}
//
// It appears the drivers can overrun buffers in the serial USB devices, this ensure we never send data faster than the device
// can transmit it
//
						if EnableSendBlockDelay {
							delay := int(charDelay * float64(wcount))
							time.Sleep(time.Duration(delay))
						}
					}
				}
				
				
				
			}()

			chDTRSerial = make( chan bool)
			chQuitDTR := make( chan bool)
			go func() {
				var param uint
				var ep syscall.Errno
				for q := false; q == false; {
					select {
					case q = <- chQuitDTR:
					case dtr := <-chDTRSerial:
						param = syscall.TIOCM_DTR
						if dtr {
							_, _, ep = syscall.Syscall(syscall.SYS_IOCTL, uintptr(fd), syscall.TIOCMBIS, uintptr(unsafe.Pointer(&param)))
						} else {
							_, _, ep = syscall.Syscall(syscall.SYS_IOCTL, uintptr(fd), syscall.TIOCMBIC, uintptr(unsafe.Pointer(&param)))
						}
						if ep != 0 {
							conLog <- fmt.Sprintf( "SERIAL ERROR: DTR  error [%d]\n", ep)
						}
					
					}
				}
			}()

			go func() {
				<- chQuitSerial
				serFile.Close()
				chQuitFrom <- true
				chQuitTo <- true
				chQuitDTR <- true
			}()

		}
	}

	return chFromSerial, chToSerial, chDTRSerial, chQuitSerial, err
}

