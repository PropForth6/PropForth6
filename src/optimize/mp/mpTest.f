: gc mpGCStart delms mpGCStop mpMon drop ;



wvariable fq 0 fq W!
\
\ send ( startval count -- )
: send
	fq W@ 0<>
	if
		0 do
			dup fq W@ 

			begin 2dup _toq until 2drop
			1+ dup 0=
			if
				leave
			then
		loop
	else
		drop
	then
	drop
;
	
((( lim_t
defL mcount

::: lim_X
	mpInit
	0 mcount!
	begin
		mcount@ 1+ mcount!
		slice
		mcount@ d_100_000 >
	until
	mp-
;

)))

\ lim_t y
\ y mp+
\ : t y setThis mcount@ . ;


((( ERR_t
defW errIndex
defW iteration

: ERR1 ERR ;
: ERR2 ERR ;
: ERR3 ERR ;

::: ERR_X
	mpInit
	iteration@ 1+ iteration!
	begin
		slice
		cogid 0=
		if
			errIndex@ 1+ dup 3 > if drop 1 then errIndex!
			>dbg iteration@ . errIndex@ . xdbg
			errIndex@ 1 = if
				ERR1
			else errIndex@ 2 = if
				ERR2
			else errIndex@ 3 = if
				ERR3
			else
				ERR
		thens
	0 until
	mp-
;

)))



((( ERR2_t
reuseW errIndex
reuseW iteration
defW cogIndex
defW eCog


::: ERR_X2
	mpInit
	iteration@ 1+ iteration!
	begin
		slice
		cogIndex@ eCog@ = if cogIndex@ 1+ cogIndex! then
		cogid cogIndex@ =
		if
			errIndex@ 1+ dup 7 >=
			if
				cogIndex@ 1+ cogIndex! drop 0 errIndex!
			else
				errIndex!
				>dbg  iteration@ . cogIndex@ . errIndex@ . xdbg
				errIndex@ 1 = if
					begin 1 0 until
				else errIndex@ 2 = if
					begin 1 >r 0 until
				else errIndex@ 3 = if
					begin drop 0 until
				else errIndex@ 4 = if
					begin r> drop 0 until
				else errIndex@ 5 = if
					1
				else errIndex@ 6 = if
					1 >r
				else
					ERR
			
		thens
		cogIndex@ 7 >=
		if
			0 cogIndex!
			0 errIndex!
		then
		0	
	until
	mp-
;

)))


ERR_t err
: errt
	err setThis 0 errIndex! 0 iteration!
	d_10 0
	do
		i . err mp+
		d_10 0
		do
			d200 delms
			mpST@ 0=
			if
				leave
			then
		loop
	loop
	." ~h0Derrt DONE~h0D"
;

ERR2_t err2
: err2t
	err2 setThis  cogid eCog! 0 errIndex! 0 cogIndex! 0 iteration!
	d_150 0
	do
		i . err2 mp+
		d_10 0
		do
			d200 delms
			mpST@ 0=
			if
				leave
			then
		loop
	loop
	." ~h0Derr2t DONE~h0D"
;


((( w_t

defL sv

: _qa _qaf drop 1 >= ;
: _qf _qaf nip 1 >= ;

: <IN
	r> mpS0!
	begin
		inQ@ _qa
		if
			-1
		else
			slice 0
		then
	until
	mpS0@ >r
	inQ@ _frq 0= if ERR then
;

: OUT>
	r> mpS0!
	mpS1!
	begin
		outQ@ _qf
		if
			-1
		else
			slice 0
		then
	until
	mpS0@ >r
	mpS1@ outQ@ _toq 0= if ERR then
;

::: w_X
	mpInit
	begin
		<IN dup sv!
		OUT>
		sv@ -1 =
	until
	mp-
;

)))




((( null_t

::: null_X
	mpInit
	begin
		<IN >dbg dup . xdbg -1 =
	until
	mp-
;
	
)))




: .dc
	dup .cstr
;

: initW
	>nc
	numBG 1+ 0
	do
		
		." ~h0D3 defQ q" i <# # # # #> .cstr
	loop
	c" 000"
	numBG 0
	do
		." ~h0Dw_t w" .dc ."  w" .dc ."  setThis q" .dc ."  inQ! q" drop i 1+ <# # # # #> .dc ."  outQ!"	
	loop
	." ~h0Dnull_t null null setThis q" .cstr ."  inQ!~h0D: w+ null mp+"
	numBG 0
	do
		
		." ~h0Dw" i <# # # # #> .cstr ."  mp+" 	
	loop
	."  ;~h0Dq000 fq W!~h0D~h0D~h0D"
	xnc
;

{
\ : q?
\	sliceLock lock
\	base W@ hex sliceQ sliceQSize 8 + dump base W!  
\	sliceLock unlock
\ ;

1 gc

initW

w+

mpMon mpRes

10 10 send 1000 delms mpMon
-10 10 send 1000 delms mpMon

1 gc 5 gc 10 gc 100 gc


c" -1 0 1 2 3 4 5" 5 cogx
c" -1 0 1 2 3 4" 4 cogx
c" -1 0 1 2 3" 3 cogx
c" -1 0 1 2" 2 cogx
c" -1 0 1" 1 cogx
c" -1 0" 0 cogx


errt
err2t

}
