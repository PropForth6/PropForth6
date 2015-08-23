$V_lc 1+ $V_pad -	wconstant _vpadsize
_vpadsize 2-		wconstant _vpadsize-2
_vpadsize 4 u/		wconstant _vpadlongs
$V_state 2-		wconstant _vstate-2
$V_state $V_pad 1+ -	wconstant _vstate-vpad+1

\
\
wvariable max_coghere coghere W@ max_coghere W!

max_coghere W@ wconstant build_BootOpt3

build_BootOpt3 :rasm
	rpop
	mov	$C_IP , $C_treg5
	spush
	rdword	$C_treg1 , $C_IP
	add	$C_IP , # 2
	add	$C_treg1 , $C_this
	rdlong	$C_stTOS , $C_treg1
	jnext
;asm thisL@

max_coghere W@ _asmaddr W@ max max_coghere W!

build_BootOpt3 :rasm
	rpop
	mov	$C_IP , $C_treg5
	spush
	rdword	$C_treg1 , $C_IP
	add	$C_IP , # 2
	add	$C_treg1 , $C_this
	rdword	$C_stTOS , $C_treg1
	jnext
;asm thisW@

max_coghere W@ _asmaddr W@ max max_coghere W!

build_BootOpt3 :rasm
	rpop
	mov	$C_IP , $C_treg5
	spush
	rdword	$C_treg1 , $C_IP
	add	$C_IP , # 2
	add	$C_treg1 , $C_this
	rdbyte	$C_stTOS , $C_treg1
	jnext
;asm thisC@

max_coghere W@ _asmaddr W@ max max_coghere W!

\
\
\ padbl ( -- ) 
\
build_BootOpt3 :rasm
		mov	$C_treg5 , par
		add	$C_treg5 , # $V_pad
\
		mov	$C_treg3 , # _vpadlongs
__x01
		wrlong	__x0F , $C_treg5
		add	$C_treg5 , # h4
		djnz	$C_treg3 , # __x01
\		
		jexit
\
__x0F
	h20202020
;asm padbl

max_coghere W@ _asmaddr W@ max max_coghere W!

\
\
\ key ( -- c1 )
\
build_BootOpt3 :rasm
		spush
__x01
		rdword	$C_stTOS , par
		test	$C_stTOS , # h100	wz
	if_nz	jmp	# __x01
		mov	$C_treg1 , # h100
		wrword	$C_treg1 , par
		jexit
;asm key

max_coghere W@ _asmaddr W@ max max_coghere W!

max_coghere W@ wconstant build_BootOpt2

build_BootOpt2 :rasm
	rpop
	mov	$C_IP , $C_treg5
	rdword	$C_treg1 , $C_IP
	add	$C_IP , # 2
	add	$C_treg1 , $C_this
	wrlong	$C_stTOS , $C_treg1
	spop
	jnext
;asm thisL!

max_coghere W@ _asmaddr W@ max max_coghere W!

build_BootOpt2 :rasm
	rpop
	mov	$C_IP , $C_treg5
	rdword	$C_treg1 , $C_IP
	add	$C_IP , # 2
	add	$C_treg1 , $C_this
	wrword	$C_stTOS , $C_treg1
	spop
	jnext
;asm thisW!

max_coghere W@ _asmaddr W@ max max_coghere W!

build_BootOpt2 :rasm
	rpop
	mov	$C_IP , $C_treg5
	rdword	$C_treg1 , $C_IP
	add	$C_IP , # 2
	add	$C_treg1 , $C_this
	wrbyte	$C_stTOS , $C_treg1
	spop
	jnext
;asm thisC!

max_coghere W@ _asmaddr W@ max max_coghere W!

max_coghere W@ wconstant build_BootOpt1

\
\
\
\ um* ( u1 u2 -- u1*u2L u1*u2H ) \ unsigned 32bit * 32bit -- 64bit result
\
\
build_BootOpt1 :rasm
		spopt
		mov	$C_treg2 , # 0
		mov	$C_treg3 , # 0
		mov	$C_treg4 , # 0
__x01
		shr	$C_stTOS , # 1			wz wc 
	if_nc	jmp     # __x02
\
		add	$C_treg4 , $C_treg1		wc
		addx	$C_treg2 , $C_treg3 
__x02
\
		shl	$C_treg1 , # 1			wc
		rcl	$C_treg3 , # 1
	if_nz	jmp     # __x01
\		
		mov	$C_stTOS , $C_treg4
		spush
		mov	$C_stTOS , $C_treg2
		jexit
;asm um*

max_coghere W@ _asmaddr W@ max max_coghere W!

