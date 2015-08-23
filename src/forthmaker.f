
\
1 wconstant forthmakerfence
\
' forthmakerfence pfa>nfa wconstant asmsearchstart
\
\ ixnfa ( n1 -- c-addr ) returns the n1 from the last nfa address
: ixnfa
	0 max wlastnfa W@
	begin
		over 0=
		if
			-1
		else
			swap 1- swap nfa>next dup 0=
		then
	until
	nip
;
\
\ nfacount ( -- n1 ) returns the number of nfas in the forth dictionary
: nfacount
	0 wlastnfa W@
	begin
		swap 1+ swap nfa>next dup 0=
	until
	drop
;
\
\ nfaix ( c-addr -- n1 ) returns the index of the nfa address, -1 if not found
: nfaix
	-1 swap 0 wlastnfa W@
	begin
		rot 2dup =
		if
			2drop swap -1 -1 -1
		else
			rot 1+ rot nfa>next dup 0=
		then
	until
	3drop
;
\
\ lastdef ( c-addr -- t/f ) true if this is the most recently defined word 
: lastdef
	lastnfa over _dictsearch dup
	if
		=
	else
		2drop -1
	then
; 

\
\
wvariable lastNewNFA
wvariable initialNewhere
wvariable newhere
wvariable currentWordSize
wvariable savebase

: nh+  dup newhere W+! negate currentWordSize W+! ;
: nh2+ 2 nh+ ;
: dolalign+
	newhere W@ 3 and
	if
		." w h_0 " nh2+
		2 currentWordSize W+!
	then
;
: dolalign
	newhere W@ 3 and
	if
		." w h_0 " nh2+
	then
;


\ asmlookup ( n1 --- n2) n1 the assembler address, n2 0 if not found, symbol nfa
: asmlookup
	0 swap asmsearchstart
	begin
	\ ( -1 n1 nfa)
		dup c" $C_" npfx
		if
			2dup nfa>pfa 2+ W@ =
			if
				rot2 -1
			else
					nfa>next dup 0=
			then
		else
			nfa>next dup 0=
		then		
	until
	2drop
;


\ isExecasm ( addr -- t/f) true if addr is one of the ifuncs
: isExecasm
	dup $C_a__xasm2>1 =
	over $C_a__xasm2>flag = or
	over $C_a__xasm1>1 = or
	swap $C_a__xasm2>0 = or
;
	
\
\ isExecasmIMM ( addr -- t/f) true if addr is one of the immediate ifuncs
: isExecasmIMM
	dup $C_a__xasm2>1IMM =
	swap $C_a__xasm2>flagIMM = or
;
	
\
\
: dcmp1
	2+ dup W@ ." w h_" . nh2+
;

\
\
: dcmp2
	2+ alignl
	dup dup W@ dolalign ." w h_" .  2+ W@ ." w h_" .  2+ nh2+ nh2+
;
\
: dcmp3
		asmlookup dup 0= 
		if
			drop ." * ***h_" .
		else
			." a " .strname space drop
		then
;
\
\
\ dcmp ( addr -- addr t/f) process the post word data, flag true if at the end of the word
: dcmp
	dup W@ dup $C_a_doconw = swap $C_a_dovarw = or
	if
		dcmp1 -1
	else
		
	dup W@ isExecasmIMM
	if
		dcmp1
		dcmp1 0
	else

	dup W@ dup isExecasm
	over $C_a_litw = or
	over $C_a_branch = or
	over $C_a_(loop) = or
	over $C_a_(+loop) = or
	swap $C_a_0branch = or
	if
		dcmp1 0
	else

	dup W@ dup $C_a_doconl =
	swap $C_a_dovarl = or
	if
		dcmp2 -1
	else
	dup W@ $C_a_litl =
	if
		dcmp2 0
	else

	dup W@ dup $H_dq = swap $H_cq = or
	if
		dup 2+ C@ 2+ 2/ 0
		do
			2+ dup W@ ." w h_" . nh2+
		loop
		0
	else

	dup W@ $C_a_lxasm =
	if
		2+
		dup 3 and
		if
			-2 currentWordSize W+!
			alignl
		then
		dolalign+
		dup L@ h9 rshift h1FF and 0
		do
			dup dup W@  ." w h_" . 2+  W@ ." w h_" .  4+ nh2+ nh2+
		loop
		-1
	else
		dup W@ $C_a_exit =
	thens
;
\
\ wordforth( addr1 -- addr2 ) addr1 is the nfa, addr2 is the pfa address at the end of this word
: wordforth
	nfa>pfa 2-
	begin
		2+ dup W@ dup hFE00 and 0=
		if
		\ ( addr @ -- )
			dup dcmp3
		else
			." p " pfa>nfa .strname space
		then
		nh2+
		dcmp
	until
	drop
