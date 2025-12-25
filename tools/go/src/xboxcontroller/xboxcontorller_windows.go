// go:build windows

package xboxcontroller

import (
	"syscall"
	"time"
	"unsafe"
)

type xinputGamepad struct {
	buttons      uint16
	leftTrigger  uint8
	rightTrigger uint8
	lThumbX      int16
	lThumbY      int16
	rThumbX      int16
	rThumbY      int16
}

type xinputState struct {
	packetNumber uint32
	gamepad      xinputGamepad
}

func Start() chan []uint16 {
	var st xinputState
	var id, lastPacketNumber uint32

	rc := make(chan []uint16, 1000)

	go func() {
		for {
			xinputdll := syscall.NewLazyDLL("Xinput1_4.dll")
			if xinputdll == nil {
				rc <- []uint16{0xFFFF}
				time.Sleep(500 * time.Millisecond)
			} else {
				xinputGetState := xinputdll.NewProc("XInputGetState")
				if xinputGetState == nil {
					rc <- []uint16{0xFFFE}
					time.Sleep(500 * time.Millisecond)
				} else {
					lastPacketNumber = uint32(0xFFFFFFFF)
					for id = 0; ; id++ {
						if id > 16 {
							id = 0
						}
						ret, _, _ := xinputGetState.Call(uintptr(id), uintptr(unsafe.Pointer(&st)))
						if ret != 0 {
							rc <- []uint16{0xFFFD, uint16(ret), uint16(id)}
							if xinputdll == nil {
								rc <- []uint16{0xFFFF}
								time.Sleep(500 * time.Millisecond)
							} else {
								xinputGetState := xinputdll.NewProc("XInputGetState")
								if xinputGetState == nil {
									rc <- []uint16{0xFFFE}
									time.Sleep(500 * time.Millisecond)
								}
							}
							time.Sleep(500 * time.Millisecond)
						} else {
							for ret == 0 {
								ret, _, _ = xinputGetState.Call(uintptr(id), uintptr(unsafe.Pointer(&st)))
								if lastPacketNumber != st.packetNumber {
									rc <- []uint16{st.gamepad.buttons, (uint16(st.gamepad.leftTrigger) << 8) | uint16(st.gamepad.rightTrigger), uint16(st.gamepad.lThumbX),
										uint16(st.gamepad.lThumbY), uint16(st.gamepad.rThumbX), uint16(st.gamepad.rThumbY)}
									lastPacketNumber = st.packetNumber
								}
								time.Sleep(50 * time.Millisecond)
							}
						}
					}
				}
			}
		}
	}()
	return rc
}
