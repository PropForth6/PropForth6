// go:build darwin

package xboxcontroller

import "time"

func Start() chan []uint16 {

	rc := make(chan []uint16, 1000)

	go func() {
		for {
			rc <- []uint16{0xEEEE}
			time.Sleep(500 * time.Millisecond)
		}
	}()
	return rc
}
