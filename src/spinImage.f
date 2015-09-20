

1 wconstant build_spinimage

lastnfa nfa>lfa W@ wconstant imageLastnfa

c" _bt" find drop dup pfa>nfa nfa>lfa wconstant imageStart
2+ 2+ 2+ wconstant bootPFA

c" build_spinimage" find drop  pfa>nfa nfa>lfa wconstant imageEnd

\
\
\ 2* ( n1 -- n1<<1 ) n2 is shifted logically left 1 bit
[ifndef 2*
: 2* _xasm2>1IMM h0001 _cnip h05F _cnip ; 
]
\
wvariable numConstantsOfInterest 0 numConstantsOfInterest W!
lockdict wvariable ConstantsOfInterest 100 2* allot freedict
: w. <# # # # # #> .cstr ;
\
\ findConstantsOfInterest ( -- )
: findConstantsOfInterest
	lastnfa
	begin
		c" $S_" over swap
		npfx
		if
			dup nfa>pfa dup W@ $C_a_doconw =
			if
				c" dlr" tbuf ccopy
				over dup 2+
				swap tbuf 2+ 2+
				swap C@ h1F and 2+
				dup tbuf C! cmove
				tbuf .cstr
				2+ dup W@
				." = $" w.
				cr
				ConstantsOfInterest numConstantsOfInterest W@ 2* + W!
				numConstantsOfInterest W@ 1+ 
				100 min numConstantsOfInterest W!
			else
				drop
			then
		then
		nfa>lfa W@ dup 0=
	until
;
\
: isConstantOfInterest?
	numConstantsOfInterest W@ 0<>
	if
		0 swap
		numConstantsOfInterest W@ 0
		do
			i 2* ConstantsOfInterest + W@ over =
			if
				nip -1 swap leave
			then
		loop
		drop
	else
		drop 0
	then
;
: _spinImage \ ( i -- t/f )
	dup bootPFA =
	if
		." ~h0D~h0D' " dup w.
		." ~h0DbootPFA~h0D~h0D  word $" W@ w. 0
	else
		dup isConstantOfInterest?
		if
			." ~h0D~h0D' " dup w. 
			." ~h0D  word dlr"
			2- pfa>nfa namelen 1- swap 1+ swap .str 0
		else
			drop -1
		then
	then
	;
\
: spinImage
\	base W@
	hex
	." ~h0D~h0D{{~h0DAuto Generated~h0D}}~h0D~h0DCON~h0D_clkmode= xtal1+pll16x~h0D_xinfreq= 5_000_000~h0D~h0D"
	findConstantsOfInterest
	." ~h0D~h0DVAR~h0D~h0DOBJ~h0D~h0DPUB Main~h0D  coginit( 0, @bootPFA, 0)~h0D~h0DDAT~h0D"
	lastnfa W@
	here W@ 
	imageEnd here W!
	imageLastnfa wlastnfa W!
	0 _finit W!
	." ~h0D' " imageStart .
	." ~h0D  word $" imageStart W@ w.
	_cd imageStart 2+
	do
		i _spinImage
		if
			i h1F and 0=
			if
				." ~h0D' " i w.
				." ~h0D  word $" i W@ w.
			else
				." , $" i W@ w.
			then
		then
	2 +loop
	
	_cd $S_numcogs $S_cdsz u* + _cd
	do
		i _spinImage
		if
			i h1F and 0=
			if
				." ~h0D' " i w.
				." ~h0D  word $" 0 w.
			else
				." , $" 0 w.
			then
		then
	2 +loop

	imageEnd _cd $S_numcogs $S_cdsz u* + 
	do
		i _spinImage
		if

			i h1F and 0=
			if
				." ~h0D' " i w.
				." ~h0D  word $" i W@ w.
			else
				." , $" i W@ w.
			then
		then
	2 +loop

	
	cr cr
	-1 _finit W!
	here W!
	lastnfa W!

	memend W@ 2- imageEnd
	."   word "
	do
		i h1F and 0=
		if
			." $0000~h0D' " i .
			." ~h0D  word "
		else
			." $0000, "
		then
	2 +loop
	." $0000~h0D~h0D~h0D"
\	base W!		
;

