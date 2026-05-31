\ double math


 \
 \ dum* ( u1lo u1hi u2lo u2hi -- u1*u2LL u1*u2LM u1*u2HM  u1*u2HH) \ unsigned 64 bit * 64bit -- 128 bit result
 \
 \

lockdict create dum* forthentry
$C_a_lxasm w, h120  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
hA0BE3AC8 l, h5CFD72B3 l, hA0BE38C8 l, h5CFD72B3 l, hA0FE3C00 l, hA0FE3E00 l, h5CFD72B2 l, hA0FC0200 l,
hA0FD9200 l, hA0FD9400 l, hA0FD9600 l, h2BFC0001 l, h31FD9001 l, h86699000 l, h5C4C010F l, h81BC031C l,
hC9BD931D l, hC9BD951E l, hC8BD971F l, h2DFE3801 l, h35FE3A01 l, h35FE3C01 l, h34FE3E01 l, h5C540107 l,
hA0BD9001 l, h5CFD54A4 l, hA0BD90C9 l, h5CFD54A4 l, hA0BD90CA l, h5CFD54A4 l, hA0BD90CB l, h5C7C0073 l,
0 l, 0 l, 0 l, 0 l,
freedict


 \
 \
 \ dum/mod ( u1LL u1LM u1HM u1HH u2lo u2hi -- remainderlo remainderhi quotientlo quotienthi )
 \ unsigned divide & mod  u1 divided by u2
 \
lockdict create dum/mod forthentry
$C_a_lxasm w, h127  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
hA0BD94C8 l, h5CFD72B3 l, hA0BE44C8 l, h5CFD72B3 l, hA0BD92C8 l, h5CFD72B3 l, hA0BC02C8 l, h5CFD72B3 l,
h5CFD72B2 l, hA0FD9880 l, hA0FE4600 l, hA0FE4800 l, h2DFD9001 l, h35FC0001 l, h35FC0201 l, h35FD9201 l,
h35FE4601 l, h35FE4801 l, h5C700113 l, h873E4722 l, hCD3E48CA l, hA0F19600 l, h5C700116 l, h87BE4722 l,
hCCBE48CA l, hA0FD9601 l, h31FD9601 l, h35FE4A01 l, h34FE4C01 l, hE4FD9908 l, hA0BD9123 l, h5CFD54A4 l,
hA0BD9124 l, h5CFD54A4 l, hA0BD9125 l, h5CFD54A4 l, hA0BD9126 l, h5C7C0073 l, 0 l, 0 l,
0 l, 0 l, 0 l,
freedict

 \
 \ d+ ( n1lo n1hi n2lo n2hi -- n3lo n3hi ) n3 = n1+n2
 \
 lockdict create d+ forthentry
$C_a_lxasm w, h106  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
hA0BD92C8 l, h5CFD72B3 l, hA0BC02C8 l, h5CFD72B3 l, h5CFD72B2 l, h81BD9001 l, hD8BC00C9 l, h5CFD54A4 l,
hA0BD9000 l, h5C7C0073 l,
freedict


 \
 \ d- ( n1lo n1hi n2lo n2hi -- n3lo n3hi ) n3 = n1-n2
 \
lockdict create d- forthentry
$C_a_lxasm w, h106  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
hA0BD92C8 l, h5CFD72B3 l, hA0BC02C8 l, h5CFD72B3 l, h5CFD72B2 l, h87BD9001 l, hDCBC00C9 l, h5CFD54A4 l,
hA0BD9000 l, h5C7C0073 l,
freedict


 \
 \ du> ( n1lo n1hi n2lo n2hi -- flag )
 \
lockdict create du> forthentry
$C_a_lxasm w, h106  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
hA0BD92C8 l, h5CFD72B3 l, hA0BC02C8 l, h5CFD72B3 l, h5CFD72B2 l, h873D9001 l, hCF3C00C9 l, hA0FD9000 l,
hA08590C4 l, h5C7C0073 l,
freedict

 \
 \ du< ( n1lo n1hi n2lo n2hi -- flag )
 \
lockdict create du< forthentry
$C_a_lxasm w, h106  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
hA0BD92C8 l, h5CFD72B3 l, hA0BC02C8 l, h5CFD72B3 l, h5CFD72B2 l, h873D9001 l, hCF3C00C9 l, hA0FD9000 l,
hA0B190C4 l, h5C7C0073 l,
freedict

 \
 \ du= ( n1lo n1hi n2lo n2hi -- n3lo n3hi ) n3 = n1-n2
 \

lockdict create d= forthentry
$C_a_lxasm w, h106  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
hA0BD92C8 l, h5CFD72B3 l, hA0BC02C8 l, h5CFD72B3 l, h5CFD72B2 l, h873D9001 l, hCF3C00C9 l, hA0FD9000 l,
hA0A990C4 l, h5C7C0073 l,
freedict

 \
 \ du>= ( n1lo n1hi n2lo n2hi -- flag )
 \
lockdict create du>= forthentry
$C_a_lxasm w, h106  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
hA0BD92C8 l, h5CFD72B3 l, hA0BC02C8 l, h5CFD72B3 l, h5CFD72B2 l, h873D9001 l, hCF3C00C9 l, hA0FD9000 l,
hA08D90C4 l, h5C7C0073 l,
freedict


 \
 \ du<= ( n1lo n1hi n2lo n2hi -- flag )
 \
lockdict create du<= forthentry
$C_a_lxasm w, h106  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
hA0BD92C8 l, h5CFD72B3 l, hA0BC02C8 l, h5CFD72B3 l, h5CFD72B2 l, h873D9001 l, hCF3C00C9 l, hA0FD9000 l,
hA0B990C4 l, h5C7C0073 l,
freedict

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










\ CURRENT TESTING


\ pin0 - pin15 - simwave __toneOutput
\ pin 17 - bit clock for i2s (32 * LR ) - this is generated by a counter, and the i2s driver synch to this clock
\ pin 18 - i2s LR ( left right signal) 
\ pin 19 - data for i2s

\ cog 0 - i2s driver,  clock A produces the bit clk 44100 sample rate
\ cog 1 - wave generator, possibility for freq < 2 khz ??? generation at 22.5 kHz, 10 waves ???
\ cog 2 - wave generator
\ cog 3 - wave generator / (wave display for lac - for debugging )
\ cog 4 - mixer 
\ cog 5 - tone / note envelope driver
\ cog 6 - ui 
\ cog 7 - serial interface

d17 constant i2sBitClock
d18 constant i2sLrClock
d19 constant i2sData

\ 13 tableAddress bits for look up tables
d8192 constant tableLen

\ 32 bits - 13 bits = 19, shift when using a 32 bit unsigned value to index a table
d19 constant stepShift 

\ sample frequency
d44100 constant sampleFreq

\ clock cycles per sample
clkfreq sampleFreq / constant period

\ clock cycles per millisecond
clkfreq d1000 / constant clocksPerMs

\ bit frequency for i2s
sampleFreq d32 * constant bitFrequency

d22000 constant maxFreq
maxFreq d100 u* constant maxCents

: ftosNumerator tableLen u>d 1 stepShift lshift u>d du* ;
: ftosDenominator sampleFreq u>d ;

