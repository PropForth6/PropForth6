

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



















\ ( angle type -- res ) angle 0x2000 is 2PI or 360 degrees, 
\   type 0 sin, 1 triangle, 2 square, 3 sawtooth, res has 17 significant bits
build_BootOpt :rasm
                mov     __type , $C_stTOS
                spop
                cmp     __type , # 3                  wc wz
    if_e        jmpret  __sawRet , # __saw
                cmp     __type , # 2                  wc wz
    if_e        jmpret  __squareRet , # __square
                cmp     __type , # 1                  wc wz
    if_e        jmpret  __triangleRet , # __triangle
                cmp    __type , # 0                   wc wz
    if_e        jmpret  __sinRet ,  # __sin
                jexit
 
__sin
                test    $C_stTOS , __quad90 wc
                test    $C_stTOS , __quad180 wz
    if_c        neg     $C_stTOS , $C_stTOS
                or      $C_stTOS , __sinTable
                shl     $C_stTOS , # 1
                rdword  $C_stTOS , $C_stTOS
    if_nz       neg     $C_stTOS , $C_stTOS
__sinRet
                ret

__triangle
                test    $C_stTOS , __quad90 wc
                test    $C_stTOS , __quad180 wz
    if_c        neg     $C_stTOS , $C_stTOS
                and     $C_stTOS , __angleMask
                shl     $C_stTOS , # 5
    if_nz       neg     $C_stTOS , $C_stTOS
__triangleRet
                ret

__saw
                and     $C_stTOS , __angleMask360
                shl     $C_stTOS , # 4
                sub     $C_stTOS , __sawShift            
__sawRet
                ret

__square
                test    $C_stTOS , __quad180 wz
    if_z        mov     $C_stTOS , __maxValue
    if_nz       mov     $C_stTOS , __minValue
__squareRet
                ret


__type
                0
__quad90
                h800 
__quad180
                h1000 
\ 0xE000 >> 1
__sinTable
                h7000
__angleMask360
                h1FFF
__angleMask
                h7FF
__maxValue
                hFFFF 
__minValue
                hFFFF0001
\ h10000 - 8
__sawShift
                hFFF8
;asm wav





lockdict create wav forthentry
$C_a_lxasm w, h127  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
hA0BE3CC8 l, h5CFD72B3 l, h877E3C03 l, h5CEA3316 l, h877E3C02 l, h5CEA3B1A l, h877E3C01 l, h5CEA2B0F l,
h877E3C00 l, h5CEA1D07 l, h5C7C0073 l, h613D911F l, h623D9120 l, hA4B190C8 l, h68BD9121 l, h2CFD9001 l,
h4BD90C8 l, hA49590C8 l, h5C7C0000 l, h613D911F l, h623D9120 l, hA4B190C8 l, h60BD9123 l, h2CFD9005 l,
hA49590C8 l, h5C7C0000 l, h60BD9122 l, h2CFD9004 l, h84BD9126 l, h5C7C0000 l, h623D9120 l, hA0A99124 l,
hA0959125 l, h5C7C0000 l, 0 l, h800 l, h1000 l, h7000 l, h1FFF l, h7FF l,
hFFFF l, hFFFF0001 l, hFFF8 l,
freedict

: sin 0 wav ;
: triangle 1 wav ;
: square 2 wav ;
: sawtooth 3 wav ;

: winit dira COG@ hFFFF or dira COG! ;
 

: tw
    h2100 0 do
        i . i 0 wav . i 1 wav . i 2 wav .  i 3 wav . cr

    loop
;

: tw1
    h80 0 do
        i . i 0 wav . i 1 wav . i 2 wav .  i 3 wav . cr
    loop
    cr cr cr cr
    h880 h780 do
        i . i 0 wav . i 1 wav . i 2 wav .  i 3 wav . cr
    loop
    cr cr cr cr
    h1040 hFC0 do
        i . i 0 wav . i 1 wav . i 2 wav .  i 3 wav . cr
    loop
    cr cr cr cr
    h1880 h1780 do
        i . i 0 wav . i 1 wav . i 2 wav .  i 3 wav . cr
    loop
    cr cr cr cr
    h2040 h1FC0 do
        i . i 0 wav . i 1 wav . i 2 wav .  i 3 wav . cr
    loop