\
\
\ um/mod ( u1lo u1hi u2 -- remainder quotient ) \ unsigned divide & mod  u1 divided by u2
\
build_BootOpt1 :rasm
		spopt
		mov	$C_treg6 , $C_stTOS                     
		spop
		mov	$C_treg3 , # h40
		mov	$C_treg2 , # 0
\
__x01
		shl	$C_stTOS , # 1			wc
		rcl	$C_treg6 , # 1			wc
\                                                
		rcl	$C_treg2 , # 1			wc
\
\
	if_c	sub	$C_treg2 , $C_treg1                        
	if_nc	cmpsub	$C_treg2 , $C_treg1		wc wr
\
\
		rcl	$C_treg4 , # 1                                               
		djnz	$C_treg3 , # __x01
\
		mov	$C_stTOS , $C_treg2
		spush
		mov	$C_stTOS , $C_treg4
		jexit
;asm um/mod

max_coghere W@ _asmaddr W@ max max_coghere W!

\
\ cstr= ( cstr1 cstr2 -- t/f ) case sensitive compare
\
\
build_BootOpt1 :rasm
		spopt
		rdbyte	$C_treg2 , $C_treg1
		add	$C_treg2 , # 1
		sub	$C_stTOS , # 1
__x01
		rdbyte	$C_treg3 , $C_treg1
		add	$C_treg1 , # 1
		add	$C_stTOS , # 1
		rdbyte	$C_treg4 , $C_stTOS
		cmp	$C_treg3 , $C_treg4		wz
	if_z	djnz	$C_treg2 , # __x01
\
		muxz	$C_stTOS , $C_fLongMask
		jexit
;asm cstr=
\
\ name= ( cstr1 cstr2 -- t/f ) case sensitive compare
\
build_BootOpt1 :rasm
		spopt
		rdbyte	$C_treg2 , $C_treg1
		and	$C_treg2 , # h1F
		add	$C_treg1 , # 1
\
		rdbyte	$C_treg4 , $C_stTOS
		and	$C_treg4 , # h1F
		mov	$C_treg3 , $C_treg2
		add	$C_treg2 , # 1
\		
		jmp	# __x02
\		
__x01
		rdbyte	$C_treg3 , $C_treg1
		add	$C_treg1 , # 1
		add	$C_stTOS , # 1
		rdbyte	$C_treg4 , $C_stTOS
__x02
		cmp	$C_treg3 , $C_treg4		wz
	if_z	djnz	$C_treg2 , # __x01
\
		muxz	$C_stTOS , $C_fLongMask
		jexit
;asm name=

max_coghere W@ _asmaddr W@ max max_coghere W!

\
\ .str ( c-addr u1 -- ) emit u1 characters at c-addr
\
build_BootOpt1 :rasm
		spopt
\
		cmp	$C_treg1 , # 0	wz
	if_nz	mov	$C_treg6 , par
	if_nz	add	$C_treg6 , # h2
	if_nz	rdword	$C_treg2 , $C_treg6	wz 
\
	if_z	jmp	# __x01
__x03
		rdbyte	$C_treg4 , $C_stTOS
		add	$C_stTOS , # 1
__x02
		rdword	$C_treg3 , $C_treg2
		test	$C_treg3 , # h100	wz
	if_z	jmp	# __x02
\
		wrword	$C_treg4 , $C_treg2
		djnz	$C_treg1 , # __x03
\
__x01
		spop
		jexit
;asm .str

max_coghere W@ _asmaddr W@ max max_coghere W!

\
\ _fkey? ( ioaddr -- c1 t/f ) fast nonblocking key routine, true if c1 is a valid key
\
build_BootOpt1 :rasm
		rdword	$C_treg1 , $C_stTOS
		test	$C_treg1 , # h100	wz
		muxz	$C_treg2 , $C_fLongMask
\				
	if_nz	jmp	# __x01
\
		mov	$C_treg3 , # h100
		wrword	$C_treg3 , $C_stTOS
\
__x01
		mov	$C_stTOS , $C_treg1
		spush
		mov	$C_stTOS , $C_treg2
		jexit
;asm _fkey?

max_coghere W@ _asmaddr W@ max max_coghere W!

\
\
\ fkey? ( -- c1 t/f ) fast nonblocking key routine, true if c1 is a valid key
\
build_BootOpt1 :rasm
		spush
		rdword	$C_stTOS , par
		test	$C_stTOS , # h100	wz
		muxz	$C_treg1 , $C_fLongMask
\				
	if_nz	jmp	# __x01
\
		mov	$C_treg3 , # h100
		wrword	$C_treg3 , par
\
__x01
		spush
		mov	$C_stTOS , $C_treg1 
		jexit
;asm fkey?

max_coghere W@ _asmaddr W@ max max_coghere W!