\ (freq -- stepPerPeriod)
: freqToStep maxFreq min u>d ftosNumerator ftosDenominator du*/ d>u ;

: centsToStep maxCents min u>d ftosNumerator ftosDenominator du*/ d100 u>d du/ d>u  ;

\
\ ( -- t/f) if the esc key or CTL-E has been hit
[ifndef esc?
: esc?
	fkey?
	if 
		dup h1B = swap 5 = or 
	else 
		drop 0 
	then
	;
]

variable numTones 0 l, 0 l,
variable cyclesLeft 0 l, 0 l,
variable toneOutput 0 l, 0 l,
variable toneSum
variable mixDebug 0 l, 0 l, 0 l, 0 l,
variable volume

0 volume L!
0 toneSum L!
0 toneOutput L!

\ set up for 15 tones, currently running at 5 tones per cog

d5 constant tonesPerCog
d3 constant numToneCogs

tonesPerCog numToneCogs u* constant maxNumTones

d256 constant maxVolume

tonesPerCog numTones L!
tonesPerCog numTones 4+ L!
tonesPerCog numTones 4+ 4+ L!


variable tonesArray
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
tonesArray                              constant typeGainVector
tonesArray     maxNumTones 4* +         constant stepVector
tonesArray     maxNumTones 4* 2* +      constant currentStepIndexVector

0 constant typeSin
1 constant typeTriangle
2 constant typeSquare
3 constant typeSaw

\ ( type gain freq index -- )
: setTone 
    maxNumTones min 4* swap freqToStep over stepVector + L! 
    currentStepIndexVector over + 0 swap L!
    rot d16 lshift rot or swap typeGainVector + L!
;
\ ( type gain freq index -- )
: setToneCents 
    maxNumTones min 4* swap centsToStep over stepVector + L! 
    currentStepIndexVector over + 0 swap L!
    rot d16 lshift rot or swap typeGainVector + L!
;

\ ( volume index -- )
: setToneVolume
    4* typeGainVector + dup L@ hFFFF_0000 and rot or swap L!
;
: stv setToneVolume ;


\ ( n -- ) n = 0-256 overall volume
: setVolume
    maxVolume min volume L!
;


\ set up for 15 notes

variable notesArray
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,


d16 d4 u*               constant noteSize
d15                     constant numNotes

\ noteActive    vibrato
\ currentGain   currentVibrato
\ attackStart   128 * gain/ms
\ holdStart     128 * gain/ms
\ decayStart    128 * gain/ms
\ sustainStart  128 * gain/ms
\ releaseStart  128 * gain/ms
\ endStart      0

\ 4 ms to 10 sec 
\ 4-7 hz 5-8 hz 

\ specify freq in cents - 1/100 

\ freq f0 *2^(n/12) 
\ f0 base lo note freq
\ a440 middle
\ a220 
\ a110 
\ a 55
\ 2 27.5
\ a a# b c c# d d# e f f# g g#

\ 12 * 12 notearray specified in cents 
\ piano, barber, indian, culture based, start with piano, aux


variable vibrato
variable noteIndex
variable attackLevel
variable sustainLevel
variable attackMs
variable holdMs
variable decayMs
variable sustainMs
variable releaseMs
variable notePointer


\ setNote ( vibrato attackLevel sustainLevel attackMs holdMs decayMs sustainMs releaseMs type freq noteIndex -- )

: setNote 
    noteIndex L! 0 swap noteIndex L@ setTone
    releaseMs L!
    sustainMs L!
    decayMs L!
    holdMs L!
    attackMs L!
    sustainLevel L!
    attackLevel L!
    vibrato L!

    notesArray noteSize noteIndex L@ u* notePointer L!



;

\ _i2s ( clockMask lrMask dataOutMask dataAddr  -- )

lockdict create _i2s forthentry
$C_a_lxasm w, h136  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
hA0BE5EC8 l, h5CFD72B3 l, hA0BE60C8 l, h5CFD72B3 l, hA0BE62C8 l, h5CFD72B3 l, hA0BE64C8 l, h5CFD72B3 l,
h64BFE930 l, h64BFE931 l, h8BE672F l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l,
h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l,
h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h68BFE931 l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l,
h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l,
h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h64BFE931 l, h5C7C0106 l, hF03E6532 l, hF43E6532 l,
h2DFE6601 l, h70BFE930 l, h5C3C0135 l, 0 l, h4 l, h2 l, h1 l, 0 l,
hFFFF7FFE l, 0 l,
freedict

\ ( toneOutput cyclesLeft currentStepIndexVector stepVector typeGainVector numTonesAddr -- )

lockdict create __genwave forthentry
$C_a_lxasm w, h18D  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
hA0BEFEC8 l, h5CFD72B3 l, hA0BF06C8 l, h5CFD72B3 l, hA0BF0AC8 l, h5CFD72B3 l, hA0BF08C8 l, h5CFD72B3 l,
hA0BF0CC8 l, h5CFD72B3 l, hA0BF04C8 l, h5CFD72B3 l, hA0BF02C8 l, h5CFD72B3 l, hA0BEFDF1 l, h80BEFD7F l,
hF8BEFD7F l, hA0FF1600 l, h8BF1383 l, hA0BEE385 l, h80BEE387 l, h8BF1971 l, hA0BEE384 l, h80BEE387 l,
h8BEFB71 l, hA0BEE386 l, h80BEE387 l, h8BEF971 l, hA0BEE57C l, h80BEE57D l, h83EE571 l, hA0BEE37C l,
h28FEE213 l, hA0BF158C l, h60FF19FF l, h28FF1410 l, h60FF1403 l, h2CFF1403 l, h80FF1554 l, h5C3C018A l,
hA0FEE400 l, h627F1801 l, h8096E571 l, h2CFEE201 l, h28FF1801 l, h627F1801 l, h8096E571 l, h2CFEE201 l,
h28FF1801 l, h627F1801 l, h8096E571 l, h2CFEE201 l, h28FF1801 l, h627F1801 l, h8096E571 l, h2CFEE201 l,
h28FF1801 l, h627F1801 l, h8096E571 l, h2CFEE201 l, h28FF1801 l, h627F1801 l, h8096E571 l, h2CFEE201 l,
h28FF1801 l, h627F1801 l, h8096E571 l, h2CFEE201 l, h28FF1801 l, h627F1801 l, h8096E571 l, h2CFEE201 l,
h28FF1801 l, h627F1801 l, h8096E571 l, h80FEE480 l, h38FEE408 l, h80BF1772 l, h80FF0E04 l, h86FF1201 l,
h5C54010F l, hA0FF0E00 l, h83F1781 l, hA0BEE37E l, h84BEE3F1 l, h83EE382 l, h5C7C010C l, h5C7C0073 l,
h613EE375 l, h623EE376 l, hA4B2E371 l, h68BEE377 l, h2CFEE201 l, h4BEE371 l, hA496E371 l, h5C7C0124 l,
h613EE375 l, h623EE376 l, hA4B2E371 l, h60BEE379 l, h2CFEE205 l, hA496E371 l, h5C7C0124 l, h5C7C0124 l,
h60BEE378 l, h2CFEE204 l, h84BEE37B l, h5C7C0124 l, h5C7C0124 l, h5C7C0124 l, h5C7C0124 l, h5C7C0124 l,
h623EE376 l, hA0AAE37A l, hA0D6E200 l, h84BEE37B l, h5C7C0124 l, 0 l, 0 l, 0 l,
0 l, h800 l, h1000 l, h7000 l, h1FFF l, h7FF l, h1FFFF l, h10000 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, h1 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l,
freedict

