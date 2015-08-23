\
\ >nc ( -- ) allocate a free cog and link the io to this cog
: >nc lockdict cogid nfcog iolink freedict ;
\
\ xnc ( -- ) unlink the io
: xnc lockdict cogid iounlink freedict ;
\
\
\ 2* ( n1 -- n1<<1 ) n2 is shifted logically left 1 bit
[ifndef 2*
: 2* _xasm2>1IMM h0001 _cnip h05F _cnip ; 
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
\
\
\ 4- ( n1 -- n1-4 )
[ifndef 4-
: 4- _xasm2>1IMM h0004 _cnip h10F _cnip ;
]

\ u*/mod ( u1 u2 u3 -- u4 u5 ) u5 = (u1*u2)/u3, u4 is the remainder. Uses a 64bit intermediate result.
[ifndef u*/mod
: u*/mod
	rot2 um* rot um/mod
;
]

\
\ u*/ ( u1 u2 u3 -- u4 ) u4 = (u1*u2)/u3 Uses a 64bit intermediate result.
[ifndef u*/
: u*/
	rot2 um* rot um/mod nip
;
]
\ queue structure, must be long aligned
\
\ byte 0	- head
\ byte 1	- tail
\ byte 2	- # elements
\ byte 3	- flags , xxxx_xx00 - byte queue,  xxxx_xx01 - word queue, xxxx_xx10 - long queue
\ byte 4-n	- data
\
\ _iniQ ( flags size addr -- )
: _iniQ 
\ (flags size addr -- ) lo 2 bits of flags are used for the item size 0 - byte 1 word 2 long addr must be long aligned	
	dup 3 and if ERR then
	0 over C! 1+ 0 over C! 1+ swap over C! 1+ C!
;
\
\ _defQ1 ( name bsize -- addr)
: _defQ1
 \ ( bsize addr -- )
	swap ccreate $C_a_dovarl w, 
 	herelal here W@ swap 4+ allot forthentry
;
\
\ _defQ( size name -- )	
: _defQ
	lockdict
	swap 1+ 2 max tuck 4* _defQ1
\ (size addr -- )	
	2 rot2 _iniQ
	freedict
;
\
\ defQ( size -- ) name	
: defQ parsenw _defQ ;
\
\
\ _defWQ( size name -- )	
: _defWQ
	lockdict
	swap 1+ 2 max tuck 2* _defQ1
\ (size addr -- )	
	1 rot2 _iniQ
	freedict
;
\
\ defWQ( size -- ) name	
: defWQ parsenw _defWQ ;
\
\ _defCQ( size name -- )	
: _defCQ
	lockdict
	swap 1+ 2 max tuck _defQ1
\ (size addr -- )	
	0 rot2 _iniQ
	freedict
;
\
\ defCQ( size -- ) name	
: defCQ parsenw _defCQ ;

\
: >sliceQ sliceQ _toq 0= if ERR then ;
: sliceQ> sliceQ _frq  0= if ERR then ;
: >sliceQ? sliceQ _qaf  nip ;
: sliceQ>? sliceQ _qaf  drop ;
: >bgQ bgQ _toq  0= if ERR then ;
: bgQ> bgQ _frq  0= if ERR then ;
\ : bgQ> bgQ _qfr ;
: >bgQ? bgQ _qaf  nip ;
: bgQ>? bgQ _qaf  drop ;
\
\
: setThis $C_this COG! ;
: mpST@	thisC@ d_0 _cnip ;
: mpST!	thisC! d_0 _cnip ;
: mpRS@	thisC@ d_1 _cnip ;
: mpRS!	thisC! d_1 _cnip ;
: mpIP@	thisW@ d_2 _cnip ;
: mpIP!	thisW! d_2 _cnip ;
: mpCT@	thisL@ d_4 _cnip ;
: mpCT!	thisL! d_4 _cnip ;
: mpXC@	thisL@ d_8 _cnip ;
: mpXC!	thisL! d_8 _cnip ;
: mpS0@	thisL@ d_12 _cnip ;
: mpS0!	thisL! d_12 _cnip ;
: mpS1@	thisL@ d_16 _cnip ;
: mpS1!	thisL! d_16 _cnip ;
: mpS2@	thisL@ d_20 _cnip ;
: mpS2!	thisL! d_20 _cnip ;
: inQ@ thisW@ d_24 _cnip ;
: inQ! thisW! d_24 _cnip ;
: in2Q@ thisW@ d_26 _cnip ;
: in2Q! thisW! d_26 _cnip ;
: outQ@ thisW@ d_28 _cnip ;
: outQ! thisW! d_28 _cnip ;
: out2Q@ thisW@ d_30 _cnip ;
: out2Q! thisW! d_30 _cnip ;
\
d_32 wconstant mpSZ
\
wvariable _inTypedef 0 _inTypedef W!

: inTDef?
	_inTypedef W@ 0= if ERR then
;
\
\ .h ( n1 -- ) output as hex
: .h base W@ swap hex ." h_" . base W! ;
\
\ :: ( - ) name - same as :  but causes an error if word is already defined
: ::
	inTDef?
	parsenw dup find
	if
		errdata W! ERR
	else
		drop
	then
	lockdict ccreate h3741 1 state orC!
;
\
\ ::: ( addr -- addr) name - addr wconstant data, define main mp routine
: :::
	inTDef?
	dup 2+ W@ 0<> if ERR then
	parsenw dup find
	if
		errdata W! ERR
	else
		drop
	then
	lockdict ccreate
	here W@ alignw over 2+ W!
	h3741 1 state orC!
;
\
\ defPtr ( addr-- addr) name
: defPtr
	inTDef?
\ ( addr -- )
	parsenw dup 0=
	if
		ERR
	else
\ ( addr name -- )
		>nc
		." ~h0D:: " .cstr  space dup W@ .h ." $C_this COG@ + ;~h0D~h0D~h0D"
		xnc
\ ( addr -- )
	then
;

\ mpAllot ( addr size -- addr )
: mpAllot
	inTDef?
	over W@ + over W!
;	
\
\ _defX ( addr strType size -- addr) name
: _defX
	inTDef?
	2 ST@ W@ dup >r over 1- and if ERR then r>
\ ( addr strType size offset -- )
	parsenw dup 0=
	if
		3drop 2drop ERR
	else
\ ( addr strType size offset name -- )
		>nc
		." ~h0D:: " dup .cstr ." @ this" 3 ST@ .cstr ." @ " over .h ."  _cnip ;~h0D:: "
		.cstr ." ! this"  rot .cstr ." ! " .h ."  _cnip ;~h0D~h0D~h0D"
		xnc
\ ( addr size -- )
		mpAllot
	then
;

\
\ _reuX ( addr strType size -- addr) name
: _reuX
	swap find 0= if ERR then swap
	inTDef?
	2 ST@ W@ dup >r over 1- and if ERR then r>
	parsenw dup 0=
	if
		3drop 2drop ERR
	else
\ ( addr xpfa size offset name -- )
		tbuf ccopy c" @" tbuf cappend tbuf
		find 0=
		if ERR else
\ ( addr xpfa size offset pfa -- )
			dup W@ swap 2+ W@
\ ( addr xpfa size offset @pfa  poffset-- )
			rot <> 
			if ERR then
\ ( addr xpfa size @pfa -- )
			rot <> if ERR then
\ ( addr size -- )
			mpAllot
		then
	then
	
;
\
\ defL ( addr -- addr) name - addr wconstant data
: defL
	c" L" 4 _defX
;
\
\ defW ( addr -- addr) name - addr wconstant data
: defW
	c" W" 2 _defX
;
\ defC ( addr -- addr) name - addr wconstant data
: defC
	c" C" 1 _defX
;
\ reuseL ( addr -- addr) name - addr wconstant data
: reuseL
	c" thisL@" 4 _reuX
;
\
\ reuseW ( addr -- addr) name - addr wconstant data
: reuseW
	c" thisW@" 2 _reuX
;
\ reuseC ( addr -- addr) name - addr wconstant data
: reuseC
	c" thisC@" 1 _reuX
;

\ _gaccX ( strType addrobj member accname -- )
: _gaccX
	rot find 0=
	if
		ERR
	else
		2+ alignl
\ ( strType member accname  addrSZ -- )
		rot tbuf ccopy c" @" tbuf cappend
\ ( strType accname  addr -- )
		tbuf find 0=
		if
			ERR
		else
			2+ W@ + 
\ ( strType accname addr -- )
			>nc
			." ~h0D: " over .cstr  ." @ " dup .h rot dup .cstr ." @ ;~h0D: "
\ (accname  addr  strType -- )
			rot .cstr ." ! " swap .h .cstr ." ! ;~h0D~h0D~h0D"
			xnc
		then
	then
;

\ gaccX ( strType -- ) smon_d _xdir xdir 
: gaccX
	parsenw dup 0=
	if
		ERR
	else
		parsenw dup 0=
		if
			ERR
		else
			parsenw dup 0=
			if
				ERR
			else
				_gaccX
	thens
;
\ gaccL smon_d _xdir xdir 
: gaccL
	c" L" gaccX
;
\ gaccW smon_d _xdir xdir 
: gaccW
	c" W" gaccX
;
\ gaccC smon_d _xdir xdir 
: gaccC
	c" C" gaccX
;


\
\ ((( ( -- addr) name - addr wconstant data
: (((
	parsenw dup
	if
		lockdict _inTypedef W@
		if
			freedict
			ERR
		then
		dup find nip
		if
			ERR
		then
		-1 _inTypedef W! freedict
		>nc
		." ~h0Dlockdict mpSZ wconstant " dup .cstr ."  0 w, freedict~h0D~h0D~h0D"
		xnc		
		find 0=
		if
			drop
			ERR
		then
		2+	
	else
		ERR
	then
;
\
\ ))) ( addr -- ) addr wconstant data
: )))
	lockdict _inTypedef W@ 0=
	if
		freedict
		ERR
	then
	0 _inTypedef W! freedict
	>nc
	dup 2+ W@ dup 0= if ERR then
	swap dup W@ swap 2- pfa>nfa
\ ( xpfa size  name -- )
	." ~h0D: " .strname ."  lockdict variable here W@ " dup 4- .h ." allot freedict 4- dup "
	.h ." 0 fill~h0D" .h ." swap 2+ W! cr ;~h0D~h0D~h0D"
	xnc		
;
\
\
\ mp+ ( addr -- )
: mp+
	dup setThis
	h10 lshift mpIP@ or
\ ( qv -- )
	sliceLock lock
	>sliceQ? 2 >=
	if
		>bgQ? 2 >=
		if
			1 mpST!
			$C_this COG@ >bgQ

			>sliceQ
			sliceLock unlock
		else
			0 mpST!
			sliceLock unlock
			drop ERR
		then
	else
		0 mpST!
		sliceLock unlock
		drop ERR
	then
;
\
\
: mpInit	cnt COG@ mpCT! 0 mpXC! ;
\
\
: mp-
	mpST@
	0 mpST!
	sliceLock lock sliceQ> sliceLock unlock
	dup h_7FFFF and
	r> drop >r
	h10 rshift dup setThis 0=
	if
		drop
	else
		mpST!
	then

;
\
\	
((( mpMon_t
defL flags
defL curcnt
defL lastcnt
defL count
defL maxcnt
defL totcnt

\ mpMon_x ( -- )
::: mpMon_x
	mpInit 0 flags! 0 curcnt! cnt COG@ lastcnt! 0 count! 0 maxcnt! 0 totcnt!
	begin
		slice
		flags@ 1 and
		if
			0 flags! 0 curcnt! cnt COG@ lastcnt! 0 count! 0 maxcnt! 0 totcnt!
		else
			cnt COG@ dup lastcnt@ - curcnt! lastcnt!
			maxcnt@ curcnt@ max maxcnt!
			totcnt@ curcnt@ + totcnt!
			totcnt@ h_4000_000 <
			if
			 	count@ 1+ count!
			else
				totcnt@ 1 rshift totcnt!
				count@ 1+ 1 rshift count!
			then
		then
	0 until
;


)))


((( mpGC_t
reuseL	flags


\ mpGC_x ( -- )
::: mpGC_x
	mpInit
	0 flags!
	begin
		slice
\
\ 3 lo bits of flag
\ 000 - GC running
\ XX1 - waiting for GC to stop
\ 100 - GC stopped
\ X1X - waiting for GC to start
\
\ bits 0 & 2 are set by other process
\ bit 1 is set by GC
\ bits 0 1 2 are reset by GC
\
		flags@ 7 and
		if
			flags@ 1 and
			if
				flags@ 7 andn 4 or flags!
			else
				flags@ 2 and
				if
					flags@ 7 andn flags!
				then
			then
		else
			gc1
		then
	0 until
;


)))
\
\
\ _main ( -- ) main interpreter loop
: _main
	r> r> 2drop
	state C@ h80 and
	if
		sliceLock lock sliceQ> sliceLock unlock
		dup h_7FFFF and >r
		h10 rshift
		setThis 0
	else
		begin
			compile? 0=
			if
				prompt
			then
			h80 state orC!
			begin
				io W@ h100 and
				if
					0 setThis 0 slice 
				else
					-1
				then
			until
			h80 state andnC!
			0 setThis 0 errdata W!
			interpret 0
		until
	then
;

mpMon_t mpMon_d
mpGC_t mpGC_d

gaccL mpGC_d flags gcflags

\
\ mpGCStop( -- t/f) true if GC was running
: mpGCStop
	gcflags@ 7 and 4 =
	if
		0
	else
		begin
			gcflags@ 7 and 0=
		until
		gcflags@ 1 or gcflags!
		begin
			gcflags@ 7 and 4 =
		until
		-1
	then
;
: mpGCStart
	gcflags@ 2 or gcflags!
	begin
		gcflags@ 7 and 0=
	until
;
\
: _mp1
	p>n dup C@ namemax and hC swap - 0 max spaces .strname
;
\
: _af
	dup 0=
	if
		drop h15 spaces
	else
		dup _mp1 space _qaf . .
	then
;
\
: mpMon
	mpMon_d setThis
	." lag(us):: max avg: " maxcnt@ d_1000_000 clkfreq u*/ . totcnt@ count@ u/ d_1000_000 clkfreq u*/ .
	." slices/s:: min avg: " clkfreq maxcnt@ u/ . clkfreq count@ totcnt@ u*/ . cr
	mpGCStop
	." ~h0Dword_name        dataname:addr mpST maxT(us)    in                in2               out               out2~h0D~h0D"

	0 >bgQ

	sqz 1+ 0
	do
		bgQ> dup setThis
		if
			mpIP@ _mp1 space $C_this COG@ dup _mp1 ." :" .
			mpST@ . mpXC@ d_1000_000 clkfreq u*/ .
			inQ@ _af in2Q@ _af outQ@ _af out2Q@ _af
			cr
			$C_this COG@ >bgQ
		else
			leave
		then
	loop
	cr
	if
		mpGCStart
	then
;
\
: mpRes
	mpMon_d setThis flags@ 1 or flags!
	mpGCStop
	sqz 1+ 0
	do
		bgQ> dup setThis dup
		if
			 >bgQ 0 mpXC! 
		else
			drop leave
		then
	loop
	if
		mpGCStart
	then
;


\ this changes the name of the last onboot word
\
c" onboot" find drop pfa>nfa 1+ c" onb001" C@++ rot swap cmove

\ onboot ( -- )
: onboot

	lockdict bgQ dup dictend W! memend W! freedict
	2 sqz sliceQ _iniQ
	1 sqz bgQ _iniQ

	mpMon_d mp+
	mpGC_d mp+
	onb001
;
\
\ this changes the name of the last onreset word
\
c" onreset" find drop pfa>nfa 1+ c" onre001" C@++ rot swap cmove

\ onreset ( -- )
: onreset
	errdata W@ 0<>
	if
\ offending mpST to 0
		0 errdata W@ C!
	then
	onre001
;
\
' _main ' main W!
c"  MPF" prop W@ ccopy

{
10 defQ i1
10 defQ i2
10 defQ o1
10 defQ o2

((( t_t
::: t_x
	mpInit
	begin
		slice
	0 until
;

)))

t_t t_d

t_d setThis i1 inQ! i2 in2Q! o1 outQ! o2 out2Q! t_d mp+
}