\
\
\ _femit? (c1 ioaddr -- t/f) true if the output emitted a char, a fast non blocking emit
\
build_BootOpt1 :rasm
		spopt
		and	$C_stTOS , # hFF
\
		rdword	$C_treg2 , $C_treg1
		test	$C_treg2 , # h100	wz
		muxnz	$C_treg3 , $C_fLongMask
	if_nz	wrword	$C_stTOS , $C_treg1
__x01
		mov	$C_stTOS , $C_treg3		
		jexit
;asm _femit?

max_coghere W@ _asmaddr W@ max max_coghere W!

\
\
\ femit? (c1 -- t/f) true if the output emitted a char, a fast non blocking emit
\
build_BootOpt1 :rasm
		and	$C_stTOS , # hFF
		mov	$C_treg2 , par
		add	$C_treg2 , # h2
\		
		rdword	$C_treg3 , $C_treg2	wz
		muxz	$C_treg4 , $C_fLongMask
	if_z	jmp	# __x01
\
		rdword	$C_treg2 , $C_treg3
		test	$C_treg2 , # h100	wz
		muxnz	$C_treg4 , $C_fLongMask
	if_nz	wrword	$C_stTOS , $C_treg3
__x01
		mov	$C_stTOS , $C_treg4		
		jexit
;asm femit?

max_coghere W@ _asmaddr W@ max max_coghere W!

\
\ emit ( c1 -- )
\
build_BootOpt1 :rasm
		spopt
		and	$C_treg1 , # hFF
		mov	$C_treg2 , par
		add	$C_treg2 , # h2
\		
		rdword	$C_treg3 , $C_treg2	wz
	if_z	jmp	# __x02
__x01
		rdword	$C_treg2 , $C_treg3
		test	$C_treg2 , # h100	wz
	if_z	jmp	# __x01
\
		wrword	$C_treg1 , $C_treg3
__x02
		jexit
;asm emit

max_coghere W@ _asmaddr W@ max max_coghere W!

\
\ skipbl ( -- )
build_BootOpt1 :rasm
\ >in
		mov	$C_treg1 , par
		add	$C_treg1 , # $V_>in
		rdword	$C_treg2 , $C_treg1
		cmp	$C_treg2 , # _vpadsize		wz wc
	if_ae	jmp	# __x02
\
\
\ num characters left in pad
		mov	$C_treg3 , # _vpadsize
		sub	$C_treg3 , $C_treg2
\ pad>in
		add	$C_treg2 , # $V_pad
		add	$C_treg2 , par
\
__x01
			rdbyte	$C_treg5 , $C_treg2
			cmp	$C_treg5 , # h20 	wz
		if_e	add	$C_treg2 , # 1
\
	if_e	djnz	$C_treg3 , # __x01
\	
\
\
\ recalculate >in
	sub	$C_treg2 , # $V_pad
	sub	$C_treg2 , par
	wrword	$C_treg2 , $C_treg1
__x02
	jexit
\	
;asm skipbl

max_coghere W@ _asmaddr W@ max max_coghere W!

build_BootOpt1 :rasm
\
\ INPUTS:
\ stTOS - addr
\
\ OUTPUTS:
\ treg2 - items available
\ treg4 - items free
\
\ USES:
\ treg2 - head
\ treg3 - tail
\ treg4 - size
\ stTOS - addr
	rdlong	$C_treg2 , $C_stTOS
	mov	$C_treg3 , $C_treg2
	mov	$C_treg4 , $C_treg2
	and	$C_treg2 , # hFF
	shr	$C_treg3 , # h8
	and	$C_treg3 , # hFF
	shr	$C_treg4 , # h10
	and	$C_treg4 , # hFF

	sub	$C_treg2 , $C_treg3	wz wc
 if_b	add	$C_treg2 , $C_treg4

	sub	$C_treg4 , $C_treg2
	sub	$C_treg4 , # 1

	mov	$C_stTOS , $C_treg2
	spush
	mov	$C_stTOS , $C_treg4
	jexit
;asm _qaf

max_coghere W@ _asmaddr W@ max max_coghere W!

\
\

max_coghere W@ wconstant build_BootOpt

wvariable max_coghere coghere W@ max_coghere W!

\
\ _eeread ( t/f -- c1 ) flag should be true is this is the last read
\
build_BootOpt :rasm
		jmp	# __x0C
__x02sda
		h20000000
__x03scl
		h10000000
__x04delay/2
		hD
\ this delay makes for a 400kHZ clock on an 80 Mhz prop
\
__x0Edelay/2
		mov	$C_treg6 , __x04delay/2
__x0D
		djnz	$C_treg6 , # __x0D
__x0Fdelayret
		ret
