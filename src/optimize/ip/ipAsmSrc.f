hA state orC!


build_BootOpt :rasm
		jmp	# __x0C
__x01v_df00
	hDF00
__x02v_dfff
	hDFFF
__x03v_5f00
	h5F00
__x04v_4700
	h4700
__x05v_5c00
	h5C00
__x06v_5d00
	h5D00
__x07v_1400
	h1400
__x08v_5e00
	h5E00

__x0C
	spush

	mov	outa , __x03v_5f00
	mov	dira , __x01v_df00

	mov	outa , __x04v_4700

	mov	$C_stTOS , # hFF 
	and	$C_stTOS , ina

	mov	outa , __x05v_5c00

	jexit

;asm a__ip_rddr


build_BootOpt :rasm
		jmp	# __x0C
__x01v_df00
	hDF00
__x02v_dfff
	hDFFF
__x03v_5f00
	h5F00
__x04v_4700
	h4700
__x05v_5c00
	h5C00
__x06v_5d00
	h5D00
__x07v_1400
	h1400
__x08v_5e00
	h5E00

__x0C
	mov	$C_treg1 , $C_stTOS
	shr	$C_treg1 , # h8
	and	$C_treg1 , # hFF

	or	$C_treg1 , __x06v_5d00
	mov	outa , $C_treg1

	mov	dira , __x02v_dfff

	andn	$C_treg1 , __x07v_1400
	mov	outa , $C_treg1

	and	$C_stTOS , # hFF
	or	$C_stTOS , __x08v_5e00
	mov	outa , $C_stTOS

	andn	$C_stTOS , __x07v_1400
	mov	outa , $C_stTOS

	spop
	mov	outa , __x05v_5c00

	jexit

;asm a__ip_wridm



build_BootOpt :rasm
		jmp	# __x0C
__x01v_df00
	hDF00
__x02v_dfff
	hDFFF
__x03v_5f00
	h5F00
__x04v_4700
	h4700
__x05v_5c00
	h5C00
__x06v_5d00
	h5D00
__x07v_1400
	h1400
__x08v_5e00
	h5E00

__x0C
	and	$C_stTOS , # hFF
	or	$C_stTOS , __x03v_5f00

	mov	outa , $C_stTOS
	mov	dira , __x02v_dfff

	andn	$C_stTOS , __x07v_1400
	mov	outa , $C_stTOS

	spop

	mov	outa , __x05v_5c00

	jexit

;asm a__ip_wrdr

build_BootOpt :rasm
\
\ _treg1 - pointer to the current socket structure
\ _treg2 - pointer to the current io channel
\ _treg3 - current io word read
\
	spopt
	mov	$C_treg2 , $C_stTOS

	rdword	$C_treg3 , $C_treg2
	mov	$C_stTOS , $C_treg3		
	spush

	test	$C_stTOS , # h100 wz
	muxz	$C_stTOS , $C_fLongMask

 if_nz	jexit

	cmp	$C_treg3 , # h_D wz
\
\ h_1A is the offset of _ip_sockstatus
\
 if_z	add	$C_treg1 , # h_1A
 if_z	rdword	$C_treg4 , $C_treg1
\
\ h_100 - is the expandcr flag bit 
\
 if_z	test	$C_treg4 , # h_100 wz
 
 if_nz	mov	$C_treg3 , # h_100
 if_z	mov	$C_treg3 , # h_0A
 	wrword	$C_treg3 , $C_treg2

	jexit

;asm a__ip_fkeyq


build_BootOpt :rasm
	add	$C_stTOS , # h2

	rdword	$C_treg1 , $C_stTOS	wz
 if_z	muxz	$C_stTOS , $C_fLongMask
 if_z	jnext

	rdword	$C_stTOS , $C_treg1
	and	$C_stTOS , # h100 wz
	muxnz	$C_stTOS , $C_fLongMask
	jexit
;asm a__ip_emitq


build_BootOpt :rasm
	add	$C_stTOS , # h2

	rdword	$C_treg1 , $C_stTOS	wz
 if_nz	jmp	# __x0F
	spop
	spop
 	jexit
__x0F
	rdword	$C_stTOS , $C_treg1
	and	$C_stTOS , # h100 wz
 if_z	jmp	# __x0F
	spop
	wrword	$C_stTOS , $C_treg1
	spop
	jexit
;asm a__ip_emit


hA state orC!

{

lockdict create a__ip_rddr forthentry
$C_a_lxasm w, h10E  hFD  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z1SV046 l, zDv0 l, zDyy l, z5v0 l, z4S0 l, z5j0 l, z5n0 l, z1G0 l,
z5r0 l, z1SyL2Y l, z2Wix[0 l, z2Wixmx l, z2Wix[1 l, z2WyOuy l, z1WiOyl l, z2Wix[2 l,
z1SV01k l,
freedict




lockdict create a__ip_wridm forthentry
$C_a_lxasm w, h116  hFD  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z1SV046 l, zDv0 l, zDyy l, z5v0 l, z4S0 l, z5j0 l, z5n0 l, z1G0 l,
z5r0 l, z2WiP37 l, zbyP08 l, z1WyP3y l, z1biP43 l, z2WixZ8 l, z2Wixmy l, z1[iP44 l,
z2WixZ8 l, z1WyOuy l, z1biOv5 l, z2WixZ7 l, z1[iOv4 l, z2WixZ7 l, z1SyMtk l, z2Wix[2 l,
z1SV01k l,
freedict




lockdict create a__ip_wrdr forthentry
$C_a_lxasm w, h10F  hFD  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z1SV046 l, zDv0 l, zDyy l, z5v0 l, z4S0 l, z5j0 l, z5n0 l, z1G0 l,
z5r0 l, z1WyOuy l, z1biOv0 l, z2WixZ7 l, z2Wixmy l, z1[iOv4 l, z2WixZ7 l, z1SyMtk l,
z2Wix[2 l, z1SV01k l,
freedict




lockdict create a__ip_fkeyq forthentry
$C_a_lxasm w, h10D  hFD  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z1SyMtj l, z2WiPB7 l, z4iPJ9 l, z2WiOuA l, z1SyL2Y l, z1YVOv0 l, z1riOu2 l, z1SL01k l,
z26VPGD l, z20tP0Q l, z4dPR8 l, z1YQPS0 l, z2WoPK0 l, z2WtPGA l, z4FPJ9 l, z1SV01k l,

freedict




lockdict create a__ip_emitq forthentry
$C_a_lxasm w, h105  hFD  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z20yOr2 l, z6iP37 l, z1rdOu2 l, z1SQ01m l, z4iOu8 l, z1YyOv0 l, z1viOu2 l, z1SV01k l,

freedict




lockdict create a__ip_emit forthentry
$C_a_lxasm w, h10A  hFD  1- tuck - h9 lshift or here W@ alignl h10 lshift or l,
z20yOr2 l, z6iP37 l, z1SL043 l, z1SyMtk l, z1SyMtk l, z1SV01k l, z4iOu8 l, z1YyOv0 l,
z1SQ043 l, z1SyMtk l, z4FOu8 l, z1SyMtk l, z1SV01k l,
freedict

}
