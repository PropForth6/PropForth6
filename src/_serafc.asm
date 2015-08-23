\
\
\
\ h_01 - sent every 256 characters consumed from serial receive buffer
\ h_02 - sent when serial driver is initialized, over the wire
\ h_03 h80 - sent for value h00
\ h_03 h81 - sent for value h01
\ h_03 h82 - sent for value h02
\ h_03 h83 - sent for value h02
\ 
\ _serafc ( -- ) 
\ pad + 12 - n1 - clocks/bit
\ pad +  8 - n2 - txmask 
\ pad +  4 - n3 - rxmask 
\ pad +  0 - t/f - flow control on/off
\
\ additionally
\ cog registers 0 - hFF inclusive are used for the send receive buffers
\
\ so assemble to load such that __rxmask is at location h100
h_FD :rasm
\
\ the initialization code is reused for uninitialized variables, some of which are initialized
\ by the code, sequence is important
\
__tr1
			mov	__tr1 , par
__tr2
			add	__tr1 , # $V_pad
__rxmask

			rdlong	__tr2 , __tr1 wz
__txmask
		if_e	or	__IFALWAYS_1 , $C_fCondMask
__rxbyte_m
		if_e	or	__IFALWAYS_2 , $C_fCondMask
__rxbyteOut_t 
		if_e	andn	__IFNEVER_1 ,  $C_fCondMask
__rxbits
		if_e	mov	__receiveACK ,  # h_100
__outptr
			add	__tr1 , # 4
__bitticks
			rdlong	__rxmask , __tr1
__bitticks/4
			add	__tr1 , # 4
__receiveTask
			rdlong	__txmask , __tr1
__transmitTask 
			add	__tr1 , # 4
__schedTask
			rdlong	__bitticks , __tr1
__rxbufInTask
			mov	__bitticks/4 , __bitticks
__rxbufOutTask
			shr	__bitticks/4 , # 2
__txbufInTask
			add	__outcharPtr , par
__reg1
                        mov     __transmitTask , # __transmit
__rxbufInReg
                        mov     __schedTask , # __sched                        
__txbufInReg
                        mov     __rxbufInTask  , # __rxbufIn
__txbufInBuf
                        mov     __rxbufOutTask , # __rxbufOut
__txbufInBuf_1
                        mov     __txbufInTask  , # __txbufIn
\
\
\
\ max # of 4 cycle equiv instructions between slices - 8
\
\ Receive
\
__receive
\
                        jmpret  __receiveTask , __transmitTask
\
                        test    __rxmask , ina  wz
              if_nz     jmp     # __receive
\
                        mov     __rxbits , # h9
\ mov 1/4 of the way into the bit slot                        
                        mov     __rxcnt , __bitticks/4
                        add     __rxcnt , cnt             
__receivebit
			add     __rxcnt , __bitticks
__receivewait
			jmpret  __receiveTask , __transmitTask
\
                        mov     __reg1 , __rxcnt
                        sub     __reg1 , cnt
                        cmps    __reg1 , # 0           wc
\
        if_nc           jmp     # __receivewait
\
                        test    __rxmask , ina      wc
                        rcr     __rxdata , # 1
\
                        djnz    __rxbits , # __receivebit
\
\
\        if_nc           jmp     # __receive
\
			jmpret  __receiveTask , __transmitTask
\
\
\
                        shr     __rxdata , # h17
\ 32-9
                        and     __rxdata , # hFF
\
                        mov     __rxbyte , __rxdata
\
                        jmp     # __receive
\
\
\
\ max # of 4 cycle equiv instructions between slices - 7
\
\ Transmit
\
__transmit


__txbufOut
\
                        jmpret  __transmitTask , __schedTask
\
			test    __receiveACK , # h100 wz
		if_z	mov	__txdata , __receiveACK
		if_z	mov	__receiveACK , # h100
		if_z	jmp	# __txACK
                        cmp     __txh , __txt   wz
		if_z	jmp     # __transmit
\
                        jmpret  __transmitTask , __schedTask
\              
			or	__txta , # h80
			movs	__txbufoutrd , __txta
			mov	__txdata , __txtm
__txbufoutrd
			and	__txdata , __txta
			shr	__txdata , __txts
\
                        jmpret  __transmitTask , __schedTask
