\ __tickCNTat ( addr_dticks _timelock --  countlo counthi )
\
build_BootOpt :rasm
	spopt
\
\ $C_treg1 - _timelock
\
__mainloop
		lockset	$C_treg1 wc
	if_c	jmp	# __mainloop
\
\ $C_stTOS - addr_dticks
\
	rdlong	$C_treg2 , $C_stTOS
	add	$C_stTOS , # d_4
	rdlong	$C_treg3 , $C_stTOS
	sub	$C_stTOS , # d_4

	mov	$C_treg4 , cnt
	wrlong	$C_treg4 , $C_stTOS
	cmp	$C_treg4 , $C_treg2 wz wc
	addx	$C_treg3 , # 0
	add	$C_stTOS , # d_4
	wrlong	$C_treg3 , $C_stTOS
	lockclr	$C_treg1

	mov	$C_stTOS , $C_treg4
	spush
	mov	$C_stTOS , $C_treg3
	jexit

;asm __tickCNTat
