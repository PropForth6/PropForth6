package main

import (
	"fmt"
	"sync"
	"time"

	"salsanci.com/propforth/src/chanIp"
	"salsanci.com/propforth/src/xboxcontroller"
)

func ncrc(old_crc int16, Data int8) int16 {
	var x int16
	x = ((old_crc >> 8) ^ int16(Data)) & 0xFF
	x ^= x >> 4
	return (old_crc << 8) ^ (x << 12) ^ (x << 5) ^ x
}

func calcCrc(b []byte) uint16 {
	crc := int16(-1)
	for _, v := range b {
		crc = ncrc(crc, int8(v))
	}
	return uint16(crc)
}

func xboxc(cout chan []byte, xBoxControllerDebug bool) {
	c := xboxcontroller.Start()
	lc := uint8(0)

	for {
		s := time.Now()
		t := <-c
		d := time.Since(s)
		outB := make([]byte, 14)
		m := ""
		if len(t) == 1 {
			m = fmt.Sprintf("XBC ERROR %9d %v  %04X\n", d, lc, t[0])
			outB[0] = byte(0xAA)
			outB[1] = byte(lc)
			outB[2] = byte(t[0])
			outB[3] = byte(t[0] >> 8)
		} else if len(t) == 2 {
			m = fmt.Sprintf("XBC ERROR %9d %v %04X %04X\n", d, lc, t[0], t[1])
			outB[0] = byte(0xAA)
			outB[1] = byte(lc)
			outB[2] = byte(t[0])
			outB[3] = byte(t[0] >> 8)
			outB[4] = byte(t[1])
			outB[5] = byte(t[1] >> 8)
		} else if len(t) == 3 {
			m = fmt.Sprintf("XBC ERROR %9d %v %04X %04X %04X\n", lc, d, t[0], t[1], t[2])
			outB[0] = byte(0xAA)
			outB[1] = byte(lc)
			outB[2] = byte(t[0])
			outB[3] = byte(t[0] >> 8)
			outB[4] = byte(t[1])
			outB[5] = byte(t[1] >> 8)
			outB[6] = byte(t[2])
			outB[7] = byte(t[2] >> 8)
		} else {
			m = fmt.Sprintf("XBC OK %9d %v %v\n", lc, d, t)
			outB[0] = byte(0x55)
			outB[1] = byte(lc)
			outB[2] = byte(t[0])
			outB[3] = byte(t[0] >> 8)
			outB[4] = byte(t[1])
			outB[5] = byte(t[1] >> 8)
			outB[6] = byte(t[2])
			outB[7] = byte(t[2] >> 8)
			outB[8] = byte(t[3])
			outB[9] = byte(t[3] >> 8)
			outB[10] = byte(t[4])
			outB[11] = byte(t[4] >> 8)
			outB[12] = byte(t[5])
			outB[13] = byte(t[5] >> 8)
		}
		if cap(cout) > len(cout) {
			cout <- outB
		}
		if xBoxControllerDebug {
			toConsole <- m
		}
		lc++
	}
}