\ ( toneAddrs outAddr outSignedAddr volumeAddr --  ) 


lockdict create __mixer forthentry
$C_a_lxasm w, h18E  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
hA0BF0EC8 l, h5CFD72B3 l, hA0BF06C8 l, h5CFD72B3 l, hA0BEFCC8 l, h5CFD72B3 l, hA0BEFAC8 l, h5CFD72B3 l,
hA0BF11F1 l, h80FF1A01 l, h83F057E l, hA0BEFF7D l, hA0FF0400 l, h8BF017F l, h80FEFE04 l, h80BF0580 l,
h8BF017F l, h80FEFE04 l, h80BF0580 l, h8BF017F l, h80BF0580 l, hA0BF038C l, hA0FF0000 l, h627F0201 l,
h80970182 l, h2CFF0401 l, h28FF0201 l, h627F0201 l, h80970182 l, h2CFF0401 l, h28FF0201 l, h627F0201 l,
h80970182 l, h2CFF0401 l, h28FF0201 l, h627F0201 l, h80970182 l, h2CFF0401 l, h28FF0201 l, h627F0201 l,
h80970182 l, h2CFF0401 l, h28FF0201 l, h627F0201 l, h80970182 l, h2CFF0401 l, h28FF0201 l, h627F0201 l,
h80970182 l, h2CFF0401 l, h28FF0201 l, h627F0201 l, h80970182 l, h2CFF0401 l, h28FF0201 l, h627F0201 l,
h80970182 l, h80FF0080 l, h38FF0008 l, hA0BF0580 l, hA0FF0000 l, h41BF0586 l, h80F31201 l, h45BF0585 l,
h80CF1201 l, h83F1B87 l, h80FF0E04 l, h83F1387 l, h80FF0E04 l, h83F1987 l, h80FF0E04 l, h83F0587 l,
h84FF0E0C l, h8BF0983 l, hA0FF0000 l, h627F0801 l, h80970182 l, h2CFF0401 l, h28FF0801 l, h627F0801 l,
h80970182 l, h2CFF0401 l, h28FF0801 l, h627F0801 l, h80970182 l, h2CFF0401 l, h28FF0801 l, h627F0801 l,
h80970182 l, h2CFF0401 l, h28FF0801 l, h627F0801 l, h80970182 l, h2CFF0401 l, h28FF0801 l, h627F0801 l,
h80970182 l, h2CFF0401 l, h28FF0801 l, h627F0801 l, h80970182 l, h2CFF0401 l, h28FF0801 l, h627F0801 l,
h80970182 l, h2CFF0401 l, h28FF0801 l, h627F0801 l, h80970182 l, h80FF0080 l, h38FF0008 l, hA0BF0580 l,
hA0BF01F1 l, h84BF0188 l, h873F018A l, h5C700105 l, hA0FF1A00 l, hA0BF11F1 l, hA0BF0189 l, h877F01FF l,
h28C70008 l, h84871980 l, h867F1200 l, h80EB1801 l, hA0FF1200 l, h44FF1900 l, h40FF1800 l, h5C7C0105 l,
h5C7C0073 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, hFFFF l, hFFFF0000 l, 0 l, 0 l, 0 l, hF4240 l, h200 l,
h100 l, 0 l,
freedict


lockdict create __simwave forthentry
$C_a_lxasm w, h10B  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
hA0BE0EC8 l, h5CFD72B3 l, h8BE1307 l, h80BE130A l, h28FE120C l, h60FE120F l, hA0FE1001 l, h2CBE1109 l,
hA0BFE908 l, h5C7C00FE l, h5C7C0073 l, 0 l, 0 l, 0 l, h8000 l,
freedict

\ set up the i2s 
: runI2s 
	c" __i2s" pad ccopy
    pad cds W!

    d17 pinout d18 pinout d19 pinout 17 bitFrequency setHza
    d17 >m  d18 >m d19 >m toneSum _i2s
;

\ ( n -- ) n - cog offset
: runGenWave
	c" __genwave: " pad ccopy
    dup pad cappendn
    pad cds W!
    4*
    toneOutput over + swap
    cyclesLeft over + swap
    currentStepIndexVector over tonesPerCog u* + swap
    stepVector over tonesPerCog u* + swap
    typeGainVector over tonesPerCog u* + swap
    numTones +
    period
    __genwave
;

\ set up wave simulator, can see the wave on logic analyzer
: runSimWave
	c" __simwave" pad ccopy
    pad cds W!
    dira COG@ hFFFF or dira COG!
    toneSum
    __simwave
;

: runMixer
	c" __mixer" pad ccopy
    pad cds W!
    toneOutput toneSum volume mixDebug __mixer
;

: dd
    typeGainVector d64 dump
    stepVector d64 dump
    currentStepIndexVector d64 dump
;
: dmon 
    begin 
        mixDebug d12 + dup L@ swap 4- dup L@ swap 4- dup L@ swap 4- L@
        . . . .
        cr esc? 
    until 
;

: tmon 
    begin 
        toneOutput L@ . 
        toneOutput 4+ L@ . 
        toneOutput 4+ 4+ L@ . 
        toneSum L@ .
        cr esc? 
    until 
;

: cmon 
    begin 
        cyclesLeft L@ . 
        cyclesLeft 4+ L@ . 
        cyclesLeft 4+ 4+ L@ . 
        cr 1000 delms esc? 
    until 
;


: v setVolume ;

\ : t0  typeSin swap d400  d0   setTone ;
\ : t1  typeSin swap d500  d1   setTone ;
\ : t2  typeSin swap d600  d2   setTone ;
\ : t3  typeSin swap d700  d3   setTone ;
\ : t4  typeSin swap d800  d4   setTone ;
\ : t5  typeSin swap d900  d5   setTone ;
\ : t6  typeSin swap d1000 d6   setTone ;
\ : t7  typeSin swap d1100 d7   setTone ;
\ : t8  typeSin swap d1200 d8   setTone ;
\ : t9  typeSin swap d1300 d9   setTone ;
\ : t10 typeSin swap d1400 d10  setTone ;
\ : t11 typeSin swap d1500 d11  setTone ;
\ : t12 typeSin swap d1600 d12  setTone ;
\ : t13 typeSin swap d1700 d13  setTone ;
\ : t14 typeSin swap d1800 d14  setTone ;