;

\ fixalign ( ix -- ix)
: fixalign
	dup ixnfa nfa>lfa 3 and 0<> 
	if
		newhere W@ 3 and 0=
		if
			\ ." ~h0D\" dup ixnfa dup . .strname space newhere W@ . ." fixalign~h0D" 
			2 newhere W+!
		then
	else
		newhere W@ 3 and 0<>
		if
			\ ." ~h0D\" dup ixnfa dup . .strname space newhere W@ . ." fixalign~h0D" 
			2 newhere W+!
		then
	then
;

\ doword ( ix -- )
: doword
	\ cr newhere W@ . lastNewNFA W@ .
	fixalign
	\ newhere W@ . lastNewNFA W@ . cr
	
\ dup . dup ixnfa dup . .strname space dup 1- ixnfa dup . .strname space

	dup 1- ixnfa over ixnfa - currentWordSize W!
\ currentWordSize W@ . cr
	." h_"  newhere W@ dup . ." h_" lastNewNFA W@ dup 0<> if 2+ then . lastNewNFA W! nh2+ ixnfa dup C@ h_E0 and ." h_" .
	dup .strname dup C@ namemax and 2+ 1 andn nh+ space
	\ (nfa --)
	dup C@ h80 and 0=
	if
	 	dup nfa>pfa W@ dcmp3 nh2+
	else
		dup nfa>pfa W@ dup $C_a_doconw =
		if
		\ (nfa pfa@ -- )
			drop ." a $C_a_doconw " nfa>pfa 2+ W@ ." w h_" . nh2+ nh2+
		else dup $C_a_dovarw = if
			2drop ." a $C_a_dovarw w h_0 " nh2+ nh2+
		else dup $C_a_doconl = if
			drop ." a $C_a_doconl " nfa>pfa 2+ alignl L@ nh2+ dolalign+
			 ." w h_" dup hFFFF and .  h10 rshift  ." w h_" . nh2+ nh2+
		else dup $C_a_dovarl = if
			2drop ." a $C_a_dovarl " nh2+ dolalign ." w h_0 w h_0 " nh2+ nh2+ 
		else
			drop wordforth
	thens
\ cr currentWordSize W@ . cr
	currentWordSize W@ 0>
	if
		currentWordSize W@ h7FFF >
		if
			." ******************************************************* " currentWordSize W@ .
		else
			currentWordSize W@ 1+ 2/ 0
			do
				." w h_0 " nh2+
			loop
		then
	then
	." e~h0D~h0D" 
;
wvariable _forthmakerFlag
wvariable _hi
\ forthmaker ( n1 -- ) generates the forth intermediate code, n1 starting address, must be a long
: forthmaker
	-1 _forthmakerFlag W!
	base W@ savebase W!
	hex
	dup newhere W! initialNewhere W!
	0 lastNewNFA W!
	c" forthmakerfence" find nip c" forthmakerfenceend" find nip or
	c" forthmakerdeletefence" find	nip or
	if
		\ these should always be the first 3 words
		c" _bt" find drop pfa>nfa nfaix doword
		c" _fi" find drop pfa>nfa nfaix doword
		c" _cd" find drop pfa>nfa nfaix doword
		
		c" forthmakerdeletefence" find drop pfa>nfa nfaix nfacount 1- tuck swap - 0
		do
\ dup . i . dup i - . dup i - ixnfa .strname _forthmakerFlag W@ . cr
			_forthmakerFlag W@
			if
				dup i - ixnfa c" forthmakerfence" name=
				if
					0 _forthmakerFlag W!
					0
				else 
					-1
				then
			else
				dup i - ixnfa c" forthmakerfenceend" name=
				if
					-1 _forthmakerFlag W!
					0
				else 
					0
				then					
			then
			
			if
				dup i - dup ixnfa
				
				dup c" _bt" name=
				over c" _fi" name= or
				over c" _cd" name= or
				if
					2drop
				else			
\ 2dup swap . dup . .strname space
					lastdef
\ dup . cr
					if
						doword
					else
						drop
					then
				then
			then
		loop
		drop
	then
	-1 . cr cr

	." \ initialNewhere h_" initialNewhere W@ . cr cr
	." \ newhere h_" newhere W@ . cr cr
	." \ lastNewNFA h_" lastNewNFA W@ . cr cr
	savebase W@ base W!
;
1 wconstant forthmakerfenceend

\ 1 wconstant forthmakerdeletefence h18 forthmaker
 



