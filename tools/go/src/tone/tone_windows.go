//build:go windows

package tone

import "syscall"

func Tone(freq, lenMs int) {
	go func() {
		if freq < 300 {
			freq = 300
		} else if freq > 7000 {
			freq = 7000
		}
		if lenMs < 100 {
			lenMs = 100
		} else if lenMs > 10000 {
			lenMs = 10000
		}
		kernel32, _ := syscall.LoadLibrary("kernel32.dll")
		beep32, _ := syscall.GetProcAddress(kernel32, "Beep")
		defer syscall.FreeLibrary(kernel32)
		_, _, _ = syscall.SyscallN(beep32, uintptr(int(freq)), uintptr(lenMs))
	}()
}