\
			rol	__txtm , # 8	wc
			addx	__txta , # 0
			and	__txta , # h7F
			add	__txts , # 8
                        add     __txt , # 1
                        and     __txt , # h1FF        
__txACK
                        jmpret  __transmitTask , __schedTask
\
                        or      __txdata , # h100
                        shl     __txdata , # h2
                        or      __txdata , # 1
                        mov     __txbits , # hB
\
                        jmpret  __transmitTask , __schedTask
\
                        mov     __txcnt , cnt
__transmitbit
			shr     __txdata , # 1 wc
                        muxc    outa , __txmask        
                        add     __txcnt , __bitticks
\
__transmitwait
\
                        jmpret  __transmitTask , __schedTask
\
                        mov     __reg1 , __txcnt
                        sub     __reg1 , cnt
                        cmps    __reg1 , # 0 wc
        if_nc           jmp     # __transmitwait
                        djnz    __txbits , # __transmitbit
                        jmp     # __transmit
\
\
\
__sched
                        jmpret  __schedTask , __receiveTask
                        jmpret  __schedTask , __rxbufInTask

                        jmpret  __schedTask , __receiveTask
                        jmpret  __schedTask , __rxbufOutTask

                        jmpret  __schedTask , __receiveTask
                        jmpret  __schedTask , __txbufInTask

			jmp     # __sched
\
\
\ max # of 4 cycle equiv instructions between slices - 7
\
\ num required slices for each byte - 6
\
\

\
__rxbufIn
			mov	__rxbyte_m , # hFF
__rxbufInWait
\
                        jmpret  __rxbufInTask , __schedTask
\
                        test    __rxbyte , # h100     wz
              if_nz     jmp     # __rxbufInWait
			mov	__rxbyte_t , __rxbyte
			mov	__rxbyte , # h100
__IFALWAYS_1
	if_never	jmp	# __rxbufInNFC
\
                        jmpret  __rxbufInTask , __schedTask
\
			cmp	__rxbyte_t , # h_01	wz
		if_e	sub	__sentCharCount , # h100
		if_e	jmp	# __rxbufInWait
\
			cmp	__rxbyte_t , # h_02	wz
		if_e	mov	__sentCharCount , # 0
		if_e	mov	__receivedCharCount , # 0
		if_e	jmp	# __rxbufInWait
\
                        jmpret  __rxbufInTask , __schedTask
\
			cmp	__rxbyte_t , # h_03	wz
		if_e	mov	__rxbyte_m , # h7F
		if_e	jmp	# __rxbufInWait
__rxbufInNFC
			and	__rxbyte_t , __rxbyte_m
\
                        jmpret  __rxbufInTask , __schedTask
\
                        mov     __rxbufInReg , __rxh
                        add     __rxbufInReg , # 1
                        and     __rxbufInReg , # h1FF
                        cmp     __rxbufInReg , __rxt   wz
              if_z      jmp     # __rxbufIn
			movd	__rxbufinand , __rxha
			movd	__rxbufinor , __rxha
\                        
                        jmpret  __rxbufInTask , __schedTask
\
			shl	__rxbyte_t , __rxhs
			and	__rxbyte_t , __rxhm
__rxbufinand
			andn	__rxha , __rxhm
__rxbufinor
			or	__rxha , __rxbyte_t
			rol	__rxhm , # 8	wc
			addx	__rxha , # 0
\
                        jmpret  __rxbufInTask , __schedTask
\
			and	__rxha , # h7F
			add	__rxhs , # 8
                        mov     __rxh , __rxbufInReg
                        jmp     # __rxbufIn
\
\
\
\ max # of 4 cycle equiv instructions between slices - 6
\
\ num required slices for each byte - 10
\
__rxbufOut
                        jmpret  __rxbufOutTask , __schedTask
\
                        cmp     __rxh , __rxt   wz
              if_z      jmp     # __rxbufOut
\
                        jmpret  __rxbufOutTask , __schedTask
\
                        rdword  __outptr , __outcharPtr
\
                        jmpret  __rxbufOutTask , __schedTask
\
                        cmp	__outptr , # 0	wz
              if_z      jmp     # __rxbufOut
\
                        jmpret  __rxbufOutTask , __schedTask
\
			rdword  __rxbyteOut_t , __outptr
\
                        jmpret  __rxbufOutTask , __schedTask