\
__x0C
		mov	$C_treg1 , $C_stTOS 
		mov	$C_stTOS , # 0
		andn	dira , __x02sda
		mov	$C_treg3 , # h8
\		
__x0B
		jmpret	__x0Fdelayret , # __x0Edelay/2
\
		test	__x02sda , ina	wc
		rcl	$C_stTOS , # 1
\
		or	outa , __x03scl
\
		jmpret	__x0Fdelayret , # __x0Edelay/2
		jmpret	__x0Fdelayret , # __x0Edelay/2
\
		andn	outa , __x03scl
\
		jmpret	__x0Fdelayret , # __x0Edelay/2
\
		djnz	$C_treg3 , # __x0B
\
		cmp	$C_treg1 , # 0 wz
		muxnz	outa , __x02sda
		or	dira , __x02sda
\
		jmpret	__x0Fdelayret , # __x0Edelay/2
\
		or	outa , __x03scl
\
		jmpret	__x0Fdelayret , # __x0Edelay/2
		jmpret	__x0Fdelayret , # __x0Edelay/2
\
		andn	outa , __x03scl
		andn	outa , __x02sda
\
		jmpret	__x0Fdelayret , # __x0Edelay/2
\
		jexit
\
;asm _eeread

max_coghere W@ _asmaddr W@ max max_coghere W!

\
\ _dictsearch ( nfa cstr -- n1) nfa - addr to start searching in the dictionary, cstr - the counted string to find
\	n1 - nfa if found, 0 if not found, a fast assembler routine
\
build_BootOpt :rasm
		spopt
		mov	$C_treg5 , $C_treg1
__x03
		mov	$C_treg6 , $C_stTOS
\
		rdbyte	$C_treg2 , $C_treg1
		and	$C_treg2 , # h1F
		add	$C_treg1 , # 1
\
		rdbyte	$C_treg4 , $C_stTOS
		and	$C_treg4 , # h1F
		mov	$C_treg3 , $C_treg2
		add	$C_treg2 , # 1
\		
		jmp	# __x02
\		
__x01
		rdbyte	$C_treg3 , $C_treg1
		add	$C_treg1 , # 1
		add	$C_stTOS , # 1
		rdbyte	$C_treg4 , $C_stTOS
__x02
		cmp	$C_treg3 , $C_treg4		wz
	if_z	djnz	$C_treg2 , # __x01
\		
		mov	$C_stTOS , $C_treg6
	if_z	jexit
\
		sub	$C_treg6 , # h2
		rdword	$C_stTOS , $C_treg6		wz
	if_z	jexit
		mov	$C_treg1 , $C_treg5
		jmp	# __x03			
\
;asm _dictsearch

wvariable max_coghere coghere W@ max_coghere W!

\
\
\ _eewrite ( c1 -- t/f ) write c1 to the eeprom, true if there was an error
\
\
build_BootOpt :rasm
		jmp	# __x0C
__x02sda
		h20000000
__x03scl
		h10000000
__x04delay/2
		hD
\ this delay makes for a 400kHZ clock on an 80 Mhz prop
\
__x0Edelay/2
		mov	$C_treg6 , __x04delay/2
__x0D
		djnz	$C_treg6 , # __x0D
__x0Fdelayret
		ret
\
__x0C
		mov	$C_treg3 , # h8
\		
__x0B
		test	$C_stTOS , # h80	wz
		muxnz	outa , __x02sda
\
		jmpret	__x0Fdelayret , # __x0Edelay/2
\
		or	outa , __x03scl
\
		jmpret	__x0Fdelayret , # __x0Edelay/2
		jmpret	__x0Fdelayret , # __x0Edelay/2
\
		andn	outa , __x03scl
		shl	$C_stTOS , # 1
\
		jmpret	__x0Fdelayret , # __x0Edelay/2
\
		djnz	$C_treg3 , # __x0B
\
		andn	dira , __x02sda
		test	__x02sda , ina	wz
		muxnz	$C_stTOS , $C_fLongMask
\
		jmpret	__x0Fdelayret , # __x0Edelay/2
\
		or	outa , __x03scl
\
		jmpret	__x0Fdelayret , # __x0Edelay/2
		jmpret	__x0Fdelayret , # __x0Edelay/2
\
		andn	outa , __x03scl
\
		jmpret	__x0Fdelayret , # __x0Edelay/2
		andn	outa , __x02sda
		or	dira , __x02sda
\
\
		jexit
\
;asm _eewrite

max_coghere W@ _asmaddr W@ max max_coghere W!

