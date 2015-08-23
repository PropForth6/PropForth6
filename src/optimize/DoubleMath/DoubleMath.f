\
\ sign ( n1 n2 -- n3 ) n3 is the xor of the sign bits of n1 and n2 
[ifndef sign
: sign
	xor h80000000 and
;
]

\ du* ( u1lo u1hi u2lo u2hi -- u1*u2lo u1*u2hi ) u1 multiplied by u2
[ifndef du*
: du*
	dum* 2drop
;
]

\ du/mod ( u1lo u1hi u2lo u2hi -- remainderlo remainderhi quotientlo quotienthi) \ unsigned divide & mod  u1 divided by u2
[ifndef du/mod
: du/mod
	0 rot2 0 rot2 dum/mod
;
]

\
\
\ du/ ( u1lo u1hi u2lo u2hi -- u1/u2lo u1/u2hi) u1 divided by u2
[ifndef du/
: du/
	du/mod rot drop rot drop
;
]

\ du*/mod ( u1lo u1hi u2lo u2hi u3lo u3hi -- u4lo u4hi u5lo u5hi ) u5 = (u1*u2)/u3, u4 is the remainder.
\         Uses a 128bit intermediate result.
[ifndef du*/mod
: du*/mod
	>r >r dum* r> r> dum/mod
;
]

\
\ du*/ ( u1lo u1hi u2lo u2hi u3lo u3hi -- u4lo u4hi ) u4 = (u1*u2)/u3. Uses a 128bit intermediate result.
[ifndef du*/
: du*/
	>r >r dum* r> r> dum/mod rot drop rot drop
;
]


\ dswap ( n1lo n1hi n2lo n2hi -- n2lo n2hi n1lo n1hi) 
[ifndef dswap
: dswap
	 0 ST@ 3 ST@ 1 ST! 2 ST!
	 1 ST@ 4 ST@ 2 ST! 3 ST!
;

\ drot ( n1lo n1hi n2lo n2hi n3lo n3hi -- n2lo n2hi n3lo n3hi  n1lo n1hi) 
[ifndef drot
: drot 
	 0 ST@ 3 ST@ 6 ST@ 2 ST! 5 ST! 2 ST!
	 1 ST@ 4 ST@ 7 ST@ 3 ST! 6 ST! 3 ST!
;
]
]
\ ddup ( n1lo n1hi --	n1lo n1hi n1lo n1hi)
[ifndef ddup
: ddup
	2dup
;
]
\ ddrop ( n1lo n1hi --	)
[ifndef ddrop
: ddrop
	2drop
;
]
\ dnip ( n1lo n1hi n2lo n2hi -- n2lo n2hi)
[ifndef dnip
: dnip
	rot drop
	rot drop
;
]
\ dover ( n1lo n1hi n2lo n2hi -- n1lo n1hi n2lo n2hi n1lo n1hi)
[ifndef dover
: dover
	3 ST@ 3 ST@
;
]

\ dtuck ( n1lo n1hi n2lo n2hi -- n2lo n2hi n1lo n1hi n2lo n2hi)
[ifndef dtuck
: dtuck
	dswap dover
;
]


\ d2dup ( n1lo nihi n2lo n2hi -- n1lo n1hi n2lo n2hi n1lo nihi n2lo n2hi)
[ifndef d2dup
: d2dup
	dover dover
;
]


\ dnegate( n1lo n1hi -- u1lo u1hi)
[ifndef dnegate
: dnegate
	0 0 dswap d-
;
]
\ dabs( n1lo n1hi -- u1lo u1hi)
[ifndef dabs
: dabs
	dup 0<
	if
		dnegate
	then
;
]

\ d* ( n1lo n1hi n2lo n2hi -- n1*n2lo n1*n2hi ) u1 multiplied by u2
[ifndef d*
: d*
	du*
;
]

\ d*/mod ( n1lo n1hi n2lo n2hi n3lo n3hi -- n4lo n4hi n5lo n5hi ) n5 = (n1*n2)/n3, n4 is the remainder.
\         Uses a 128bit intermediate result.
[ifndef d*/mod
: d*/mod
	dup 3 ST@ sign 5 ST@ sign
	>r
	dabs
	>r >r
	dabs dswap dabs
	dum*
	r> r>
	dum/mod
	r>
	if
		dnegate dswap dnegate dswap
	then
;
]

\ d*/ ( n1lo n1hi n2lo n2hi n3lo n3hi -- n5lo n5hi ) n5 = (n1*n2)/n3
\         Uses a 128bit intermediate result.
[ifndef d*/
: d*/
	d*/mod dnip
;
]
\ d/mod ( n1lo n1hi n2lo n2hi -- n4lo n4hi n5lo n5hi ) n5 = (n1/n2), n4 is the remainder.
[ifndef d/mod
: d/mod
	dup 3 ST@ sign
	>r
	dabs dswap dabs dswap
	du/mod
	r>
	if
		dnegate dswap dnegate dswap
	then
;
]

\ d/ ( n1lo n1hi n2lo n2hi -- n5lo n5hi ) n5 = (n1/n2)
[ifndef d/
: d/
	d/mod dnip
;
]

\
\
\ d# ( n1lo n1hi -- n2lo n2hi ) divide n1 by base and convert the remainder to a char and append to the output
[ifndef d#
: d#
	base W@ 0 du/mod rot drop rot tochar -1 >out W+! pad>out C!
;
]

\
\
\ d#s ( n1lo n1hi -- 0 ) execute # until the remainder is 0
[ifndef d#s
: d#s
	begin
		d# 2dup 0= swap 0= and
	until
	drop
;
]

\
\ du. ( n1lo n1hi -- ) prints the unsigned number on the top of the stack
[ifndef du.
: du.
	<# d#s #> .cstr space
;
]
\
\ d. ( n1lo n1hi -- ) prints the signed number on the top of the stack
[ifndef d.
: d.
	dup 0<
	if
		h2D emit dabs
	then
	du.
;
]

\
\ dL! ( nlo nhi addr -- )
[ifndef dL!
: dL!
	tuck 4+ L! L!
;
]
\
\ dL@ ( addr -- nlo nhi)
[ifndef dL@
: dL@
	dup L@ swap 4+ L@
;
]
\ d>u ( u1lo u1hi -- u1lo )
[ifndef d>u
: d>u
	drop
;
]
\ u>d ( u1lo -- u1lo u1hi )
[ifndef u>d
: u>d
	0
;
]
\ i>d ( d1lo -- d1lo d1hi )
[ifndef i>d
: i>d
	dup 0<
	if
		-1
	else
		0
	then
;
]


