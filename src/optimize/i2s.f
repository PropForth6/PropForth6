

[ifndef ctra
h1F8	wconstant ctra
]
[ifndef ctrb
h1F9	wconstant ctrb 
]
[ifndef frqa
h1FA	wconstant frqa 
]
[ifndef frqb
h1FB	wconstant frqb 
]
[ifndef phsa
h1FC	wconstant phsa 
]
[ifndef phsb
h1FD	wconstant phsb 
]
\
\ abs ( n1 -- abs_n1 ) absolute value of n1
[ifndef abs
: abs
	_xasm1>1 h151 _cnip
;
]
\ _cfo ( n1 -- n2 ) n1 - desired frequency, n2 freq a 
[ifndef _cfo
: _cfo clkfreq 1- min 0 swap clkfreq um/mod swap clkfreq 2/ >= abs + ; 
]
\ setHza ( n1 n2 -- ) n1 is the pin, n2 is the freq, uses ctra
\ set the pin oscillating at the specified frequency
[ifndef setHza
: setHza _cfo frqa COG! dup pinout h10000000 + ctra COG! ; 
]
\ qHzb ( n1 n2 -- n3 ) n1 - the pin, n2 - the # of msec to sample, n3 the frequency
[ifndef qHzb
: qHzb
	swap h28000000 + 1 frqb COG! ctrb COG!
	h3000 min clkfreq over h3E8 u*/ h310 - phsb COG@ swap cnt COG@ + 0 waitcnt
	phsb COG@ nip swap - h3E8 rot u*/ ; 
]
\ setHzb ( n1 n2 -- ) n1 is the pin, n2 is the freq, uses ctrb
\ set the pin oscillating at the specified frequency
[ifndef setHzb
: setHzb _cfo frqb COG! dup pinout h10000000 + ctrb COG! ; 
]

variable  dataOut
wvariable dataAck

: d! dataOut L! ;
: esc? fkey? if dup h1B = swap 5 = or else drop 0 then ;

: up 
    0 dataOut L!
    7 pinout
    begin
        dataOut L@
        h00010001 +
        begin
            dataAck W@ 0 =
        until
        7 pinlo
        dataOut L!
        1 dataAck W!
        esc?  
        7 pinhi  
    until 
    ;
: lrToBitFreq 
    32 * 
    ;
: showFreq
    lrToBitFreq dup dup cr
    c"     BIT freq: " .cstr . cr
    32 u/
    c"      LR freq: " .cstr . cr 
    clkfreq swap u/
    c" # cpu clocks: " .cstr . cr 
    ; 

lockdict create _i2s forthentry
$C_a_lxasm w, h13B  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
hA0BE64C8 l, h5CFD72B3 l, hA0BE66C8 l, h5CFD72B3 l, hA0BE68C8 l, h5CFD72B3 l, hA0BE6AC8 l, h5CFD72B3 l,
hA0BE6CC8 l, h5CFD72B3 l, h64BFE934 l, h64BFE935 l, h8BE6F33 l, h5CFE752D l, h43E7132 l, h5CFE752D l,
h5CFE752D l, h5CFE752D l, h5CFE752D l, h5CFE752D l, h5CFE752D l, h5CFE752D l, h5CFE752D l, h5CFE752D l,
h5CFE752D l, h5CFE752D l, h5CFE752D l, h5CFE752D l, h5CFE752D l, h5CFE752D l, h68BFE935 l, h5CFE752D l,
h5CFE752D l, h5CFE752D l, h5CFE752D l, h5CFE752D l, h5CFE752D l, h5CFE752D l, h5CFE752D l, h5CFE752D l,
h5CFE752D l, h5CFE752D l, h5CFE752D l, h5CFE752D l, h5CFE752D l, h5CFE752D l, h5CFE752D l, h64BFE935 l,
h5C7C0108 l, hF03E6D36 l, hF43E6D36 l, h2DFE6E01 l, h70BFE934 l, h5C3C013A l, 0 l, 0 l,
h4 l, h2 l, h1 l, 0 l, 0 l, hFFFF7FFE l, 0 l,
freedict

0 d!

c" 1 pinout 2 pinout 3 pinout 0 44100 lrToBitFreq setHza 1 2 4 dataOut dataAck _i2s" 5 cogx





h7EFF7FEF d!
hA555A555 d!
h800010005 d!
0 d!














--cps 10000
\ _i2s ( clockMask lrMask dataOutMask dataAddr ackAddr -- )
build_BootOpt :rasm
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
                andn    outa , __lrMask
__mainLoop
                rdlong  __currentData , __dataAddr
\ clock - 49
                jmpret  __bitOutRet , # __bitOut
\ max t = 55 clocks
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
                andn    outa , __lrMask
\ clock - 22
                jmp     # __mainLoop
\ clock - 26

__bitOut
                waitpeq __clockMask , __clockMask
\ clock - 0 -- clock 55
                waitpne __clockMask , __clockMask
\ clock - 6
                shl     __currentData , # 1 wc
\ clock - 10
                muxc    outa , __dataOutMask
\ clock - 14
                jmp     __bitOutRet
\ clock - 18    

__ackAddr
                0
__dataAddr
                0
__dataOutMask
                4
__lrMask
                2
__clockMask
                1
__currentData
                0
__zero
                0
__data
                hFFFF7FFE
__bitOutRet
                0

;asm _i2s



































\ old stuff

\ _i2s ( clockMask lrMask dataOutMask dataAddr ackAddr -- )
build_BootOpt :rasm
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
\ clock - 41
                jmpret  __bitOutRet , # __bitOut
\ clock - 47 max
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
\ 
                waitpeq __clockMask , __clockMask
\ clock - 0 -- clock 47
                waitpne __clockMask , __clockMask
\ clock - 6
                shl     __currentData , # 1 wc
\ clock - 10
                muxc    outa , __dataOutMask
\ clock - 14
                jmp     __bitOutRet
\ clock - 18    

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