: t0  typeSin swap  d40000 d0   setToneCents ;
: t1  typeSin swap  d50000 d1   setToneCents ;
: t2  typeSin swap  d60000 d2   setToneCents ;
: t3  typeSin swap  d70000 d3   setToneCents ;
: t4  typeSin swap  d80000 d4   setToneCents ;
: t5  typeSin swap  d90000 d5   setToneCents ;
: t6  typeSin swap d100000 d6   setToneCents ;
: t7  typeSin swap d110000 d7   setToneCents ;
: t8  typeSin swap d120000 d8   setToneCents ;
: t9  typeSin swap d130000 d9   setToneCents ;
: t10 typeSin swap d140000 d10  setToneCents ;
: t11 typeSin swap d150000 d11  setToneCents ;
: t12 typeSin swap d160000 d12  setToneCents ;
: t13 typeSin swap d170000 d13  setToneCents ;
: t14 typeSin swap d180000 d14  setToneCents ;


0 t0  0 t1  0 t2  0 t3  0 t4  0 t5  0 t6  0 t7  0 t8  0 t9  0 t10  0 t11  0 t12  0 t13  0 t14 



c" runI2s" 0 cogx
c" 0 runGenWave" 1 cogx
c" 1 runGenWave" 2 cogx
c" 2 runGenWave" 3 cogx
c" runMixer"  4 cogx


256 t0 32 v

128 t7











\ OLD TESTING

\ pin0 - pin15 - simwave __toneOutput
\ pin 17 - bit clock for i2s (32 * LR ) - this is generated by a counter, and the i2s driver synch to this clock
\ pin 18 - i2s LR ( left right signal) 
\ pin 19 - data for i2s

\ cog 0 - i2s driver,  clock A produces the bit clk 44100 sample rate
\ cog 1 - wave generator, possibility for freq < 2 khz ??? generation at 22.5 kHz, 10 waves ???
\ cog 2 - wave generator
\ cog 3 - wave generator / (wave display for lac - for debugging )
\ cog 4 - mixer 
\ cog 5 - tone / note envelope driver
\ cog 6 - ui 
\ cog 7 - serial interface

d17 constant i2sBitClock
d18 constant i2sLrClock
d19 constant i2sData

\ 13 tableAddress bits for look up tables
d8192 constant tableLen

\ 32 bits - 13 bits = 19, shift when using a 32 bit unsigned value to index a table
d19 constant stepShift 

\ sample frequency
d44100 constant sampleFreq

\ clock cycles per sample
clkfreq sampleFreq / constant period

\ clock cycles per millisecond
clkfreq d1000 / constant clocksPerMs

\ bit frequency for i2s
sampleFreq d32 * constant bitFrequency

\ (freq -- stepPerPeriod)
: freqToStep tableLen u* 1 stepShift lshift sampleFreq u*/ ;


: centsToStep  tableLen u* u>d 1 stepShift lshift u>d sampleFreq u>d du*/
    d100 u>d du/mod dswap d>u
    d50 >= if d>u 1 + else d>u then ;

\
\ ( -- t/f) if the esc key or CTL-E has been hit
[ifndef esc?
: esc?
	fkey?
	if 
		dup h1B = swap 5 = or 
	else 
		drop 0 
	then
	;
]

variable numTones 0 l, 0 l,
variable cyclesLeft 0 l, 0 l,
variable toneOutput 0 l, 0 l,
variable toneSum
variable mixDebug 0 l, 0 l, 0 l, 0 l,
variable volume

0 volume L!
0 toneSum L!
0 toneOutput L!

\ set up for 15 tones, currently running at 5 tones per cog

d5 constant tonesPerCog
d3 constant numToneCogs

tonesPerCog numToneCogs u* constant maxNumTones

d256 constant maxVolume

tonesPerCog numTones L!
tonesPerCog numTones 4+ L!
tonesPerCog numTones 4+ 4+ L!


variable tonesArray
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
tonesArray                              constant typeGainVector
tonesArray     maxNumTones 4* +         constant stepVector
tonesArray     maxNumTones 4* 2* +      constant currentStepIndexVector

0 constant typeSin
1 constant typeTriangle
2 constant typeSquare
3 constant typeSaw

\ ( type gain freq index -- )
: setTone 
    maxNumTones min 4* swap freqToStep over stepVector + L! 
    currentStepIndexVector over + 0 swap L!
    rot d16 lshift rot or swap typeGainVector + L!
;

\ ( volume index -- )
: setToneVolume
    4* typeGainVector + dup L@ hFFFF_0000 and rot or swap L!
;
: stv setToneVolume ;


\ ( n -- ) n = 0-256 overall volume
: setVolume
    maxVolume min volume L!
;


\ set up for 15 notes

variable notesArray
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,


d16 d4 u*               constant noteSize
d15                     constant numNotes

\ noteActive    vibrato
\ currentGain   currentVibrato
\ attackStart   128 * gain/ms
\ holdStart     128 * gain/ms
\ decayStart    128 * gain/ms
\ sustainStart  128 * gain/ms
\ releaseStart  128 * gain/ms
\ endStart      0

\ 4 ms to 10 sec 
\ 4-7 hz 5-8 hz 

\ specify freq in cents - 1/100 

\ freq f0 *2^(n/12) 
\ f0 base lo note freq
\ a440 middle
\ a220 
\ a110 
\ a 55
\ 2 27.5
\ a a# b c c# d d# e f f# g g#

\ 12 * 12 notearray specified in cents 
\ piano, barber, indian, culture based, start with piano, aux

\ 

welsh's synthesizer cookbook - github microcosm/cookbok-sc


variable vibrato
variable noteIndex
variable attackLevel
variable sustainLevel
variable attackMs
variable holdMs
variable decayMs
variable sustainMs
variable releaseMs
variable notePointer


\ setNote ( vibrato attackLevel sustainLevel attackMs holdMs decayMs sustainMs releaseMs type freq noteIndex -- )

: setNote 
    noteIndex L! 0 swap noteIndex L@ setTone
    releaseMs L!
    sustainMs L!
    decayMs L!
    holdMs L!
    attackMs L!
    sustainLevel L!
    attackLevel L!
    vibrato L!

    notesArray noteSize noteIndex L@ u* notePointer L!



;

\ _i2s ( clockMask lrMask dataOutMask dataAddr  -- )

lockdict create _i2s forthentry
$C_a_lxasm w, h136  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
hA0BE5EC8 l, h5CFD72B3 l, hA0BE60C8 l, h5CFD72B3 l, hA0BE62C8 l, h5CFD72B3 l, hA0BE64C8 l, h5CFD72B3 l,
h64BFE930 l, h64BFE931 l, h8BE672F l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l,
h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l,
h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h68BFE931 l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l,
h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l,
h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h5CFE6B2A l, h64BFE931 l, h5C7C0106 l, hF03E6532 l, hF43E6532 l,
h2DFE6601 l, h70BFE930 l, h5C3C0135 l, 0 l, h4 l, h2 l, h1 l, 0 l,
hFFFF7FFE l, 0 l,
freedict

\ ( toneOutput cyclesLeft currentStepIndexVector stepVector typeGainVector numTonesAddr -- )

