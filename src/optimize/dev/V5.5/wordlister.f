1 wconstant build_wordlister
\
\ (forget) ( cstr -- ) wind the dictionary back to the word which follows - caution
[ifndef (forget)
: (forget)
	dup
	if
		find
		if
			pfa>nfa nfa>lfa dup here W! W@ wlastnfa W!
		else
			_p?
			if
				.cstr h3F emit cr
			then
		then
	else
		drop
	then
;
]

\
\ forget ( -- ) wind the dictionary back to the word which follows - caution
[ifndef forget
: forget
	parsenw (forget)
;
]
\
\ cstr> ( addr1 addr2 -- )
[ifndef cstr>
: cstr>
	0 rot2
\ ( 0 a1 a2 -- )
	2dup C@ swap C@ swap
\ ( 0 a1 a2 l1 l2 -- )
	2dup
	>
	>r
	min  rot
\ ( 0 a2 length  a1 -- )
	1+ rot 1+ rot
\ ( 0 a1+1 a2+1 length -- )
	bounds
	do
\ ( 0 a1+n -- )
		dup C@ i C@
		-
		rot + tuck
		0<>
		if
			leave
		then
		1+
	loop
	drop
	dup
	if
		r> drop 0>
	else
\ strings are the same for length compared, if a1 is longer than a2 then true
		drop r>
	then
;
]
\
\ cmove> ( c-addr1 c-addr2 u -- ) If u is greater than zero, copy u consecutive characters from the data space starting
\  at c-addr1 to that starting at c-addr2, proceeding character-by-character from higher addresses to lower addresses.
[ifndef cmove>
: cmove>
	dup 0>
	if
\ ( c-addr1 c-addr2 u -- )
		tuck +	
\ ( c-addr1 u c-addr2end -- )
		rot2
\ ( c-addr2end c-addr1 u -- )
		tuck +	
\ ( c-addr2end u c-addr1end -- )
		swap 0
		do
\ ( c-addr2end c-addr1end -- )
			1- swap 1- swap
			2dup C@ swap C!
		loop
		2drop
	else
		3drop
	then
;
]
\
\ _wordArray ( n cstr -- addr)
: _wordArray
	lockdict ccreate $C_a_dovarw w, here W@ 0 w, swap 0 max h1000 min dup w, 2* allot forthentry freedict
	dup dup W@ swap 2+ swap 2* 0 fill
;

\ _waAppend( addr val -- )
: _waAppend
	over dup W@ swap 2+ W@ <
	if
		over dup W@ 2+ 2* +  W!
		1 swap W+!
		
	else
		hDD ERR
	then
;
\
\ dictionary must be locked
\ dictionary may be left character aligned, be sure to word align after sring are allocated
\ _string ( cstr -- addr)
: _string
	here W@ ccopy here W@ dup C@ 1+ allot
;
\
\
\
\ _strBubbleSort ( endaddr startaddr -- flag ) bubble sort of string array
: _strBubbleSort
	-1 rot2
	do
		i W@ i 2+ W@
		cstr>
		if
			i W@ i 2+ W@
			i W! i 2+ W!
			drop  0
		then
	2 +loop
;
\
\
\ _strInsertionSort ( endaddr startaddr -- ) insertion sort of string array
: _strInsertionSort
	2dup over W@ rot2
\ ( endaddr startaddr InsertItem endaddr startaddr -- )
	do
\ ( endaddr startaddr InsertItem -- )
		i W@ over 
		cstr>
		if
			2 ST@
\ ( endaddr startaddr InsertItem endaddr -- )
			i -
\ ( endaddr startaddr InsertItem movsize -- )
			i dup 2+ rot
			cmove>			 
\ ( endaddr startaddr InsertItem -- )
			dup i
			W!
			leave
		then
	2 +loop
	3drop
;

\ strBubbleSort ( addr -- addr ) bubble sort of string array
: strBubbleSort
	begin
		h2E emit
		dup W@ 1 >
		if
			dup W@ 1- 2* over 4+ swap bounds
			_strBubbleSort
		else
			-1
		then		
	until
;



\ strInsertionSort ( addr -- addr ) Insertion sort of string array
: strInsertionSort
	dup W@ dup 0 >
	if
\ ( addr n -- )
		over swap
		2* swap 4+ swap bounds
		tuck 2+
		do
			h2E emit
\ ( startaddr -- )
			i over
			_strInsertionSort
		2 +loop
		drop
	else
		drop
	then