func multiplexor(fromHost, toHost, muxFromHost, muxToHost chan []byte, errChan chan string, numMux, muxPort int, muxHost string, crc bool, xbox, xboxDebug bool) {
	var xboxChan chan []byte
	if xbox {
		xboxChan = make(chan []byte, 10)
		go xboxc(xboxChan, xboxDebug)
	}
	if numMux <= 1 {
		numMux = 2
	}
	chanToHost := make([]chan []byte, numMux)
	chanFromHost := make([]chan []byte, numMux)
	chanFromHost[0] = fromHost
	if xbox {
		chanToHost[0] = xboxChan
		go func() {
			for {
				<-toHost
			}
		}()
	} else {
		chanToHost[0] = toHost
	}
	for i := 1; i < numMux; i++ {
		chanToHost[i] = make(chan []byte, 2)
		chanFromHost[i] = make(chan []byte, 1)
	}
	if muxHost != "" {
		for i := 1; i < numMux; i++ {
			go chanIp.Connect(muxHost, muxPort+i-1, chanFromHost[i], chanToHost[i])
		}
	} else {
		for i := 1; i < numMux; i++ {
			go chanIp.Listen(muxPort+i-1, chanFromHost[i], chanToHost[i])
		}
	}
	for i := byte(0); i < byte(numMux); i++ {
		go muxOutToHost(i, muxToHost, chanToHost[i], crc)
	}

	mfh := make(chan byte, 1024)
	go chanArrayToByte(muxFromHost, mfh)
	for {
		t := <-mfh
		idx := (t & byte(0xF0)) >> 4
		nb := t & byte(0xF)
		if t == byte(0) {
			errChan <- "Zero received from host"
		} else {
			if idx >= byte(len(chanFromHost)) {
				errChan <- fmt.Sprintf("Bad channel index [%d] received from host", idx)
			} else {
				if nb == 0 || (crc && (nb < 2)) {
					errChan <- fmt.Sprintf("Bad packet length [%d] received from host", nb)
				} else {
					nb++
					buf := make([]byte, nb)
					buf[0] = t
					for i := byte(1); i < nb; i++ {
						buf[i] = <-mfh
					}
					if crc {
						nb = nb - 2
						xcrc := calcCrc(buf[:nb])
						pcrc := getUint16(buf[nb:])
						if pcrc != xcrc {
							errChan <- fmt.Sprintf("Bad crc received from host [%04X], expected [%04X]", pcrc, xcrc)
						}
					}
					buf = buf[1:nb]
					select {
					case chanFromHost[idx] <- buf:
					case <-time.After(time.Duration(10) * time.Millisecond):
						//fmt.Printf("idx: %d discard buf: %v\n", idx, buf)
					}
				}
			}
		}
	}
}

func getUint16(b []byte) uint16 {
	return uint16(b[0]) + (uint16(b[1]) << 8)
}
func putUint16(v uint16) []byte {
	return []byte{byte(v), byte(v >> 8)}
}

func chanArrayToByte(array chan []byte, out chan byte) {
	for {
		t := <-array
		for i := 0; i < len(t); i++ {
			out <- t[i]
		}
	}
}

func muxOutToHost(index byte, muxToHost, chanFromHost chan []byte, crc bool) {
	var o []byte
	for {
		fc := <-chanFromHost
		for f := true; f && len(fc) < 2000; {
			select {
			case t := <-chanFromHost:
				fc = append(fc, t...)
			default:
				f = false
			}
		}
		if !crc {
			olen := len(fc) + (len(fc) / 15)
			if len(fc)%15 != 0 {
				olen++
			}
			o = make([]byte, olen)
			dst := 0
			n := 0
			for i := 0; i < len(fc); i += n {
				n = len(fc) - i
				if n >= 15 {
					n = 15
				}
				if n > 0 {
					o[dst] = byte(n) | (index << 4)
					dst++
					copy(o[dst:dst+n], fc[i:i+n])
					dst += n
				}
			}
		} else {
			// when using crc packet length includes the crc, crc include 1st bute which is packet channel / packet length
			olen := len(fc) + ((len(fc) / 13) * 3)
			if len(fc)%13 != 0 {
				olen += 3
			}
			o = make([]byte, olen)
			dst := 0
			n := 0
			for i := 0; i < len(fc); i += n {
				n = len(fc) - i
				if n >= 13 {
					n = 13
				}
				if n > 0 {
					st := dst
					o[dst] = byte(n+2) | (index << 4)
					dst++
					copy(o[dst:dst+n], fc[i:i+n])
					dst += n
					crc := calcCrc(o[st : st+n+1])
					crcb := putUint16(crc)
					copy(o[dst:dst+2], crcb)
					dst += 2
				}
			}
		}
		muxToHost <- o
	}
}

