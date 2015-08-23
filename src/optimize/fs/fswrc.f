\
\ _nk ( buf -- buf key)
: _nk
	dup h18 rshift swap _fsk swap
;
\
\ same as fswrite but eliminates comments and whitespace
\
: fswritec
	cogid nfcog iolink
	parsenw
	." fswrite " .cstr cr
\
\ buffer 4 characters
\
	key _fsk _fsk _fsk
	begin
		dup h2E2E2E0D =
		if
			-1
		else
			_nk
\
\ drop lines between braces {}
\
			dup h7B =
			if
				drop
				begin _nk h7D = until
				_nk
			then
\
\ drop comment lines
\
			dup h5C =
			if
				drop
				begin _nk h0D = until
			else
				dup h0D =
				if
					drop
				else
\
\ drop spaces and tabs at the beginning of a line
\
					begin
						dup h20 = over h09 = or
						if
							drop _nk 0
						else
							-1
						then
					until
\
\ emit chars until we get a cr or find a ...CR  sequence
\
					dup h0D =
					if
						drop
					else
						begin
							dup h22 =
							if
								emit begin _nk dup emit h22 = until
								_nk
							then
							dup h20 = over h09 = or
							if
								begin drop _nk dup h20 <> over h09 <> and until
								dup h0D <>
								if space then
							then
							dup emit h0D <>
							if
								dup h2E2E2E0D =
								if
									-1
								else
									_nk 0
								then
							else
								-1
							then
						until
					then
				then
			then	
			0
		then
	until
	drop
	." ...~h0D~h0D~h0D"
	cogid iounlink
;
