\
\
\ _la_asample41+ ( baseaddr numsamples samplecycle triggerbefore triggerafter triggermask -- numsamples)
build_BootOpt :rasm
\ trigger mask
	mov	$C_treg6 , $C_stTOS
	spop
\ trigger after
	mov	$C_treg5 , $C_stTOS
	spop
\ trigger before
	mov	$C_treg4 , $C_stTOS
	spop

\ sample cycle
	mov	$C_treg3 , $C_stTOS
	spop

\ num samples
	mov	$C_treg2 , $C_stTOS
	spop

\ base address - $C_treg1
	mov	$C_treg1 , $C_stTOS

	mov	$C_stTOS , $C_treg2
\	 
\ $C_treg1 - baseaddr
\ $C_treg2 - numsamples
\ $C_treg3 - samplecycle
\ $C_treg4 - triggerbefore
\ $C_treg5 - triggerafter
\ $C_treg6 - triggermask
\
\
\ wait for trigger
\
	waitpeq $C_treg4 , $C_treg6
	waitpeq $C_treg5 , $C_treg6
\
\ get the sample and set up the count for the next sample 
\
\
\                                               t = 0
	mov	$C_treg6 , ina
\                                               t = 4
	mov	$C_treg5 , cnt
\                                               t = 8
	add	$C_treg5 , $C_treg3
\
\ $C_treg1 - baseaddr
\ $C_treg2 - numsamples
\ $C_treg3 - samplecycle
\ $C_treg4 - triggerbefore
\ $C_treg5 - nextcounttosample
\ $C_treg6 - current sample
\
__1
\
\ write out the sample
\
\                                               t = 12
	wrlong	$C_treg6 , $C_treg1
\
\ wait for the next sample time
\
\                                               t = 20 - 35
	waitcnt $C_treg5 , $C_treg3
\                                               t = 26 - 41
\                                                            t = 0
	mov	$C_treg6 , ina	
\                                                            t = 4
	add	$C_treg1 , # 4
\                                                            t = 8
	djnz	$C_treg2 , # __1
\                                                            t = 12

\ we are done
	jexit
\
;asm _la_asample41+


\ _la_asample18+ ( baseaddr numsamples samplecycle triggerbefore triggerafter triggermask -- numsamples )
build_BootOpt :rasm
\ trigger mask
	mov	$C_treg6 , $C_stTOS
	spop
\ trigger after
	mov	$C_treg5 , $C_stTOS
	spop
\ trigger before
	mov	$C_treg4 , $C_stTOS
	spop

\ sample cycle
	mov	$C_treg3 , $C_stTOS
	spop

\ num samples
\	mov	$C_treg2 , $C_stTOS
	spop

\ base address - $C_treg1
	mov	$C_treg1 , $C_stTOS

	mov	$C_treg2 , # par
	sub	$C_treg2 , # __buffer
	mov	$C_stTOS , $C_treg2
\	 
\ $C_treg1 - baseaddr
\ $C_treg2 - numsamples
\ $C_treg3 - samplecycle
\ $C_treg4 - triggerbefore
\ $C_treg5 - triggerafter
\ $C_treg6 - triggermask
\
\
\ wait for trigger
\
	waitpeq $C_treg4 , $C_treg6
	waitpeq $C_treg5 , $C_treg6
\
\ get the sample and set up the count for the next sample 
\
\
\                                               t = 0
	mov	__buffer , ina
\                                               t = 4
	mov	$C_treg5 , cnt
\                                               t = 8
	add	$C_treg5 , $C_treg3
\
\ $C_treg1 - baseaddr
\ $C_treg2 - numsamples
\ $C_treg3 - samplecycle
\ $C_treg4 - triggerbefore
\ $C_treg5 - nextcounttosample
\ $C_treg6 - current sample
\
__1
\
\ wait for the next sample time
\
\                                               t = 12
	waitcnt $C_treg5 , $C_treg3
\                                               t = 18
\                                                            t = 0
__2
	mov	__buffer1 , ina	
\                                                            t = 4
	add	__2 , $C_fDestInc
\                                                            t = 8
	djnz	$C_treg2 , # __1
\                                                            t = 12

	mov	$C_treg2 , $C_stTOS
__3
	wrlong	__buffer , $C_treg1


	add	__3 , $C_fDestInc
	add	$C_treg1 , # 4

	djnz	$C_treg2 , # __3


\ we are done
	jexit
__buffer
 0
__buffer1
 0
\
;asm _la_asample18+







\ _la_asample4 ( baseaddr numsamples samplecycle triggerbefore triggerafter triggermask -- numsamples )
build_BootOpt :rasm
\ trigger mask
	mov	$C_treg6 , $C_stTOS
	spop
\ trigger after
	mov	$C_treg5 , $C_stTOS
	spop
\ trigger before
	mov	$C_treg4 , $C_stTOS
	spop

\ sample cycle
	spop

\ num samples
	spop

\ base address - $C_treg1
	mov	$C_treg1 , $C_stTOS

	mov	$C_treg2 , # par
	sub	$C_treg2 , # 1
	movd	__3 , $C_treg2

	sub	$C_treg2 , # __buffer
	mov	$C_stTOS , $C_treg2

__1
	mov	__buffer , __inainst
__2
	movd	__buffer , # __buffer
	add	__1 , $C_fDestInc
	add	__2 , $C_fDestInc
	add	__2 , # 1
	djnz	$C_treg2 , # __1


	movs	__jmpinst , # __4
__3
	mov	0 , __jmpinst

	jmp	# __sample
		
__4

	mov	$C_treg2 , $C_stTOS
__5
	wrlong	__buffer , $C_treg1


	add	__5 , $C_fDestInc
	add	$C_treg1 , # 4

	djnz	$C_treg2 , # __5


\ we are done
	jexit


__inainst
	hA0BC01F2
__jmpinst
	h5C7C0000
\
\ wait for trigger
\
__sample
	waitpeq $C_treg4 , $C_treg6
	waitpeq $C_treg5 , $C_treg6
__buffer
 0

\
;asm _la_asample4




\ _la_asample1 ( baseaddr startcount -- numsamples )
build_BootOpt :rasm
\ startcount
	mov	$C_treg6 , $C_stTOS
	spop

\ base address
	mov	$C_treg1 , $C_stTOS



	mov	$C_treg2 , # par
	sub	$C_treg2 , # 1
	movd	__3 , $C_treg2

	sub	$C_treg2 , # __buffer
	mov	$C_stTOS , $C_treg2

__1
	mov	__buffer , __inainst
__2
	movd	__buffer , # __buffer
	add	__1 , $C_fDestInc
	add	__2 , $C_fDestInc
	add	__2 , # 1
	djnz	$C_treg2 , # __1


	movs	__jmpinst , # __4
__3
	mov	0 , __jmpinst

	jmp	# __sample
		
__4

	mov	$C_treg2 , $C_stTOS
__5
	wrlong	__buffer , $C_treg1

	add	__5 , $C_fDestInc
	add	$C_treg1 , # h10

	djnz	$C_treg2 , # __5


\ we are done
	jexit


__inainst
	hA0BC01F2
__jmpinst
	h5C7C0000
\
\ wait for trigger
\
__sample
	waitcnt $C_treg6 , # 0
__buffer
 0

\
;asm _la_asample1