lockdict create __genwave forthentry
$C_a_lxasm w, h18D  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
hA0BEFEC8 l, h5CFD72B3 l, hA0BF06C8 l, h5CFD72B3 l, hA0BF0AC8 l, h5CFD72B3 l, hA0BF08C8 l, h5CFD72B3 l,
hA0BF0CC8 l, h5CFD72B3 l, hA0BF04C8 l, h5CFD72B3 l, hA0BF02C8 l, h5CFD72B3 l, hA0BEFDF1 l, h80BEFD7F l,
hF8BEFD7F l, hA0FF1600 l, h8BF1383 l, hA0BEE385 l, h80BEE387 l, h8BF1971 l, hA0BEE384 l, h80BEE387 l,
h8BEFB71 l, hA0BEE386 l, h80BEE387 l, h8BEF971 l, hA0BEE57C l, h80BEE57D l, h83EE571 l, hA0BEE37C l,
h28FEE213 l, hA0BF158C l, h60FF19FF l, h28FF1410 l, h60FF1403 l, h2CFF1403 l, h80FF1554 l, h5C3C018A l,
hA0FEE400 l, h627F1801 l, h8096E571 l, h2CFEE201 l, h28FF1801 l, h627F1801 l, h8096E571 l, h2CFEE201 l,
h28FF1801 l, h627F1801 l, h8096E571 l, h2CFEE201 l, h28FF1801 l, h627F1801 l, h8096E571 l, h2CFEE201 l,
h28FF1801 l, h627F1801 l, h8096E571 l, h2CFEE201 l, h28FF1801 l, h627F1801 l, h8096E571 l, h2CFEE201 l,
h28FF1801 l, h627F1801 l, h8096E571 l, h2CFEE201 l, h28FF1801 l, h627F1801 l, h8096E571 l, h2CFEE201 l,
h28FF1801 l, h627F1801 l, h8096E571 l, h80FEE480 l, h38FEE408 l, h80BF1772 l, h80FF0E04 l, h86FF1201 l,
h5C54010F l, hA0FF0E00 l, h83F1781 l, hA0BEE37E l, h84BEE3F1 l, h83EE382 l, h5C7C010C l, h5C7C0073 l,
h613EE375 l, h623EE376 l, hA4B2E371 l, h68BEE377 l, h2CFEE201 l, h4BEE371 l, hA496E371 l, h5C7C0124 l,
h613EE375 l, h623EE376 l, hA4B2E371 l, h60BEE379 l, h2CFEE205 l, hA496E371 l, h5C7C0124 l, h5C7C0124 l,
h60BEE378 l, h2CFEE204 l, h84BEE37B l, h5C7C0124 l, h5C7C0124 l, h5C7C0124 l, h5C7C0124 l, h5C7C0124 l,
h623EE376 l, hA0AAE37A l, hA0D6E200 l, h84BEE37B l, h5C7C0124 l, 0 l, 0 l, 0 l,
0 l, h800 l, h1000 l, h7000 l, h1FFF l, h7FF l, h1FFFF l, h10000 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, h1 l,
0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l,
freedict

\ ( toneAddrs outAddr outSignedAddr volumeAddr --  ) 


lockdict create __mixer forthentry
$C_a_lxasm w, h18E  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
hA0BF0EC8 l, h5CFD72B3 l, hA0BF06C8 l, h5CFD72B3 l, hA0BEFCC8 l, h5CFD72B3 l, hA0BEFAC8 l, h5CFD72B3 l,
hA0BF11F1 l, h80FF1A01 l, h83F057E l, hA0BEFF7D l, hA0FF0400 l, h8BF017F l, h80FEFE04 l, h80BF0580 l,
h8BF017F l, h80FEFE04 l, h80BF0580 l, h8BF017F l, h80BF0580 l, hA0BF038C l, hA0FF0000 l, h627F0201 l,
h80970182 l, h2CFF0401 l, h28FF0201 l, h627F0201 l, h80970182 l, h2CFF0401 l, h28FF0201 l, h627F0201 l,
h80970182 l, h2CFF0401 l, h28FF0201 l, h627F0201 l, h80970182 l, h2CFF0401 l, h28FF0201 l, h627F0201 l,
h80970182 l, h2CFF0401 l, h28FF0201 l, h627F0201 l, h80970182 l, h2CFF0401 l, h28FF0201 l, h627F0201 l,
h80970182 l, h2CFF0401 l, h28FF0201 l, h627F0201 l, h80970182 l, h2CFF0401 l, h28FF0201 l, h627F0201 l,
h80970182 l, h80FF0080 l, h38FF0008 l, hA0BF0580 l, hA0FF0000 l, h41BF0586 l, h80F31201 l, h45BF0585 l,
h80CF1201 l, h83F1B87 l, h80FF0E04 l, h83F1387 l, h80FF0E04 l, h83F1987 l, h80FF0E04 l, h83F0587 l,
h84FF0E0C l, h8BF0983 l, hA0FF0000 l, h627F0801 l, h80970182 l, h2CFF0401 l, h28FF0801 l, h627F0801 l,
h80970182 l, h2CFF0401 l, h28FF0801 l, h627F0801 l, h80970182 l, h2CFF0401 l, h28FF0801 l, h627F0801 l,
h80970182 l, h2CFF0401 l, h28FF0801 l, h627F0801 l, h80970182 l, h2CFF0401 l, h28FF0801 l, h627F0801 l,
h80970182 l, h2CFF0401 l, h28FF0801 l, h627F0801 l, h80970182 l, h2CFF0401 l, h28FF0801 l, h627F0801 l,
h80970182 l, h2CFF0401 l, h28FF0801 l, h627F0801 l, h80970182 l, h80FF0080 l, h38FF0008 l, hA0BF0580 l,
hA0BF01F1 l, h84BF0188 l, h873F018A l, h5C700105 l, hA0FF1A00 l, hA0BF11F1 l, hA0BF0189 l, h877F01FF l,
h28C70008 l, h84871980 l, h867F1200 l, h80EB1801 l, hA0FF1200 l, h44FF1900 l, h40FF1800 l, h5C7C0105 l,
h5C7C0073 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l, 0 l,
0 l, hFFFF l, hFFFF0000 l, 0 l, 0 l, 0 l, hF4240 l, h200 l,
h100 l, 0 l,
freedict


lockdict create __simwave forthentry
$C_a_lxasm w, h10B  hFC  1- tuck - h9 lshift swap h1FF and or here W@ alignl h10 lshift or l,
hA0BE0EC8 l, h5CFD72B3 l, h8BE1307 l, h80BE130A l, h28FE120C l, h60FE120F l, hA0FE1001 l, h2CBE1109 l,
hA0BFE908 l, h5C7C00FE l, h5C7C0073 l, 0 l, 0 l, 0 l, h8000 l,
freedict

\ set up the i2s 
: runI2s 
	c" __i2s" pad ccopy
    pad cds W!

    d17 pinout d18 pinout d19 pinout 17 bitFrequency setHza
    d17 >m  d18 >m d19 >m toneSum _i2s
;

\ ( n -- ) n - cog offset
: runGenWave
	c" __genwave: " pad ccopy
    dup pad cappendn
    pad cds W!
    4*
    toneOutput over + swap
    cyclesLeft over + swap
    currentStepIndexVector over tonesPerCog u* + swap
    stepVector over tonesPerCog u* + swap
    typeGainVector over tonesPerCog u* + swap
    numTones +
    period
    __genwave