const MAX_MUX_PACKET_SIZE = 1024
const MUX_SYNCH_1 = 0xFE
const MUX_SYNCH_2 = 0xE7
const MUX_CONTROL_CHANNEL = 0xF
const MAX_MUX_CHAN = 0x10
const CONTROL_PACKET_SIZE = ((MAX_MUX_CHAN + 1) * 2)

var controlIn []uint16
var controlInMin []uint16
var controlInMax []uint16
var controlOut []uint16
var lastControlOut []uint16
var controlInMutex, controlOutMutex sync.Mutex

var numOver, numControl, minBufSize, maxBufSize int

func aeq(a, b []uint16) bool {
	if len(a) != len(b) {
		return false
	}
	for i, v := range a {
		if v != b[i] {
			return false
		}
	}
	return true
}

func fastMultiplexor(fromHost, toHost, muxFromHost, muxToHost chan []byte, errChan chan string, numMux, muxPort int, muxHost string, xbox, xboxDebug bool) {
	var xboxChan chan []byte

	if xbox {
		xboxChan = make(chan []byte, 10)
		go xboxc(xboxChan, xboxDebug)
	}
	if numMux <= 1 {
		go func() {
			for {
				t := <-toHost
				muxToHost <- t
			}
		}()
		for {
			t := <-muxFromHost
			fromHost <- t
		}
	} else {
		controlIn = make([]uint16, 17)
		controlInMin = make([]uint16, 17)
		controlInMax = make([]uint16, 17)
		controlOut = make([]uint16, 17)
		lastControlOut = make([]uint16, 17)

		for i := 0; i < MAX_MUX_CHAN+1; i++ {
			controlInMin[i] = 0xFFFF
		}
		minBufSize = 0xFFFFFFFF
		chanToHost := make([]chan []byte, 16)
		chanFromHost := make([]chan []byte, 16)
		chanFromHost[0] = fromHost
		if xbox {
			chanToHost[0] = xboxChan
			go func() {
				for {
					<-toHost
				}
			}()
		} else {
			chanToHost[0] = toHost
		}
		for i := 1; i < 16; i++ {
			chanToHost[i] = make(chan []byte, 5)
			chanFromHost[i] = make(chan []byte, 5)
		}

		if muxHost != "" {
			for i := 1; i < numMux; i++ {
				go chanIp.Connect(muxHost, muxPort+i-1, chanFromHost[i], chanToHost[i])
			}
		} else {
			for i := 1; i < numMux; i++ {
				go chanIp.Listen(muxPort+i-1, chanFromHost[i], chanToHost[i])
			}
		}

		fromMux := make(chan []byte)
		go fastOutBuf(muxToHost, fromMux)
		for i := byte(0); i < byte(16); i++ {
			go fastMuxOutToHost(i, fromMux, chanToHost[i])
		}
		chanToHost[MUX_CONTROL_CHANNEL] = make(chan []byte, 2)
		chanFromHost[MUX_CONTROL_CHANNEL] = make(chan []byte, 2)

		go muxControlIn(chanFromHost[MUX_CONTROL_CHANNEL])
		go muxControlOut(chanToHost[MUX_CONTROL_CHANNEL])

		go func() {
			b := make([]uint16, MAX_MUX_CHAN+1)
			c := make([]uint16, MAX_MUX_CHAN+1)
			for {
				time.Sleep(time.Second)
				controlInMutex.Lock()
				copy(b, controlIn)
				controlInMutex.Unlock()
				if !aeq(b, c) {
					copy(c, b)
					fmt.Printf("%d %d %d %d [%v][%d][%v]\n", minBufSize, maxBufSize, numControl, numOver, controlInMin, controlInMax, c)
					numControl = 0
					numOver = 0
					minBufSize = 0xFFFFFFFF
					maxBufSize = 0
				}
			}
		}()

		mfh := make(chan byte, 2*MAX_MUX_PACKET_SIZE)
		go chanArrayToByte(muxFromHost, mfh)
		for {
			s1 := <-mfh
			s2 := <-mfh
			t1 := <-mfh
			t2 := <-mfh
			u := uint16(t1) | (uint16(t2) << 8)
			idx := byte(u & 0xF)
			nb := u >> 4

			if s1 == MUX_SYNCH_1 && s2 == MUX_SYNCH_2 && (idx < byte(numMux) || idx == byte(MUX_CONTROL_CHANNEL)) && nb > 0 && nb <= MAX_MUX_PACKET_SIZE {
				buf := make([]byte, nb)
				for i := uint16(0); i < nb; i++ {
					buf[i] = <-mfh
				}
				select {
				case chanFromHost[idx] <- buf:
				case <-time.After(time.Millisecond):
					errChan <- fmt.Sprintf("packet to channel %d dropped ", idx)
				}
			} else {
				errChan <- fmt.Sprintf("bad packet header from host: chan: %d len: %d header:0x%02X 0x%02X 0x%02X 0x%02X", idx, nb, s1, s2, t1, t2)
				for flag := true; flag; {
					select {
					case <-mfh:
					default:
						flag = false
					}
				}
			}
		}
	}
}