;

: tw2
    0 begin
        dup 
        esc?
    until

;


: tt
    h2100 0 do
        i . i h1FFF and 4 lshift h10000 - . cr
    h100 +loop
;






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





: cntToMs clkfreq 1000 u/ u/ ;
: si
    begin
        fkey?
        if
            h61 =
        else
            drop
            0
        then
    until
    cnt COG@
    0
    begin 
        5 delms
        fkey?
        if
            5 =
            swap 1 + swap
        else
            drop
            0
        then 
    until
    . cr
    cnt COG@ swap - cntToMs . cr
    ;


a
000 01234567890123456789012345678901234567890123456789012345678901234567890123456789
001 01234567890123456789012345678901234567890123456789012345678901234567890123456789
002 01234567890123456789012345678901234567890123456789012345678901234567890123456789
003 01234567890123456789012345678901234567890123456789012345678901234567890123456789
004 01234567890123456789012345678901234567890123456789012345678901234567890123456789
005 01234567890123456789012345678901234567890123456789012345678901234567890123456789
006 01234567890123456789012345678901234567890123456789012345678901234567890123456789
007 01234567890123456789012345678901234567890123456789012345678901234567890123456789
008 01234567890123456789012345678901234567890123456789012345678901234567890123456789
009 01234567890123456789012345678901234567890123456789012345678901234567890123456789
010 01234567890123456789012345678901234567890123456789012345678901234567890123456789
011 01234567890123456789012345678901234567890123456789012345678901234567890123456789
012 01234567890123456789012345678901234567890123456789012345678901234567890123456789
013 01234567890123456789012345678901234567890123456789012345678901234567890123456789
014 01234567890123456789012345678901234567890123456789012345678901234567890123456789
015 01234567890123456789012345678901234567890123456789012345678901234567890123456789
016 01234567890123456789012345678901234567890123456789012345678901234567890123456789
017 01234567890123456789012345678901234567890123456789012345678901234567890123456789
018 01234567890123456789012345678901234567890123456789012345678901234567890123456789
019 01234567890123456789012345678901234567890123456789012345678901234567890123456789
020 01234567890123456789012345678901234567890123456789012345678901234567890123456789
021 01234567890123456789012345678901234567890123456789012345678901234567890123456789
022 01234567890123456789012345678901234567890123456789012345678901234567890123456789
023 01234567890123456789012345678901234567890123456789012345678901234567890123456789
024 01234567890123456789012345678901234567890123456789012345678901234567890123456789
025 01234567890123456789012345678901234567890123456789012345678901234567890123456789
026 01234567890123456789012345678901234567890123456789012345678901234567890123456789
027 01234567890123456789012345678901234567890123456789012345678901234567890123456789
028 01234567890123456789012345678901234567890123456789012345678901234567890123456789
029 01234567890123456789012345678901234567890123456789012345678901234567890123456789
030 01234567890123456789012345678901234567890123456789012345678901234567890123456789
031 01234567890123456789012345678901234567890123456789012345678901234567890123456789
032 01234567890123456789012345678901234567890123456789012345678901234567890123456789
033 01234567890123456789012345678901234567890123456789012345678901234567890123456789
034 01234567890123456789012345678901234567890123456789012345678901234567890123456789
035 01234567890123456789012345678901234567890123456789012345678901234567890123456789
036 01234567890123456789012345678901234567890123456789012345678901234567890123456789
037 01234567890123456789012345678901234567890123456789012345678901234567890123456789
038 01234567890123456789012345678901234567890123456789012345678901234567890123456789
039 01234567890123456789012345678901234567890123456789012345678901234567890123456789
040 01234567890123456789012345678901234567890123456789012345678901234567890123456789
041 01234567890123456789012345678901234567890123456789012345678901234567890123456789
042 01234567890123456789012345678901234567890123456789012345678901234567890123456789
043 01234567890123456789012345678901234567890123456789012345678901234567890123456789
044 01234567890123456789012345678901234567890123456789012345678901234567890123456789
045 01234567890123456789012345678901234567890123456789012345678901234567890123456789
046 01234567890123456789012345678901234567890123456789012345678901234567890123456789
047 01234567890123456789012345678901234567890123456789012345678901234567890123456789
048 01234567890123456789012345678901234567890123456789012345678901234567890123456789
049 01234567890123456789012345678901234567890123456789012345678901234567890123456789
050 01234567890123456789012345678901234567890123456789012345678901234567890123456789
051 01234567890123456789012345678901234567890123456789012345678901234567890123456789
052 01234567890123456789012345678901234567890123456789012345678901234567890123456789
053 01234567890123456789012345678901234567890123456789012345678901234567890123456789
054 01234567890123456789012345678901234567890123456789012345678901234567890123456789
055 01234567890123456789012345678901234567890123456789012345678901234567890123456789
056 01234567890123456789012345678901234567890123456789012345678901234567890123456789
057 01234567890123456789012345678901234567890123456789012345678901234567890123456789
058 01234567890123456789012345678901234567890123456789012345678901234567890123456789
059 01234567890123456789012345678901234567890123456789012345678901234567890123456789
060 01234567890123456789012345678901234567890123456789012345678901234567890123456789
061 01234567890123456789012345678901234567890123456789012345678901234567890123456789
062 01234567890123456789012345678901234567890123456789012345678901234567890123456789
063 01234567890123456789012345678901234567890123456789012345678901234567890123456789
064 01234567890123456789012345678901234567890123456789012345678901234567890123456789
065 01234567890123456789012345678901234567890123456789012345678901234567890123456789
066 01234567890123456789012345678901234567890123456789012345678901234567890123456789
067 01234567890123456789012345678901234567890123456789012345678901234567890123456789
068 01234567890123456789012345678901234567890123456789012345678901234567890123456789
069 01234567890123456789012345678901234567890123456789012345678901234567890123456789
070 01234567890123456789012345678901234567890123456789012345678901234567890123456789
071 01234567890123456789012345678901234567890123456789012345678901234567890123456789
072 01234567890123456789012345678901234567890123456789012345678901234567890123456789
073 01234567890123456789012345678901234567890123456789012345678901234567890123456789
074 01234567890123456789012345678901234567890123456789012345678901234567890123456789
075 01234567890123456789012345678901234567890123456789012345678901234567890123456789
076 01234567890123456789012345678901234567890123456789012345678901234567890123456789
077 01234567890123456789012345678901234567890123456789012345678901234567890123456789
078 01234567890123456789012345678901234567890123456789012345678901234567890123456789
079 01234567890123456789012345678901234567890123456789012345678901234567890123456789
080 01234567890123456789012345678901234567890123456789012345678901234567890123456789
081 01234567890123456789012345678901234567890123456789012345678901234567890123456789
082 01234567890123456789012345678901234567890123456789012345678901234567890123456789
083 01234567890123456789012345678901234567890123456789012345678901234567890123456789
084 01234567890123456789012345678901234567890123456789012345678901234567890123456789
085 01234567890123456789012345678901234567890123456789012345678901234567890123456789
086 01234567890123456789012345678901234567890123456789012345678901234567890123456789
087 01234567890123456789012345678901234567890123456789012345678901234567890123456789
088 01234567890123456789012345678901234567890123456789012345678901234567890123456789
089 01234567890123456789012345678901234567890123456789012345678901234567890123456789
090 01234567890123456789012345678901234567890123456789012345678901234567890123456789
091 01234567890123456789012345678901234567890123456789012345678901234567890123456789
092 01234567890123456789012345678901234567890123456789012345678901234567890123456789
093 01234567890123456789012345678901234567890123456789012345678901234567890123456789
094 01234567890123456789012345678901234567890123456789012345678901234567890123456789
095 01234567890123456789012345678901234567890123456789012345678901234567890123456789
096 01234567890123456789012345678901234567890123456789012345678901234567890123456789
097 01234567890123456789012345678901234567890123456789012345678901234567890123456789
098 01234567890123456789012345678901234567890123456789012345678901234567890123456789
099 01234567890123456789012345678901234567890123456789012345678901234567890123456789



