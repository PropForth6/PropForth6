

c" 0  1000 setHza" 4 cogx
c" i2s" 5 cogx
lac

: i2b dup h8000_0000 and 1 1 waitpeq 0 1 waitpeq if 1 pinhi else 1 pinlo then 1 lshift 1 1 waitpeq ;

\ i2s ( n -- )
: i2s 
    1 pinout 2 pinout 3 pinout
    begin
        2 pinlo
        i2b drop hFFFF7FFE i2b i2b i2b  i2b i2b i2b i2b   i2b i2b i2b i2b  i2b i2b i2b i2b 
        2 pinhi
        i2b                i2b i2b i2b  i2b i2b i2b i2b   i2b i2b i2b i2b  i2b i2b i2b i2b
        3 pinhi
        key? if key 5 = else 0 then 
        3 pinlo
    until
    ;






lockdict create _i2s forthentry
$C_a_lxasm w, h13A  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
h5C7C00FD l, hA0BE64C8 l, h5CFD72B3 l, hA0BE66C8 l, h5CFD72B3 l, hA0BE68C8 l, h5CFD72B3 l, hA0BE6AC8 l,
h5CFD72B3 l, hA0BE6CC8 l, h5CFD72B3 l, h64BFE934 l, h64BFE935 l, h5CFE712D l, h8BE6F33 l, h5CFE712D l,
h43E7332 l, h5CFE712D l, h5CFE712D l, h5CFE712D l, h5CFE712D l, h5CFE712D l, h5CFE712D l, h5CFE712D l,
h5CFE712D l, h5CFE712D l, h5CFE712D l, h5CFE712D l, h5CFE712D l, h5CFE712D l, h5CFE712D l, h68BFE935 l,
h5CFE712D l, h5CFE712D l, h5CFE712D l, h5CFE712D l, h5CFE712D l, h5CFE712D l, h5CFE712D l, h5CFE712D l,
h5CFE712D l, h5CFE712D l, h5CFE712D l, h5CFE712D l, h5CFE712D l, h5CFE712D l, h5CFE712D l, h5CFE712D l,
h5C7C0108 l, hF03E6D36 l, hF43E6D36 l, h2DFE6E01 l, h70BFE934 l, h5C3C0138 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
freedict





\ _i2s ( clockMask lrMask dataOutMask dataAddr ackAddr -- )
build_BootOpt :rasm
                jmp     # __start
__start
	            mov	    __ackAddr , $C_stTOS
	            spop
	            mov     __dataAddr , $C_stTOS
	            spop
	            mov     __dataOutMask , $C_stTOS
	            spop
	            mov     __lrMask , $C_stTOS
	            spop
	            mov     __clockMask , $C_stTOS
                spop
                andn    outa , __dataOutMask
__mainLoop
                andn    outa , __lrMask
                jmpret  __bitOutRet , # __bitOut
                rdlong  __currentData , __dataAddr
                jmpret  __bitOutRet , # __bitOut
\ max t = 51 clocks
                wrword  __zero , __ackAddr
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                or      outa , __lrMask
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmpret  __bitOutRet , # __bitOut  
                jmp     # __mainLoop
__bitOut
                waitpeq __clockMask , __clockMask
                waitpne __clockMask , __clockMask
                shl     __currentData , # 1 wc
                muxc    outa , __dataOutMask
                jmp     __bitOutRet    

__ackAddr
                0
__dataAddr
                0
__dataOutMask
                0
__lrMask
                0
__clockMask
                0
__currentData
                0
__bitOutRet
                0
__zero
                0


;asm _i2s