;

\ set up wave simulator, can see the wave on logic analyzer
: runSimWave
	c" __simwave" pad ccopy
    pad cds W!
    dira COG@ hFFFF or dira COG!
    toneSum
    __simwave
;

: runMixer
	c" __mixer" pad ccopy
    pad cds W!
    toneOutput toneSum volume mixDebug __mixer
;

: dd
    typeGainVector d64 dump
    stepVector d64 dump
    currentStepIndexVector d64 dump
;
: dmon 
    begin 
        mixDebug d12 + dup L@ swap 4- dup L@ swap 4- dup L@ swap 4- L@
        . . . .
        cr esc? 
    until 
;

: tmon 
    begin 
        toneOutput L@ . 
        toneOutput 4+ L@ . 
        toneOutput 4+ 4+ L@ . 
        toneSum L@ .
        cr esc? 
    until 
;

: cmon 
    begin 
        cyclesLeft L@ . 
        cyclesLeft 4+ L@ . 
        cyclesLeft 4+ 4+ L@ . 
        cr 1000 delms esc? 
    until 
;


: v setVolume ;

: t0  typeSin swap  d40000 d0   setToneCents ;
: t1  typeSin swap  d50000 d1   setToneCents ;
: t2  typeSin swap  d60000 d2   setToneCents ;
: t3  typeSin swap  d70000 d3   setToneCents ;
: t4  typeSin swap  d80000 d4   setToneCents ;
: t5  typeSin swap  d90000 d5   setToneCents ;
: t6  typeSin swap d100000 d6   setToneCents ;
: t7  typeSin swap d110000 d7   setToneCents ;
: t8  typeSin swap d120000 d8   setToneCents ;
: t9  typeSin swap d130000 d9   setToneCents ;
: t10 typeSin swap d140000 d10  setToneCents ;
: t11 typeSin swap d150000 d11  setToneCents ;
: t12 typeSin swap d160000 d12  setToneCents ;
: t13 typeSin swap d170000 d13  setToneCents ;
: t14 typeSin swap d180000 d14  setToneCents ;


0 t0  0 t1  0 t2  0 t3  0 t4  0 t5  0 t6  0 t7  0 t8  0 t9  0 t10  0 t11  0 t12  0 t13  0 t14 



c" runI2s" 0 cogx
c" 0 runGenWave" 1 cogx
c" 1 runGenWave" 2 cogx
c" 2 runGenWave" 3 cogx
c" runMixer"  4 cogx





























typeSin d0  d400  d0   setTone





32 t0 16 t5 16 t10 32 v

256 t0 256 t5 20 v

0 t0 0 t5 32 v

\ setNote ( attackLevel sustainLevel attackMs holdMs decayMs sustainMs releaseMs type freq noteIndex -- )

256 128 100 100 100 300 100 typeSin 700 0 setNote


typeSin      d32   d400   d0 setTone 
typeSin      d16   d1200  d5 setTone 
d32 setVolume


typeSin      d256   d400   d0 setTone 
typeSin      d256   d1200  d5 setTone 

typeSin      d0   d400   d0 setTone 
typeSin      d0   d1200  d5 setTone 




typeSin      d16   d1200  d1 setTone 


typeSin      d0   d400  d0 setTone 

typeSquare      d256   d400  d0 setTone 

typeSquare      d32   d400  d0 setTone 

typeSin      d0   d1200 d6 setTone 
d32 setVolume


typeSin      d64   d400  d0 setTone 
typeTriangle d0    d500  d1 setTone 
typeTriangle d0    d600  d2 setTone 
typeTriangle d0    d700  d3 setTone 
typeTriangle d0    d800  d4 setTone 
typeTriangle d0    d900  d5 setTone 
typeTriangle d0    d1000 d6 setTone 
typeTriangle d0    d1100 d7 setTone 
typeTriangle d0    d1200 d8 setTone 
typeTriangle d0    d1300 d9 setTone 
d0 setVolume


\ test scenarios

typeSin      d64   d400  d0 setTone 
typeTriangle d0    d500  d1 setTone 
typeTriangle d0    d600  d2 setTone 
typeTriangle d0    d700  d3 setTone 
typeTriangle d0    d800  d4 setTone 
typeTriangle d0    d900  d5 setTone 
typeTriangle d0    d1000 d6 setTone 
typeTriangle d0    d1100 d7 setTone 
typeTriangle d0    d1200 d8 setTone 
typeTriangle d0    d1300 d9 setTone 
d256 setVolume


typeSin      d256   d400  d0 setTone 
typeTriangle d0    d500  d1 setTone 
typeTriangle d0    d600  d2 setTone 
typeTriangle d0    d700  d3 setTone 
typeTriangle d0    d800  d4 setTone 
typeTriangle d0    d900  d5 setTone 
typeTriangle d0    d1000 d6 setTone 
typeTriangle d0    d1100 d7 setTone 
typeTriangle d0    d1200 d8 setTone 
typeTriangle d0    d1300 d9 setTone 
d256 setVolume

typeSin      d256   d400  d0 setTone 
typeSquare   d128   d1200 d1 setTone 
typeTriangle d0    d600  d2 setTone 
typeTriangle d0    d700  d3 setTone 
typeTriangle d0    d800  d4 setTone 
typeTriangle d0    d900  d5 setTone 
typeTriangle d0    d1000 d6 setTone 
typeTriangle d0    d1100 d7 setTone 
typeTriangle d0    d1200 d8 setTone 
typeTriangle d0    d1300 d9 setTone 
d256 setVolume


typeSin      d64   d400  d0 setTone 
typeTriangle d0    d500  d1 setTone 
typeTriangle d0    d600  d2 setTone 
typeTriangle d0    d700  d3 setTone 
typeTriangle d0    d800  d4 setTone 
typeTriangle d0    d900  d5 setTone 
typeTriangle d0    d1000 d6 setTone 
typeTriangle d0    d1100 d7 setTone 
typeSin      d32   d1200 d8 setTone 
typeTriangle d0    d1300 d9 setTone 
d256 setVolume


typeSin      d64   d400  d0 setTone 
typeTriangle d0    d500  d1 setTone 
typeTriangle d0    d600  d2 setTone 
typeTriangle d0    d700  d3 setTone 
typeTriangle d64   d800  d4 setTone 
typeTriangle d0    d900  d5 setTone 
typeTriangle d0    d1000 d6 setTone 
typeTriangle d0    d1100 d7 setTone 
typeSquare   d0    d1200 d8 setTone 
typeTriangle d0    d1300 d9 setTone 
d256 setVolume




4 cogreset 1000 delms c" runMixer" 4 cogx

\ END TEST



\ set up variable sampling bins for wave generation





////////////// test 1 end


: t 
    h10000 hFFEE do 
        i . i h8000 - dup .  h8000 + . cr
    loop 
    h100 h0 do 
        i . i h8000 - dup .  h8000 + . cr
    loop 
    ;










\ assembler source

