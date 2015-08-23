

1 wconstant forthimagefence

wvariable savehere
wvariable savewlastnfa

wvariable checksum
wvariable bytecount

: _fb checksum W+! 1 bytecount W+! ;
: fbinout
	here W@ savehere W!
	wlastnfa W@ savewlastnfa W!
	c" forthimagefence" find drop pfa>nfa 2- dup here W!
	W@ wlastnfa W!
	0 _finit W!
	
	0 checksum W!
	0 bytecount W!
	
	0 5 C!	
	
	_cd 0
	do 
		i C@ _fb
		loop
		
	_cd $S_cdsz 8 u* bounds
	do
		0 _fb
		loop
	
	here W@	_cd $S_cdsz 8 u* +
	do 
		i C@ _fb
		loop
		
	h7FB8 here W@ - 0
	do
		0 _fb
		loop

	h_35 _fb h_C7 _fb h_14 _fb h_35 _fb
	h_2C _fb h_32 _fb h_00 _fb h_00 _fb

	0 _fb 0 _fb 0 _fb h_0 _fb
	0 _fb 0 _fb 0 _fb h_0 _fb
	
	h38 0 do
		0 _fb
		loop		
		
	h_14 checksum W@ - h_FF and 5 C!

	_cd 0
	do 
		i C@ emit
		loop
		
	_cd $S_cdsz 8 u* bounds
	do
		0 emit
		loop
	
	here W@	_cd $S_cdsz 8 u* +
	do 
		i C@ emit
		loop
		
	h7FB8 here W@ - 0
	do
		0 emit
		loop

	h_35 emit h_C7 emit h_14 emit h_35 emit
	h_2C emit h_32 emit h_00 emit h_00 emit
	h_FF emit h_FF emit h_F9 emit h_FF emit
	h_FF emit h_FF emit h_F9 emit h_FF emit
	
	h38 0 do
		0 emit
		loop
		
	savehere W@ here W!
	savewlastnfa W@ wlastnfa W!
	-1 _finit W!
	;

{
\ dl ( addr -- addr + h10)
: dl
	base W@ swap hex
	dup <# # # # # # #> .cstr h3A emit space
	dup h10 bounds
	do
		i C@ dup h10 < if h30 emit then . 
	loop
	dup h10 bounds
	do
		i C@ dup h20 h7E between if emit else drop h2E emit then 
	loop
	cr
	h10 +
	swap base W!
	;
\ ddl ( addr nl --	)
: ddl 0 do dl loop drop ;


\ newDictList ( -- )
: newDictList
	lastNewNFA W@ 0<>
	if
		lastNewNFA W@
		begin
			dup . dup na h10 - 3 ddl
			dup . dup na dup . .strname cr
			2- na W@ dup 0=
		until
		drop
	then
	;

\ ndl ( -- )
: ndl
	lastNewNFA W@ 0<>
	if
		lastNewNFA W@
		begin
			dup . dup na dup . .strname cr
			2- na W@ dup 0=
		until
		drop
	then
	;


}

