\ term (cog channel -- )
[ifndef term
: term
	over cognchan min ." Hit CTL-P to exit term, CTL-Q exit nest1 CTL-R exit nest2 ... CTL-exit nest9~h0D~h0A"
	>r >r cogid 0 r> r> (iolink)
	begin
		key dup h10 =
		if
			drop -1
		else
			dup h11 h19 between
			if
				1-
			then
			emit 0
		then
	until
	cogid iounlink
;
]