func muxControlOut(c chan []byte) {
}

func muxControlIn(c chan []byte) {
	for {
		buf := <-c
		for flag := true; flag; {
			select {
			case buf = <-c:
				numOver++
			default:
				flag = false
			}
		}

		numControl++
		if len(buf) == CONTROL_PACKET_SIZE {
			b := make([]uint16, MAX_MUX_CHAN+1)
			for i := 0; i < MAX_MUX_CHAN+1; i++ {
				b[i] = getUint16(buf[i*2:])
				if b[i] != 0 {
					if b[i] < controlInMin[i] {
						controlInMin[i] = b[i]
					}
					if b[i] > controlInMax[i] {
						controlInMax[i] = b[i]
					}
				}
			}
			controlInMutex.Lock()
			copy(controlIn, b)
			controlInMutex.Unlock()
		}
	}
}

func fastMuxOutToHost(index byte, muxToHost, chanFromHost chan []byte) {
	var o []byte
	for {
		fc := <-chanFromHost
		for f := true; f && len(fc) < MAX_MUX_PACKET_SIZE; {
			select {
			case t := <-chanFromHost:
				fc = append(fc, t...)
			default:
				f = false
			}
		}
		olen := len(fc) + 4*(len(fc)/MAX_MUX_PACKET_SIZE)
		if len(fc)%MAX_MUX_PACKET_SIZE != 0 {
			olen += 4
		}
		o = make([]byte, olen)
		dst := 0
		n := 0
		for i := 0; i < len(fc); i += n {
			n = len(fc) - i
			if n >= MAX_MUX_PACKET_SIZE {
				n = MAX_MUX_PACKET_SIZE
			}
			if n > 0 {
				o[dst] = byte(MUX_SYNCH_1)
				dst++
				o[dst] = byte(MUX_SYNCH_2)
				dst++
				u := uint16(index&0xF) | uint16(n<<4)
				o[dst] = byte(u)
				dst++
				o[dst] = byte(u >> 8)
				dst++
				copy(o[dst:dst+n], fc[i:i+n])
				dst += n
			}
		}
		if olen > 0 {
			b := make([]byte, olen)
			copy(b, o)
			muxToHost <- b
		}
	}
}

func fastOutBuf(toHost, fromMux chan []byte) {
	for {
		inbuf := <-fromMux
		for i := 0; i < len(inbuf); {
			cl := len(inbuf[i:])
			if cl > 1024 {
				cl = 1024
			}
			buf := inbuf[i : i+cl]
			i += cl
			if len(buf) > 0 {
				if len(buf) < minBufSize {
					minBufSize = len(buf)
				}
				if len(buf) > maxBufSize {
					maxBufSize = len(buf)
				}
				// pauseTime := time.Duration(2.0 * float64(time.Second) * float64(len(buf)*8) / float64(6000000))
				// nt := time.NewTimer(pauseTime).C
				toHost <- buf
				// <-nt
			}
		}
	}
}
