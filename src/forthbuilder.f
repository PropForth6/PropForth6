wvariable lastNewNFA
wvariable initialNewhere
wvariable newhere
wvariable resolveFlag
wvariable resolveError

wvariable initialBaseAddr
wvariable baseAddr

: bw,
	resolveFlag W@ 0=
	if
		2 allot
	then
	baseAddr W@ W! 2 baseAddr W+! 2 newhere W+!
	;
 
: >tbuf
	tbuf dup C@ + 1+ C!
	tbuf C@ 1+ tbuf C!
	;

\ getword ( -- ) 
: getword
	0 tbuf C!
	begin
		key dup bl = over h0D = or
		if
			drop 0
		else
			>tbuf -1
		then
	until
	begin
		key dup bl = over h0D = or
		if
			drop -1
		else
			>tbuf 0
		then
	until
\ ." getword " tbuf .cstr cr
	h2E emit
	;

\ getnumber ( -- 0 | -1) 
: getnumber
		getword tbuf C@++ fisnumber 0=
		if
			." ~h0D* ***ERROR EXPECTED NUMBER: " tbuf .cstr cr cr -1
		else
			tbuf C@++ fnumber 0
		then
\ ." getnumber " over . dup . cr
	;


: na initialBaseAddr W@ + initialNewhere W@ - ; 
: oa initialBaseAddr W@ - initialNewhere W@ + ; 

\ newDictFind ( cstr -- 0 | xt -1 ) c-addr is a counted string, 0 - not found, -1 pfa
: newDictFind
	dup tbuf ccopy
	lastNewNFA W@ 0= resolveFlag W@ 0= or
	if
		drop 0
	else
		lastNewNFA W@
		\ 2-
		begin
			dup 0=
			if
				-1
			else
				\ 2+
\				dup . dup na .strname cr
				2dup na name=
				if
					-1
				else
					2- na W@ dup 0=
				then
			then
		until
		2dup na name=
		if
			nip na nfa>pfa oa -1
		else
			2drop 0
			resolveFlag W@
			if
				." ~h0D~h0D~h0DSymbol not found: " tbuf .cstr cr cr cr
				-1 resolveError W!
			then
		then
	then
\	st?
	;


\ newDictWConst ( cstr -- 0 | xt -1 ) c-addr is a counted string, 0 - not found, -1 const
: newDictWConst
	newDictFind dup
	if
		swap na 2+ W@ swap
	then
	;

\ _getfword ( -- 0 | -1 )
: _getfword
	begin
		getword
		tbuf c" ;" cstr=
		if
			-1
		else
			tbuf c" a" cstr=
			if
				getword
				tbuf newDictWConst 0=
				if
					0
				then
				bw, resolveError W@
			else
				tbuf c" p" cstr=
				if
					getword
					tbuf newDictFind 0=
					if
						0
					then
					bw, resolveError W@
				else
					tbuf c" w" cstr=
					if
						getnumber
						if
							." ~h0D* ***ERROR expected number: " tbuf .cstr cr cr -1
						else
							bw, 0
						then
					else
						tbuf c" e" cstr=
						if
							-1
						else
							." ~h0D* ***ERROR [ a | p | w | e]:" tbuf .cstr cr cr -1
						then
					then
				then
			then
		then
	until
	;	


\ getfword ( -- 0 | -1 )
: getfword
	getnumber over -1 = or
	if
		drop -1
	else
		initialNewhere W@ h_FFFF =
		if
			dup initialNewhere W! dup newhere W!
		then
		\ tolerate long alignment alignment 
		dup newhere W@ <> over newhere W@ 2+ <> and
		if
			." ~h0D* ***ERROR SYNCH ERROR: " dup . newhere W@ . tbuf .cstr cr cr -1
		else
			newhere W@ 2+ =
			if
				0 bw,
			then

			getnumber
			if
				." ~h0D* ***ERROR expected lfa: " tbuf .cstr cr cr -1
			else
			
				
				bw,
				getnumber
				if
					." ~h0D* ***ERROR expected flags: " tbuf .cstr cr cr -1
				else
					getword tbuf baseAddr W@ ccopy
					resolveFlag W@ 0=
					if
						newhere W@ lastNewNFA W!
					then
					baseAddr W@ orC!
					tbuf C@ 2+ 1 andn dup resolveFlag W@ 0= if dup  allot then baseAddr W+! newhere W+!
					_getfword
					0
				then
			then
		then
	then
;
	
: forthbuilder
	lockdict
	base W@ hex 
	herelal
	here W@ dup baseAddr W! initialBaseAddr W!
	h_0 lastNewNFA W!
	h_0 resolveFlag W!
	h_0 resolveError W!
	h_FFFF initialNewhere W!
	begin
		getfword
		newhere W@ . cr
	until
	cr
	." \ initialNewhere h_" initialNewhere W@ . cr cr
	." \ newhere h_" newhere W@ . cr cr
	." \ lastNewNFA h_" lastNewNFA W@ . cr cr
	base W!
	freedict