\
\ _accept ( -- n1) 
\
\
build_BootOpt :rasm
\
\ $C_treg2 - pad start
\ $C_treg3 - loop count
\ $C_stTOS - pad ptr
\`$C_treg6 - (io+2)
\
		spush
\
\ output pointer
\
		mov	$C_treg2 , par
		add	$C_treg2 , # h2
		rdword	$C_treg6 , $C_treg2
\
\ if state has no echo bit on, offset DF 
\
		add	$C_treg2 , # _vstate-2
		rdbyte	$C_treg1 , $C_treg2
		test	$C_treg1 , # h8	wz
	if_nz	mov	$C_treg6 , # 0
\
\ point to pad + 1
\
		sub	$C_treg2 , # _vstate-vpad+1
\
		mov	$C_stTOS , $C_treg2
		mov	$C_treg3 , # _vpadsize-2
\
\
\ read a character into $C_treg4
\
__x01
		rdword	$C_treg4 , par
		test	$C_treg4 , # h100	wz
	if_nz	jmp	# __x01
		mov	$C_treg1 , # h100
		wrword	$C_treg1 , par
\
\ cr, we are done
\
		cmp	$C_treg4 , # hD wz
	if_z	mov	$C_treg3 , # 1
	if_z	jmp	# __x04
\
\ bs?
\
		cmp	$C_treg4 , # h8 wz
	if_z	jmp	# __x03
\
\
\ normal char	
\
		min	$C_treg4 , # h20
\
		wrbyte	$C_treg4 , $C_stTOS
		add	$C_stTOS , # 1
		jmp	# __x04
\
\
\ $C_treg2 - pad start
\ $C_treg3 - loop count
\ $C_treg4 - char
\ $C_stTOS - pad ptr
\`$C_treg6 - (io+2)
\
\ process backspace
\
__x03
\
		jmpret	__x0F , # __x0E
		mov	$C_treg4 , # h20
		jmpret	__x0F , # __x0E
\
		sub	$C_stTOS , # 1
		min	$C_stTOS , $C_treg2
		wrbyte	$C_treg4 , $C_stTOS
\
		add	$C_treg3 , # h2
		max	$C_treg3 , # _vpadsize-2
\
		mov	$C_treg4 , # h8
\
__x04
		jmpret	__x0F , # __x0E
\
		djnz	$C_treg3 , # __x01
\
		sub	$C_stTOS , $C_treg2
		jexit
\
\
\
\ emit char in $C_treg4, $C_treg6 is ptr to io channel 
\
__x0E
		cmp	$C_treg6 , # 0 	wz
	if_z	jmp	# __x0F
__x06
		rdword	$C_treg1 , $C_treg6
		test	$C_treg1 , # h100	wz
	if_z	jmp	# __x06
\
		wrword	$C_treg4 , $C_treg6
__x0F
		ret
;asm _accept

max_coghere W@ _asmaddr W@ max max_coghere W!

\
\
\ : t accept cr pad padsize bounds do i L@ .long space 4 +loop cr ;
\
\
\
\
\
\ _toq ( value addr -- t/f) true if successful
\
\
\ queue structure, must be long aligned
\
\ byte 0 - head
\ byte 1 - tail
\ byte 2 - # elements
\ byte 3 - flags , xxxx_xx00 - byte queue,  xxxx_xx01 - word queue, xxxx_xx10 - long queue
build_BootOpt :rasm
	mov	$C_treg6 , $C_stTOS
	spop
	jmpret	__toq_ret , # __toq

	jexit

\
\ INPUTS:
\ stTOS - data
\ treg6 - addr
\
\ OUTPUTS:
\ stTOS - t/f
\
\ USES:
\ treg1 - addr working
\ stTOS - data
\ treg2 - head
\ treg3 - tail
\ treg4 - size
\ treg5 - newhead
\ treg6 - addr
__toq
	rdlong	$C_treg1 , $C_treg6

	mov	$C_treg2 , $C_treg1
	and	$C_treg2 , # hFF

	mov	$C_treg3 , $C_treg1
	shr	$C_treg3 , # h8
	and	$C_treg3 , # hFF

	mov	$C_treg4 , $C_treg1
	shr	$C_treg4 , # h10
	and	$C_treg4 , # hFF

	mov	$C_treg5 , $C_treg2
	add	$C_treg5 , # 1

	cmp	$C_treg5 , $C_treg4	wz wc
 if_ae	mov	$C_treg5 , # 0

	cmp	$C_treg5 , $C_treg3	wz
 if_e	mov	$C_stTOS , # 0
 if_e	jmp	# __toq_ret
\
\ treg4 - flags
\
	mov	$C_treg4 , $C_treg1
	shr	$C_treg4 , # h18
	and	$C_treg4 , # h3

	shl	$C_treg2 , $C_treg4
	add	$C_treg2 , # 4
	add	$C_treg2 , $C_treg6

	test	$C_treg4 , # 3		wz
 if_z	wrbyte	$C_stTOS , $C_treg2
	test	$C_treg4 , # 1		wz
 if_nz	wrword	$C_stTOS , $C_treg2
	test	$C_treg4 , # 2		wz
 if_nz	wrlong	$C_stTOS , $C_treg2

	neg	$C_stTOS , # 1
	wrbyte	$C_treg5 , $C_treg6
__toq_ret
	ret
;asm _toq

max_coghere W@ _asmaddr W@ max max_coghere W!

\ _frq ( addr -- value true | addr false) true if successful
\
\
\ queue structure, must be long aligned
\
\ byte 0 - head
\ byte 1 - tail
\ byte 2 - # elements
\ byte 3 - flags , xxxx_xx00 - byte queue,  xxxx_xx01 - word queue, xxxx_xx10 - long queue

build_BootOpt :rasm
	mov	$C_treg6 , $C_stTOS
	jmpret	__frq_ret , # __frq

	spush
	mov	$C_stTOS , $C_treg5
	jexit
\
\ INPUTS:
\ treg6 - addr
\
\ OUTPUTS:
\ stTOS - data
\ treg5 - flag
\
\ USES:
\ treg1 - addr working
\ stTOS - data
\ treg2 - head
\ treg3 - tail
\ treg4 - size | flags
\ treg5 - newtail
\ treg6 - addr
__frq
	rdlong	$C_treg1 , $C_treg6

	mov	$C_treg2 , $C_treg1
	and	$C_treg2 , # hFF

	mov	$C_treg3 , $C_treg1
	shr	$C_treg3 , # h8
	and	$C_treg3 , # hFF

	cmp	$C_treg2 , $C_treg3	wz
 if_e	mov	$C_treg5 , # 0
 if_e	jmp	# __frq_ret
\
\ treg4 - flags
\
	mov	$C_treg4 , $C_treg1
	shr	$C_treg4 , # h18
	and	$C_treg4 , # h3

	mov	$C_treg5 , $C_treg3

	shl	$C_treg3 , $C_treg4
	add	$C_treg3 , # 4
	add	$C_treg3 , $C_treg6

	test	$C_treg4 , # 3		wz
 if_z	rdbyte	$C_stTOS , $C_treg3
	test	$C_treg4 , # 1		wz
 if_nz	rdword	$C_stTOS , $C_treg3
	test	$C_treg4 , # 2		wz
 if_nz	rdlong	$C_stTOS , $C_treg3

\
\ treg4 - size
\
	mov	$C_treg4 , $C_treg1
	shr	$C_treg4 , # h10
	and	$C_treg4 , # hFF

	add	$C_treg5 , # 1

	cmp	$C_treg5 , $C_treg4	wz wc
 if_ae	mov	$C_treg5 , # 0
	add	$C_treg6 , # 1

	wrbyte	$C_treg5 , $C_treg6
	sub	$C_treg6 , # 1
	neg	$C_treg5 , # 1
__frq_ret
	ret

;asm _frq

max_coghere W@ _asmaddr W@ max max_coghere W!

build_BootOpt :rasm
\
\ slice ( -- )
\
	rpop
	cmp	$C_this , # 0 wz
 if_z	jmp	# __nothis

	rdbyte	$C_treg1 , $C_this
	add	$C_this , # 1
	cmp	$C_treg1 , $C_stPtr	wz
	rdbyte	$C_treg1 , $C_this

 if_ne	mov	$C_treg6 , # 5
 if_ne	jmp	# $C_a_reset

	cmp	$C_treg1 , $C_rsPtr	wz
 if_ne	mov	$C_treg6 , # 6
 if_ne	jmp	# $C_a_reset

	add	$C_this , # 3
	rdlong	$C_treg1 , $C_this
	add	$C_this , # 4
	mov	$C_treg3 , cnt
	rdlong	$C_treg2 , $C_this

	sub	$C_treg3 , $C_treg1
	abs 	$C_treg4 , $C_treg3
	min	$C_treg2 , $C_treg4

	wrlong	$C_treg2 , $C_this
	sub	$C_this , # 8

\	sub	$C_this , # 6
\	wrword	$C_treg5 , $C_this
\	sub	$C_this , # 2
	
	
__nothis
	and	$C_this , $C_fAddrMask
	shl	$C_this , # h_10
	or	$C_treg5 , $C_this
	

__waitlock
	lockset	__sliceLock wc
 if_c	jmp	# __waitlock

\
\ INPUTS:
\ treg5 - data
\ stTOS - addr
\
\ USES:
\ treg1 - addr working
\ stTOS - data
\ treg2 - head
\ treg3 - tail
\ treg4 - size
\ stTOS - addr

	rdlong	$C_treg1 , __sliceQ

	mov	$C_treg2 , $C_treg1
	and	$C_treg2 , # hFF

	mov	$C_treg3 , $C_treg1
	shr	$C_treg3 , # h8
	and	$C_treg3 , # hFF

	mov	$C_treg4 , $C_treg1
	shr	$C_treg4 , # h10
	and	$C_treg4 , # hFF

	mov	$C_treg1 , $C_treg2
	shl	$C_treg1 , # 2
	add	$C_treg1 , # 4
	add	$C_treg1 , __sliceQ
	wrlong	$C_treg5 , $C_treg1

	mov	$C_treg1 , $C_treg3
	shl	$C_treg1 , # 2
	add	$C_treg1 , # 4
	add	$C_treg1 , __sliceQ

	add	$C_treg2 , # 1
	add	$C_treg3 , # 1

	rdlong	$C_IP , $C_treg1

	cmp	$C_treg2 , $C_treg4	wz wc
 if_ae	mov	$C_treg2 , # 0

	cmp	$C_treg3 , $C_treg4	wz wc
 if_ae	mov	$C_treg3 , # 0

	shl	$C_treg3 , # h8
	or	$C_treg2 , $C_treg3

	wrword	$C_treg2 , __sliceQ


	mov	$C_this , $C_IP
	and	$C_IP , $C_fAddrMask
	shr	$C_this , # h_10	wz


	lockclr __sliceLock

 if_z	jmp	# __nothis_exit

	mov	$C_treg1 , par
	add	$C_treg1 , # $V_errdata
	wrword	$C_this , $C_treg1

	
	wrbyte	$C_stPtr , $C_this
	add	$C_this , # 1
	wrbyte	$C_rsPtr , $C_this

	add	$C_this , # 3
	mov	$C_treg1 , cnt
	wrlong	$C_treg1 , $C_this
	sub	$C_this , # 4
__nothis_exit

	jnext

__sliceLock
	sliceLock
__sliceQ
	sliceQ
;asm slice

max_coghere W@ _asmaddr W@ max max_coghere W!


build_BootOpt :rasm
\
\ gc1 ( -- )
\
\
\ INPUTS:
\
\ USES:
\ treg1 - addr working
\ treg2 - head
\ treg3 - tail
\ treg4 - size
\ treg5 - this
\ treg6 - working
__waitlock
	lockset	__sliceLock wc
 if_c	jmp	# __waitlock

	rdlong	$C_treg1 , __bgQ
	mov	$C_treg2 , $C_treg1
	and	$C_treg2 , # hFF

	mov	$C_treg3 , $C_treg1
	shr	$C_treg3 , # h8
	and	$C_treg3 , # hFF

	mov	$C_treg4 , $C_treg1
	shr	$C_treg4 , # h10
	and	$C_treg4 , # hFF

	mov	$C_treg1 , $C_treg3
	shl	$C_treg1 , # 1
	add	$C_treg1 , # 4
	add	$C_treg1 , __bgQ
	rdword	$C_treg5 , $C_treg1

	rdbyte	$C_treg1 , $C_treg5	wz

	mov	$C_treg1 , $C_treg2
	shl	$C_treg1 , # 1
	add	$C_treg1 , # 4
	add	$C_treg1 , __bgQ

	add	$C_treg3 , # 1
 if_nz	add	$C_treg2 , # 1
 if_nz	wrword	$C_treg5 , $C_treg1

	cmp	$C_treg2 , $C_treg4	wz wc
 if_ae	mov	$C_treg2 , # 0

	cmp	$C_treg3 , $C_treg4	wz wc
 if_ae	mov	$C_treg3 , # 0

	shl	$C_treg3 , # h8
	or	$C_treg2 , $C_treg3

	wrword	$C_treg2 , __bgQ

	lockclr __sliceLock
	jexit

__sliceLock
	sliceLock
__bgQ
	bgQ
;asm gc1

max_coghere W@ _asmaddr W@ max max_coghere W!
\
build_BootOpt :rasm
	mov	$C_treg3 , $C_stTOS
	spop
	mov	$C_treg4 , $C_stTOS
	mov	$C_stTOS , $C_fLongMask

	mov	$C_treg1 , par
	add	$C_treg1 , # $V_base
	mov	$C_treg2 , # 0

	rdbyte	$C_treg5 , $C_treg4

	cmp	$C_treg5 , # h7A wz
 if_e	mov	$C_treg2 , # h40

	cmp	$C_treg5 , # h68 wz
 if_e	mov	$C_treg2 , # h10

	cmp	$C_treg5 , # h64 wz
 if_e	mov	$C_treg2 , # hA

	cmp	$C_treg5 , # h62 wz
 if_e	mov	$C_treg2 , # h2

	cmp	$C_treg2 , # 0	wz
 if_e	rdword	$C_treg2 , $C_treg1

 if_ne	add	$C_treg4 , # 1
 if_ne	sub	$C_treg3 , # 1

	rdbyte	$C_treg5 , $C_treg4
	cmp	$C_treg5 , # h2D wz
 if_e	add	$C_treg4 , # 1
 if_e	sub	$C_treg3 , # 1

__lp
	rdbyte	$C_treg5 , $C_treg4
	add	$C_treg4 , # 1
	cmp	$C_treg5 , # h5F wz
 if_z	jmp	# __con1 wz	

	sub	$C_treg5 , # h30
	cmps	$C_treg5 , # 9 wz wc

 if_be	jmp	# __todig1
	sub	$C_treg5 , # 7
	cmps	$C_treg5 , # hA wz wc
 if_b	mov	$C_treg5 , $C_fLongMask
__todig1

	cmps	$C_treg5 , # h26 wz wc
 if_be	jmp	# __todig2
	sub	$C_treg5 , # 3
	cmps	$C_treg5 , # h27 wz wc
 if_b	mov	$C_treg5 , $C_fLongMask
__todig2
	

	cmp	$C_treg5 , $C_treg2 wz wc
 if_b	mov	$C_treg5 , $C_fLongMask
 if_ae	mov	$C_treg5 , # 0

	and	$C_stTOS , $C_treg5 wz
__con1
 if_nz	djnz	$C_treg3 , # __lp

	jexit
;asm xisnumber

max_coghere W@ _asmaddr W@ max max_coghere W!

\
\
build_BootOpt :rasm
	mov	$C_treg3 , $C_stTOS
	spop
	mov	$C_treg4 , $C_stTOS
	mov	$C_stTOS , # 0

	mov	$C_treg1 , par
	add	$C_treg1 , # $V_base
	mov	$C_treg2 , # 0

	rdbyte	$C_treg5 , $C_treg4

	cmp	$C_treg5 , # h7A wz
 if_e	mov	$C_treg2 , # h40

	cmp	$C_treg5 , # h68 wz
 if_e	mov	$C_treg2 , # h10

	cmp	$C_treg5 , # h64 wz
 if_e	mov	$C_treg2 , # hA

	cmp	$C_treg5 , # h62 wz
 if_e	mov	$C_treg2 , # h2

	cmp	$C_treg2 , # 0	wz
 if_e	rdword	$C_treg2 , $C_treg1

 if_ne	add	$C_treg4 , # 1
 if_ne	sub	$C_treg3 , # 1

	rdbyte	$C_treg5 , $C_treg4
	cmp	$C_treg5 , # h2D wz
 	muxz	$C_treg6 , $C_fLongMask
 if_e	add	$C_treg4 , # 1
 if_e	sub	$C_treg3 , # 1

__lp
	rdbyte	$C_treg5 , $C_treg4
	add	$C_treg4 , # 1
	cmp	$C_treg5 , # h5F wz
 if_z	jmp	# __con1	

	sub	$C_treg5 , # h30
	cmps	$C_treg5 , # 9 wz wc

 if_be	jmp	# __todig1
	sub	$C_treg5 , # 7
	cmps	$C_treg5 , # hA wz wc
 if_b	mov	$C_treg5 , $C_fLongMask
__todig1

	cmps	$C_treg5 , # h26 wz wc
 if_be	jmp	# __todig2
	sub	$C_treg5 , # 3
	cmps	$C_treg5 , # h27 wz wc
 if_b	mov	$C_treg5 , $C_fLongMask
__todig2
	mov	$C_treg1 , $C_stTOS
	mov	$C_stTOS , $C_treg5
	mov	$C_treg5 , $C_treg2

__ml
	shr	$C_treg5 , # 1 wc  wz
 if_c	add	$C_stTOS , $C_treg1
	shl	$C_treg1 , # 1
 if_nz	jmp	# __ml
	
	
__con1
 	djnz	$C_treg3 , # __lp

	cmp	$C_treg6 , # 0 wz
 if_nz	neg	$C_stTOS , $C_stTOS

	jexit
;asm xnumber

max_coghere W@ _asmaddr W@ max max_coghere W!

\
base W@ hex
c" : init_coghere " .cstr h68 emit max_coghere W@ . c" coghere W! ;~h0D" .cstr
h68 emit build_BootOpt . c" wconstant build_BootOpt~h0D" .cstr
h68 emit build_BootOpt1 . c" wconstant build_BootOpt1~h0D" .cstr
h68 emit build_BootOpt2 . c" wconstant build_BootOpt2~h0D" .cstr
h68 emit build_BootOpt3 . c" wconstant build_BootOpt3~h0D~h0D" .cstr

base W!
