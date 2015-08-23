\ serafc ( n1 n2 n3 t/f -- ) 
\ n1 - tx pin
\ n2 - rx pin
\ n3 - baud rate / 4 - the actual baud rate will be 4 * this number
\ t/f - flow control on/off
\
\ 
\ _serafc ( -- ) 
\ pad + 12 - n1 - clocks/bit
\ pad +  8 - n2 - txmask 
\ pad +  4 - n3 - rxmask 
\ pad +  0 - t/f - flow control on/off
\
\ parameters are passed this way to eliminate the dependencies of the kernel assembler
\
: serafc
	c" SERAFC " pad ccopy
	dup if
		c"  FC "
	else
		c" NFC "
	then
	pad cappend

	over 4* pad cappendn
	c"  TX:" pad cappend 3 ST@ pad cappendn
	c"  RX:" pad cappend 2 ST@ pad cappendn 

	pad numpad ccopy numpad cds W!
	4 state andnC!
	pad L!	
	4* clkfreq swap u/ pad d_12 + L!
	>m tuck pad 4+ L!
	>m tuck pad 8 + L!
\ ( txmask rxmask -- )
	over _maskouthi dira COG@ over andn 2 ST@ or dira COG!
	h100 io L!
\ (bitticks txmask rxmask t/f --)
\
\
	_serafc
;
\
\
\ initcon ( -- ) initialize the default serial console on this cog
: initcon
	$S_txpin $S_rxpin $S_baud $S_flowControl serafc
;