\
			test    __rxbyteOut_t , # h100     wz
              if_z      jmp     # __rxbufOut
\
                        jmpret  __rxbufOutTask , __schedTask
\
__IFNEVER_1
			add	__receivedCharCount , # 1
			test	__receivedCharCount , # h_100	wz
		if_nz	mov	__receivedCharCount , # 0
		if_nz	mov	__receiveACK , # h_01
\
                        jmpret  __rxbufOutTask , __schedTask
\
			movs	__rxbufoutrd , __rxta
			mov	__rxbyteOut_t , __rxtm
__rxbufoutrd
			and	__rxbyteOut_t , __rxta
			shr	__rxbyteOut_t , __rxts
\
                        jmpret  __rxbufOutTask , __schedTask
\

                        wrword  __rxbyteOut_t , __outptr      
\
                        jmpret  __rxbufOutTask , __schedTask
\
			rol	__rxtm , # 8	wc
			addx	__rxta , # 0
			and	__rxta , # h7F
			add	__rxts , # 8
                        add     __rxt , # 1
                        and     __rxt , # h1FF        
\
                        jmpret  __rxbufOutTask , __schedTask
\
                        jmp     # __rxbufOut
\
\ max # of 4 cycle equiv instructions between slices - 7
\
\ num required slices for each byte - 7
\
__txbufIn
\
                        jmpret  __txbufInTask , __schedTask
\
			cmps	__sentCharCount , # h1FF 	wz wc
		if_ae	jmp	# __txbufIn
\
                        mov     __txbufInReg , __txh
                        add     __txbufInReg , # 1
                        and     __txbufInReg , # h1FF
                        cmp     __txbufInReg , __txt   wz
		if_z	jmp     # __txbufIn
\
                        jmpret  __txbufInTask , __schedTask
\
                        rdword  __txbufInBuf , par
\
                        jmpret  __txbufInTask , __schedTask
\
                        test    __txbufInBuf , # h100 wz
              if_nz     jmp     # __txbufIn
			mov	__txbufInBuf_1 , # h_100
__IFALWAYS_2
	if_never	jmp	# __txbufInNFC
\
                        jmpret  __txbufInTask , __schedTask
\
			test	__txbufInBuf , # hFC	wz
		if_e	mov	__txbufInBuf_1 , __txbufInBuf 
		if_e	or	__txbufInBuf_1 , # h_80
		if_e	mov	__txbufInBuf , # h03
		if_ne	add	__sentCharCount , # 1
__txbufInNFC
                        jmpret  __txbufInTask , __schedTask
			wrword	__txbufInBuf_1 , par
                        jmpret  __txbufInTask , __schedTask
\
			or	__txha , # h80
			movd	__txbufinand , __txha
			movd	__txbufinor , __txha
			mov	__txbufInBuf_1 , __txbufInBuf
			shl	__txbufInBuf_1 , __txhs
			and	__txbufInBuf_1 , __txhm
__txbufinand
			andn	__txha , __txhm
\
                        jmpret  __txbufInTask , __schedTask
__txbufinor
			or	__txha , __txbufInBuf_1 
			rol	__txhm , # 8	wc
			addx	__txha , # 0
			and	__txha , # h7F
			add	__txhs , # 8
                        mov     __txh , __txbufInReg
\
\ Only at low baud rates
\
\	add 	__outCharPtr , # h_C6
\	wrword	__sentCharCount , outCharPtr
\	add 	__outCharPtr , # h_2
\	wrword	__sentCharCount , outCharPtr
\	sub 	__outCharPtr , # h_C8

                        jmp     # __txbufIn
\
\
__outcharPtr
	2
__rxhm
	hFF
__rxtm
	hFF
__txhm
	hFF
__txtm
	hFF
__rxbyte
	h100
__h100
	h100
__h200
	h200
__receiveACK
	h02
__rxdata
	0
__txdata
	0
__txbits
	0
__rxbyte_t
	0
__receivedCharCount
	0
__sentCharCount
	0
__rxh
	0
__rxha
	0
__rxhs
	0
__rxt
	0
__rxta
	0
__rxts
	0
__txh
	0
__txha
	0
__txhs
	0
__txt
	0
__txta
	0
__txts
	0
__rxcnt
	0
__txcnt
	0

\
;asm _serafc