\ _i2s ( clockMask lrMask dataOutMask dataAddr -- )  clockMask - input  lrMask,dataOutMask - outputs 
\   dataAddr - pointer to long, 16 bits for each channel left channel is the lo 16 bits signed values
build_BootOpt :rasm
	            mov     __dataAddr , $C_stTOS
	            spop
	            mov     __dataOutMask , $C_stTOS
	            spop
	            mov     __lrMask , $C_stTOS
	            spop
	            mov     __clockMask , $C_stTOS
                spop
                andn    outa , __dataOutMask
                andn    outa , __lrMask
__mainLoop
                rdlong  __currentData , __dataAddr
\ clock - 49
                jmpret  __bitOutRet , # __bitOut
\ max t = 55 clocks
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut

                or      outa , __lrMask

                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                jmpret  __bitOutRet , # __bitOut
                andn    outa , __lrMask
\ clock - 22
                jmp     # __mainLoop
\ clock - 26

__bitOut
                waitpeq __clockMask , __clockMask
\ clock - 0 -- clock 55
                waitpne __clockMask , __clockMask
\ clock - 6
                shl     __currentData , # 1 wc
\ clock - 10
                muxc    outa , __dataOutMask
\ clock - 14
                jmp     __bitOutRet
\ clock - 18    

__dataAddr
                0
__dataOutMask
                4
__lrMask
                2
__clockMask
                1
__currentData
                0
__data
                hFFFF7FFE
__bitOutRet
                0

;asm _i2s


\ ( toneOutput cyclesLeft currentStepIndexVector stepVector typeGainVector numTonesAddr period -- )
build_BootOpt :rasm
                mov     __period , $C_stTOS
                spop
                mov     __numTones , $C_stTOS
                spop
                mov     __typeGainVector , $C_stTOS
                spop
                mov     __stepVector , $C_stTOS
                spop
                mov     __currentStepIndexVector , $C_stTOS
                spop
                mov     __cyclesLeft , $C_stTOS
                spop
                mov     __toneOutput , $C_stTOS
                spop
                mov     __time , cnt
                add     __time , __period
__mainLoop
                waitcnt __time , __period
                mov     __outSum , # 0
                rdlong  __toneLimit , __numTones
__toneLoop 
                mov     __r0 , __typeGainVector
                add     __r0 , __currentToneOffset 
                rdlong  __gain , __r0

                mov     __r0 , __stepVector
                add     __r0 , __currentToneOffset 
                rdlong  __step , __r0

                mov     __r0 , __currentStepIndexVector
                add     __r0 , __currentToneOffset 
                rdlong  __currentStepIndex , __r0

                mov     __r1 , __currentStepIndex
                add     __r1 , __step
                wrlong  __r1 , __r0

                mov     __r0 , __currentStepIndex
                shr     __r0 , # d19
                mov     __type , __gain
                and     __gain , # h1FF
                shr     __type , # d16
                and     __type , # 3

                shl     __type , # 3
                add     __type , # __genRoutines
                jmp     __type
__genret

                mov     __r1 , # 0
                test    __gain , # 1     wz
    if_nz       add     __r1 , __r0
                shl     __r0 , # 1
                shr     __gain , # 1
                test    __gain , # 1     wz
    if_nz       add     __r1 , __r0
                shl     __r0 , # 1
                shr     __gain , # 1
                test    __gain , # 1     wz
    if_nz       add     __r1 , __r0
                shl     __r0 , # 1
                shr     __gain , # 1
                test    __gain , # 1     wz
    if_nz       add     __r1 , __r0
                shl     __r0 , # 1
                shr     __gain , # 1
                test    __gain , # 1     wz
    if_nz       add     __r1 , __r0
                shl     __r0 , # 1
                shr     __gain , # 1
                test    __gain , # 1     wz
    if_nz       add     __r1 , __r0
                shl     __r0 , # 1
                shr     __gain , # 1
                test    __gain , # 1     wz
    if_nz       add     __r1 , __r0
                shl     __r0 , # 1
                shr     __gain , # 1
                test    __gain , # 1     wz
    if_nz       add     __r1 , __r0
                shl     __r0 , # 1
                shr     __gain , # 1
                test    __gain , # 1     wz
    if_nz       add     __r1 , __r0
                add     __r1 , # d128
                sar     __r1 , # 8

                add     __outSum , __r1

                add     __currentToneOffset , # 4

                sub     __toneLimit , # 1             wz
    if_nz       jmp    # __toneLoop

                mov     __currentToneOffset , # 0                
                wrlong  __outSum , __toneOutput
__tonesDone
                mov     __r0 , __time
                sub     __r0 , cnt               
                wrlong  __r0 , __cyclesLeft

                jmp     # __mainLoop

                jexit

\ reach routine must be 8 instructions
__genRoutines
__sin
                test    __r0 , __quad90 wc
                test    __r0 , __quad180 wz
    if_c        neg     __r0 , __r0
                or      __r0 , __sinTable
                shl     __r0 , # 1
                rdword  __r0 , __r0
    if_nz       neg     __r0 , __r0
                jmp     # __genret
__triangle
                test    __r0 , __quad90 wc
                test    __r0 , __quad180 wz
    if_c        neg     __r0 , __r0
                and     __r0 , __angleMask
                shl     __r0 , # 5
    if_nz       neg     __r0 , __r0
                jmp     # __genret
                jmp     # __genret             
__saw
                and     __r0 , __angleMask360
                shl     __r0 , # 4
                sub     __r0 , __midValue
                jmp     # __genret
                jmp     # __genret
                jmp     # __genret
                jmp     # __genret
                jmp     # __genret
__square
                test    __r0 , __quad180 wz
    if_z        mov     __r0 , __maxValue
    if_nz       mov     __r0 , # 0
                sub     __r0 , __midValue
               jmp     # __genret
\ padding no needed on last one
__r0
                0
__r1
                0
__r2
                0
__r3
                0
__quad90
                h800 
__quad180
                h1000 
\ 0xE000 >> 1
__sinTable
                h7000
__angleMask360
                h1FFF
__angleMask
                h7FF
__maxValue
                h1FFFF 
__midValue
                h10000
__currentStepIndex
                0
__step
                0
__time
                0
__period
                0
__debug
                0
__toneOutput
                0
__cyclesLeft
                0
__numTones
                1
__stepVector
                0
__typeGainVector
                0
__currentStepIndexVector
                0
__currentToneOffset 
                0
__toneNum
                0
__toneLimit
                0
__type
                0
__outSum
                0
__gain
                0
;asm __genwave  


\ ( toneAddrs outAddr volumeAddr --  ) 
build_BootOpt :rasm
                mov     __debugAddr , $C_stTOS
                spop
                mov     __volumeAddr , $C_stTOS
                spop
                mov     __outAddr , $C_stTOS
                spop
                mov     __toneAddrs , $C_stTOS
                spop
                mov     __agcStartTime , cnt

