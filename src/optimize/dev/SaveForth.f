\
\
\ saveforth( -- ) write the running image to eeprom UPDATES THE CURRENT VERSION STR
[ifndef saveforth
: saveforth
	c" wlastnfa" find
	if
		version W@ dup C@ + dup C@ 1+ swap C!
		pfa>nfa here W@ swap
		begin dup W@ over EW! 2+ dup h3F and 0= until
		do
			ibound i - h40 min dup i dup rot 
			eewritepage if hA ERR then _p? if h2E emit then
		+loop	 
	else
		drop
	then
	_p?
	if
		cr
	then
;
]
