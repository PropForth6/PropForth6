[ifndef _qa 
: _qa _qaf drop 1 >= ;
]
[ifndef _qf
: _qf _qaf nip 1 >= ;
]
[ifndef <in
: <in
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
]
[ifndef out>
: out>
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
]
[ifndef qToIO_t
((( qToIO_t

defW outAddr

::: qToIO_x
	mpInit
	begin
		slice
		<in mpS1! begin mpS1@ outAddr@ _femit? if -1 else slice 0 then until
	0 until
;
)))
]
[ifndef IOToQ_t
((( IOToQ_t

defW inAddr

::: IOTOq_x
	mpInit
	begin
		slice
		outQ@ _qf
		if
			inAddr@ _fkey?
			if
				out>
			else
				drop
			then
		then
	0 until
;
)))
]
[ifndef DBGToQ_t
((( DBGToQ_t

reuseW inAddr

::: DbGTOq_x
	mpInit
	begin
		slice
		outQ@ _qf
		if
			inAddr@ _fkey?
			if
				h80 or out>
			else
				drop
			then
		then
	0 until
;
)))
]
[ifndef _outC
qToIO_t _outC
]
[ifndef _dbgC
qToIO_t _dbgC
]
[ifndef _dbgI
DBGToQ_t _dbgI
]
[ifndef _dbgQ
d60 defCQ _dbgQ
]
[ifndef _outQ
d60 defCQ _outQ
]
_dbgC setThis _dbgQ inQ! _dbg outAddr!
_outC setThis _outQ inQ! $S_con cogio outAddr!
wvariable dbgIO h100 dbgIO W! dbgIO ' _dbg 2+ W!
_dbgI setThis _dbgQ outQ! dbgIO inAddr!

_outC mp+
_dbgC mp+
_dbgI mp+

