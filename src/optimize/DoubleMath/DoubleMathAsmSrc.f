\
\
\ dum* ( u1lo u1hi u2lo u2hi -- u1*u2LL u1*u2LM u1*u2HM  u1*u2HH) \ unsigned 64 bit * 64bit -- 128 bit result
\
\
build_BootOpt :rasm
		mov	__u2LM , $C_stTOS
		spop
		mov	__u2LL , $C_stTOS
		spop

		mov	__u2HM , # 0
		mov	__u2HH , # 0

\ treg1 - u1hi
\ stTOS - u1lo
		spopt

\ treg2 - resLL
\ treg3 - resLM
\ treg4 - resHM
\ treg5 - resHH

		mov	$C_treg2 , # 0
		mov	$C_treg3 , # 0
		mov	$C_treg4 , # 0
		mov	$C_treg5 , # 0


__x01
		shr	$C_treg1 , # 1		wz wc
		rcr	$C_stTOS , # 1		wc
	if_z	cmp	$C_stTOS , # 0		wz

	if_nc	jmp     # __x02
\
		add	$C_treg2 , __u2LL	wc
		addx	$C_treg3 , __u2LM	wc
		addx	$C_treg4 , __u2HM	wc
		addx	$C_treg5 , __u2HH
__x02
\
		shl	__u2LL , # 1		wc
		rcl	__u2LM , # 1		wc
		rcl	__u2HM , # 1		wc
		rcl	__u2HH , # 1

	if_nz	jmp     # __x01
\		
		mov	$C_stTOS , $C_treg2
		spush
		mov	$C_stTOS , $C_treg3
		spush
		mov	$C_stTOS , $C_treg4
		spush
		mov	$C_stTOS , $C_treg5

		jexit
__u2LL
 0
__u2LM
 0
__u2HM
 0
__u2HH
 0
;asm dum*


\
\
\ dum/mod ( u1LL u1LM u1HM u1HH u2lo u2hi -- remainderlo remainderhi quotientlo quotienthi )
\ unsigned divide & mod  u1 divided by u2
\
build_BootOpt :rasm
		mov	$C_treg4 , $C_stTOS
		spop
		mov	__u2lo , $C_stTOS
		spop
\ u2hi - treg4
\ u1HH - treg3
\ u1MH - treg2
\ u1ML - treg1
\ u1LL - stTOS
\

		mov	$C_treg3 , $C_stTOS
		spop
		mov	$C_treg2 , $C_stTOS
		spop
                     
		spopt

		mov	$C_treg6 , # h80
		mov	__remlo , # 0
		mov	__remhi , # 0
\
__x01
		shl	$C_stTOS , # 1		wc
		rcl	$C_treg1 , # 1		wc
		rcl	$C_treg2 , # 1		wc
		rcl	$C_treg3 , # 1		wc
\                                                
		rcl	__remlo , # 1		wc
		rcl	__remhi , # 1		wc
\
	if_c	jmp	# __x02
\        
		cmp	__remlo , __u2lo	wz wc
		cmpx	__remhi , $C_treg4	wc
	if_c	mov	$C_treg5 , # 0
	if_c	jmp	# __x03
	
__x02
		sub	__remlo , __u2lo	wz wc
		subx	__remhi , $C_treg4
		mov	$C_treg5 , # 1
__x03
		rcr	$C_treg5 , # 1		wc

		rcl	__quolo , # 1		wc
		rcl	__quohi , # 1
                                  
		djnz	$C_treg6 , # __x01
\
		mov	$C_stTOS , __remlo
		spush
		mov	$C_stTOS , __remhi
		spush
		mov	$C_stTOS , __quolo
		spush
		mov	$C_stTOS , __quohi
		jexit

__u2lo
 0

__remlo
 0
__remhi
 0

__quolo
 0
__quohi
 0
;asm dum/mod


\
\ d+ ( n1lo n1hi n2lo n2hi -- n3lo n3hi ) n3 = n1+n2
build_BootOpt :rasm
\ n2hi
		mov	$C_treg3 , $C_stTOS
		spop
\ n2lo
		mov	$C_treg2 , $C_stTOS
		spop
\ n1hi	
		spopt
\
\ stTOS - n1lo
\ treg1 - n1hi
\ treg2 - n2lo
\ treg3 - n2hi
\
		add	$C_stTOS , $C_treg2		wc
		addsx	$C_treg1 , $C_treg3