;

: _wordlisterbegin
	parsenw
	dup
	if
		find
		if
			pfa>nfa
		else
			drop 0
		then
	then
	lockdict
	." Building word list... "
	h400 c" _wlist" _wordArray swap

	c" build_wordlister" find
	if
		pfa>nfa nfa>lfa W@
	else
		drop lastnfa
	then

	begin
		dup tbuf namecopy
		tbuf C@ h1F and tbuf C!
\ ( array stopnfa nfa -- )
		2 ST@ tbuf _string
		_waAppend
		nfa>lfa W@
\ ( array stopnfa nfa -- )
		2dup >
		over 0= or
	until
	2drop

;

: _wordlisterend
	dup W@ 0<>
	if

		cr cr cr
		dup W@ 2* over 4+ swap bounds
		do
			i W@ .cstr cr

		2 +loop
	then	
	cr cr
	drop


	c" _wlist" (forget)
	freedict
;

\ wordlister ( -- ) lists words in lexical order
\ usage: wordlister [forthword] - if forthword is specified, only words in the dictionary after
\                                 forthword are listed
\                                 the top word listed is the one before build_wordlister
: wordlister
	_wordlisterbegin

	." Sorting word list..."
\ ( array -- )
\	strBubbleSort
	strInsertionSort
	cr cr

	_wordlisterend
;





\
\ words by size/name
\
\
\ name> ( addr1 addr2 -- )
[ifndef name>
: name>
	0 rot2
\ ( 0 a1 a2 -- )
	2dup C@ namemax and swap C@ namemax and swap
\ ( 0 a1 a2 l1 l2 -- )
	2dup
	>
	>r
	min  rot
\ ( 0 a2 length  a1 -- )
	1+ rot 1+ rot
\ ( 0 a1+1 a2+1 length -- )
	bounds
	do
\ ( 0 a1+n -- )
		dup C@ i C@
		-
		rot + tuck
		0<>
		if
			leave
		then
		1+
	loop
	drop
	dup
	if
		r> drop 0>
	else
\ strings are the same for length compared, if a1 is longer than a2 then true
		drop r>
	then
;
]



[ifndef $C_a_dovarl
    h5D wconstant $C_a_dovarl
]
\
\ variable ( -- ) skip blanks parse the next word and create a variable, allocate a long, 4 bytes
[ifndef variable
: variable
	lockdict create $C_a_dovarl w, 0 l, forthentry freedict
;
]


: .word <# # # # # # #> .cstr ;

wvariable _wlam
: _wla _wlam W@ ;
wvariable _wlade
\
\
: _wl
	lockdict
	dictend W@ _wlade W!
	dictend W@ d_1024 4* - dup dictend W! _wlam W!
	freedict

	_wla 4+ _wla L!
	here W@ 
	lastnfa
	begin
		2dup - over h10 lshift or _wla L@ tuck L! 4+ _wla L!
 		nip
		dup nfa>lfa W@
		dup 0= _wla L@ _wlade W@ >= or
	until
	2drop
;
: _wlend
	lockdict
	_wlade W@ dictend W!
	freedict

;
: _wl2 dup h10 rshift tuck .word space hFFFF and .word space .strname cr ;
\
\ words
\
: wl
	_wl
	0
	_wla L@ _wla 4+
	do
	1+
		i L@ _wl2 hFFFF i L!
	4 +loop
	cr . cr
	_wlend
;

lockdict
variable _de _de 2+ h10 lshift h8001 or _de L!
variable _da _de h10 lshift _da L!
freedict
\
\ words sorted by name
\
: wlsn
	
	_wl
	begin
		_da
		_wla L@ _wla 4+
		do

			i L@ 0<>
			if
				dup L@ h10 rshift i L@ h10 rshift name>
				if
					drop i
				then
				
			then
		4 +loop

		dup _da =
		if
			drop -1
		else
			dup L@ _wl2
			0 swap
			L!
			0
		then
	until
	_wlend
;

\
\ words sorted by size
\
: wlsz
	
	_wl
	begin
		hFFFF
		_wla L@ _wla 4+
		do
			i L@ hFFFF and min
		4 +loop
		dup hFFFF <>
		if
			_wla L@ _wla 4+
			do
				i L@ hFFFF and over =
				if
					i L@ _wl2 hFFFF i L!
				then
			4 +loop
		then
		hFFFF =
		
	until
	_wlend
;