__mainLoop
                add     __loopCount , # 1
                wrlong  __value , __outAddr
                mov     __r0 ,  __toneAddrs
                mov     __value , # 0
                rdlong  __r1 , __r0
                add     __r0 , # d4
                add     __value , __r1
                rdlong  __r1 , __r0
                add     __r0 , # d4
                add     __value , __r1
                rdlong  __r1 , __r0
                add     __value , __r1

                mov     __r2 , __agcVolume
                mov     __r1 , # 0
                test    __r2 , # 1     wz
    if_nz       add     __r1 , __value
                shl     __value , # 1
                shr     __r2 , # 1
                test    __r2 , # 1     wz
    if_nz       add     __r1 , __value
                shl     __value , # 1
                shr     __r2 , # 1
                test    __r2 , # 1     wz
    if_nz       add     __r1 , __value
                shl     __value , # 1
                shr     __r2 , # 1
                test    __r2 , # 1     wz
    if_nz       add     __r1 , __value
                shl     __value , # 1
                shr     __r2 , # 1
                test    __r2 , # 1     wz
    if_nz       add     __r1 , __value
                shl     __value , # 1
                shr     __r2 , # 1
                test    __r2 , # 1     wz
    if_nz       add     __r1 , __value
                shl     __value , # 1
                shr     __r2 , # 1
                test    __r2 , # 1     wz
    if_nz       add     __r1 , __value
                shl     __value , # 1
                shr     __r2 , # 1
                test    __r2 , # 1     wz
    if_nz       add     __r1 , __value
                shl     __value , # 1
                shr     __r2 , # 1
                test    __r2 , # 1     wz
    if_nz       add     __r1 , __value
                add     __r1 , # d128
                sar     __r1 , # 8
                mov     __value , __r1

 
                mov     __r1 , # 0
                mins    __value , __minValue    wc
    if_c        add     __agcCount , # 1
                maxs    __value , __maxValue    wc
    if_nc       add     __agcCount , # 1
 
                wrlong  __loopCount , __debugAddr
                add     __debugAddr , # 4
                wrlong  __agcCount , __debugAddr
                add     __debugAddr , # 4
                wrlong  __agcVolume , __debugAddr
                add     __debugAddr , # 4
                wrlong  __value , __debugAddr
                sub     __debugAddr , # d12
                
                rdlong  __volume , __volumeAddr
                mov     __r1 , # 0
                test    __volume , # 1     wz
    if_nz       add     __r1 , __value
                shl     __value , # 1
                shr     __volume , # 1
                test    __volume , # 1     wz
    if_nz       add     __r1 , __value
                shl     __value , # 1
                shr     __volume , # 1
                test    __volume , # 1     wz
    if_nz       add     __r1 , __value
                shl     __value , # 1
                shr     __volume , # 1
                test    __volume , # 1     wz
    if_nz       add     __r1 , __value
                shl     __value , # 1
                shr     __volume , # 1
                test    __volume , # 1     wz
    if_nz       add     __r1 , __value
                shl     __value , # 1
                shr     __volume , # 1
                test    __volume , # 1     wz
    if_nz       add     __r1 , __value
                shl     __value , # 1
                shr     __volume , # 1
                test    __volume , # 1     wz
    if_nz       add     __r1 , __value
                shl     __value , # 1
                shr     __volume , # 1
                test    __volume , # 1     wz
    if_nz       add     __r1 , __value
                shl     __value , # 1
                shr     __volume , # 1
                test    __volume , # 1     wz
    if_nz       add     __r1 , __value
                add     __r1 , # d128
                sar     __r1 , # 8
                mov     __value , __r1

                mov     __r1 , cnt
                sub     __r1 , __agcStartTime 
                cmp     __r1 , __agcPeriod      wz wc
    if_b        jmp     # __mainLoop

                mov     __loopCount , # 0
                mov     __agcStartTime , cnt

                mov     __r1 , __agcCount
                cmp     __r1 , # d511 wz wc
    if_a        shr     __r1 , # 8
    if_a        sub     __agcVolume , __r1
                cmp     __agcCount , # d0   wz 
    if_z        add     __agcVolume , # 1
                mov     __agcCount , # 0

                maxs    __agcVolume , # d256
                mins    __agcVolume , # 0
 
                jmp     # __mainLoop
                jexit
__toneAddrs
                0
__outAddr
                0
__r0
                0
__r1
                0
__r2
                0
__value
                0            
__volumeAddr
                0
__volume
                0
__maxValue
                hFFFF
__minValue
                hFFFF_0000
__debugAddr
                0
__agcStartTime
                0
__agcCount
                0
__agcPeriod
                d1_000_000
__agcThreshold
                d512 
__agcVolume
                d256      
__loopCount
                d0         
;asm __mixer





\ ( addrIn --  ) 
build_BootOpt :rasm
                mov     __addrIn , $C_stTOS
                spop
__mainLoop
                rdlong  __value , __addrIn
                add     __value , __midValue
                shr     __value , # d12
                and     __value , # d15
                mov     __r1 , # 1
                shl     __r1 , __value
                mov     outa , __r1
                jmp     # __mainLoop
                jexit
__addrIn
                0
__r1
                0            
__value
                0           
__midValue
                h8000

;asm __simwave



\ ( addr period --  ) pwm from addr
build_BootOpt :rasm
                mov     __period , $C_stTOS
                spop
                mov     __addr , $C_stTOS
                spop
                mov     __time , cnt
                add     __time , __period
__mainLoop
                rdword  __value , __addr
                shl     __value , # 6
                waitcnt __time , __period
                neg     phsa , __value
                jmp     # __mainLoop
                jexit
__value
                0                
__time
                0
__period
                0
__addr
                0
;asm __pwmout


\
\ 
\
\



\ ( value n -- m  ) 
build_BootOpt :rasm
                mov     __r0 , $C_stTOS
                spop
                mov     __r3 ,  $C_stTOS
                mov     __r2 , # 0
                mov     __r1 , # 1

                test    __r0 , __r1     wz
    if_nz       add     __r2 , __r3
                shl     __r1 , # 1
                shl     __r3 , # 1
                test    __r0 , __r1     wz
    if_nz       add     __r2 , __r3
                shl     __r1 , # 1
                shl     __r3 , # 1
                test    __r0 , __r1     wz
    if_nz       add     __r2 , __r3
                shl     __r1 , # 1
                shl     __r3 , # 1
                test    __r0 , __r1     wz
    if_nz       add     __r2 , __r3
                shl     __r1 , # 1
                shl     __r3 , # 1
                test    __r0 , __r1     wz
    if_nz       add     __r2 , __r3
                shl     __r1 , # 1
                shl     __r3 , # 1
                test    __r0 , __r1     wz
    if_nz       add     __r2 , __r3
                shl     __r1 , # 1
                shl     __r3 , # 1
                test    __r0 , __r1     wz
    if_nz       add     __r2 , __r3
                shl     __r1 , # 1
                shl     __r3 , # 1
                test    __r0 , __r1     wz
    if_nz       add     __r2 , __r3
                shl     __r1 , # 1
                shl     __r3 , # 1
                test    __r0 , __r1     wz
    if_nz       add     __r2 , __r3
                add     __r2 , # d128
                shr     __r2 , # 8
                mov      $C_stTOS , __r2
                jexit
__addrOfAddr
                0
__r0
                0            
__r1
                0            
__r2
                0            
__r3
                0
;asm __volume




\ END assembler source

\ END CURRENT TESTING