\
		spush
		mov	$C_stTOS , $C_treg1		
\
		jexit
;asm d+


\
\ d- ( n1lo n1hi n2lo n2hi -- n3lo n3hi ) n3 = n1-n2
build_BootOpt :rasm
\ n2hi
		mov	$C_treg3 , $C_stTOS
		spop
\ n2lo
		mov	$C_treg2 , $C_stTOS
		spop
\ n1hi	
		spopt
\
\ stTOS - n1lo
\ treg1 - n1hi
\ treg2 - n2lo
\ treg3 - n2hi
\
		sub	$C_stTOS , $C_treg2		wz wc
		subsx	$C_treg1 , $C_treg3
\
		spush
		mov	$C_stTOS , $C_treg1		
\
		jexit
;asm d-


\
\ du> ( n1lo n1hi n2lo n2hi -- flag )
build_BootOpt :rasm
\ n2hi
		mov	$C_treg3 , $C_stTOS
		spop
\ n2lo
		mov	$C_treg2 , $C_stTOS
		spop
\ n1hi	
		spopt
\
\ stTOS - n1lo
\ treg1 - n1hi
\ treg2 - n2lo
\ treg3 - n2hi
\
		cmp	$C_stTOS , $C_treg2	wz wc
		cmpx	$C_treg1 , $C_treg3	wz wc
\
		mov	$C_stTOS , # 0
	if_a	mov	$C_stTOS , $C_fLongMask
\
		jexit
;asm du>


\
\ du< ( n1lo n1hi n2lo n2hi -- flag )
build_BootOpt :rasm
\ n2hi
		mov	$C_treg3 , $C_stTOS
		spop
\ n2lo
		mov	$C_treg2 , $C_stTOS
		spop
\ n1hi	
		spopt
\
\ stTOS - n1lo
\ treg1 - n1hi
\ treg2 - n2lo
\ treg3 - n2hi
\
		cmp	$C_stTOS , $C_treg2	wz wc
		cmpx	$C_treg1 , $C_treg3	wz wc	
\
		mov	$C_stTOS , # 0
	if_b	mov	$C_stTOS , $C_fLongMask
\
		jexit
;asm du<

\
\ du= ( n1lo n1hi n2lo n2hi -- n3lo n3hi ) n3 = n1-n2
build_BootOpt :rasm
\ n2hi
		mov	$C_treg3 , $C_stTOS
		spop
\ n2lo
		mov	$C_treg2 , $C_stTOS
		spop
\ n1hi	
		spopt
\
\ stTOS - n1lo
\ treg1 - n1hi
\ treg2 - n2lo
\ treg3 - n2hi
\
		cmp	$C_stTOS , $C_treg2	wz wc
		cmpx	$C_treg1 , $C_treg3	wz wc
\
		mov	$C_stTOS , # 0
	if_e	mov	$C_stTOS , $C_fLongMask
\
		jexit
;asm d=


\
\ du>= ( n1lo n1hi n2lo n2hi -- flag )
build_BootOpt :rasm
\ n2hi
		mov	$C_treg3 , $C_stTOS
		spop
\ n2lo
		mov	$C_treg2 , $C_stTOS
		spop
\ n1hi	
		spopt
\
\ stTOS - n1lo
\ treg1 - n1hi
\ treg2 - n2lo
\ treg3 - n2hi
\
		cmp	$C_stTOS , $C_treg2	wz wc
		cmpx	$C_treg1 , $C_treg3	wz wc
\
		mov	$C_stTOS , # 0
	if_ae	mov	$C_stTOS , $C_fLongMask
\
		jexit
;asm du>=


\
\ du<= ( n1lo n1hi n2lo n2hi -- flag )
build_BootOpt :rasm
\ n2hi
		mov	$C_treg3 , $C_stTOS
		spop
\ n2lo
		mov	$C_treg2 , $C_stTOS
		spop
\ n1hi	
		spopt
\
\ stTOS - n1lo
\ treg1 - n1hi
\ treg2 - n2lo
\ treg3 - n2hi
\
		cmp	$C_stTOS , $C_treg2	wz wc
		cmpx	$C_treg1 , $C_treg3	wz wc	
\
		mov	$C_stTOS , # 0
	if_be	mov	$C_stTOS , $C_fLongMask
\
		jexit
;asm du<=