;

: forthbuilderpass2
	lockdict
	base W@ hex
	initialBaseAddr W@ baseAddr W! 
	-1 resolveFlag W!
	h_0 resolveError W!
	h_FFFF initialNewhere W!
	begin
		getfword
		newhere W@ . cr
	until
	cr
	." \ initialNewhere h_" initialNewhere W@ . cr cr
	." \ newhere h_" newhere W@ . cr cr
	." \ lastNewNFA h_" lastNewNFA W@ . cr cr
	base W!
	freedict
;

\ _fbPatch ( startCog -- )
: _fbPatch
\ the init long for the start cog
	dup c" $S_cdsz" newDictWConst . u*
	c" _cd" newDictFind . 2+ alignl + h10 lshift
	c" _fi" newDictFind . 2+ 2+ 2+ dup . 2 lshift or or
\ third long must be the initialization long
	c" _bt" newDictFind .  2+ 3 4 u* + na L!
\ Patch the forth interpreter	
\		
\
\ Set the initial IP to the forth start word
\
	c" fstart" newDictFind . dup .
	c" _fi" newDictFind . 2+ dup .
	c" $C_IP" newDictWConst . dup . 1+ 4 u* + na dup . L!

	c" $V_lasterr" newDictWConst . dup .
	c" _fi" newDictFind . 2+ dup .
	c" $C_a_lasterr" newDictWConst . dup . 1+ 4 u* + na dup .
	over . dup .
	dup L@ h1FF andn dup . rot dup . or dup . swap dup . L!
\		
\
\ Patch the forth dictionary
\
	dictend W@ dup . c" dictend" newDictFind . na 2+ dup . W!
	memend W@ dup . c" memend" newDictFind . na 2+ dup . W!
	newhere W@ dup . c" here" newDictFind . na 2+ dup . W!
	lastNewNFA dup . W@ c" wlastnfa" newDictFind . na 2+ dup . W!
	;

wvariable checksum
wvariable bytecount
wvariable count0
wvariable count1
wvariable count2
wvariable count3
wvariable count4

: _fbDbg
	hex count0 W@ .
	count1 W@ .
	count2 W@ .
	count3 W@ .
	count4 W@ .
	bytecount W@ .
	checksum W@ .
	;

: _fb checksum W+! 1 bytecount W+! ;
: fbinout 
	0 checksum W!
	0 bytecount W!
	
	h_00 _fb h_B4 _fb h_C4 _fb h_04 _fb
	h_6F _fb h_00 _fb h_10 _fb h_00 _fb
	h_C0 _fb h_7F _fb h_C8 _fb h_7F _fb
	h_B8 _fb h_7F _fb h_CC _fb h_7F _fb
\	h_B8 _fb h_7F _fb h_D0 _fb h_7F _fb
	h_B0 _fb h_7F _fb h_02 _fb h_00 _fb
	h_A8 _fb h_7F _fb h_00 _fb h_00 _fb
\	h_A8 _fb h_7F _fb h_04 _fb h_00 _fb
	
	bytecount W@ count0 W!
	initialBaseAddr W@ newhere W@ initialNewhere W@ - bounds
	do 
		i C@ _fb
		loop
	bytecount W@ count1 W!
		
	h7FB8 newhere W@ - 0
	do
		0 _fb
		loop
	bytecount W@ count2 W!

	h_35 _fb h_A7 _fb h_14 _fb h_35 _fb
\	h_35 _fb h_C7 _fb h_14 _fb h_35 _fb
	h_2C _fb h_32 _fb h_00 _fb h_00 _fb

	0 _fb 0 _fb 0 _fb h_0 _fb
	0 _fb 0 _fb 0 _fb h_0 _fb
	bytecount W@ count3 W!
	
	h38 0 do
		0 _fb
		loop
	bytecount W@ count4 W!

	h_00 emit h_B4 emit h_C4 emit h_04 emit
	h_6F emit
	h_14 checksum W@ - h_FF and emit
	h_10 emit h_00 emit
	h_C0 emit h_7F emit h_C8 emit h_7F emit
	h_B8 emit h_7F emit h_CC emit h_7F emit
\	h_B8 emit h_7F emit h_D0 emit h_7F emit
	h_B0 emit h_7F emit h_02 emit h_00 emit
	h_A8 emit h_7F emit h_00 emit h_00 emit
\	h_A8 emit h_7F emit h_04 emit h_00 emit
        
	initialBaseAddr W@ newhere W@ initialNewhere W@ - bounds
	do 
		i C@ emit
		loop
		
	h7FB8 newhere W@ - 0
	do
		0 emit
		loop

	h_35 emit h_A7 emit h_14 emit h_35 emit
\	h_35 emit h_C7 emit h_14 emit h_35 emit
	h_2C emit h_32 emit h_00 emit h_00 emit
	h_FF emit h_FF emit h_F9 emit h_FF emit
	h_FF emit h_FF emit h_F9 emit h_FF emit
	
	h38 0 do
		0 emit
		loop
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

