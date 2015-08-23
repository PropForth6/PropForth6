\
\
\ The structure which will be in cog memory
1 wconstant build_sd
\
\ the adresses of the mask bits for the sd io
\
coghere W@ wconstant v_sdbase
v_sdbase	wconstant v_sd_do
v_sd_do	1+	wconstant v_sd_di
v_sd_di	1+	wconstant v_sd_clk
\
\ 
\ the block number of the current directory
\
v_sd_clk 1+	wconstant v_currentdir
\
\
\ set the data area for the buffer at the end of the assembler code, the allocation is done in sd_init 
\
v_currentdir 1+	wconstant sd_cogbuf
\
sd_cogbuf h80 +	wconstant _sd_cogend
\
\
\
\
\
\ SD CONFIG PARAMETERS BEGIN
\
\ definitions for io pins connecting to the sd card
\
[ifndef $S_sd_cs
19 wconstant $S_sd_cs
]
[ifndef $S_sd_di
20 wconstant $S_sd_di
]
[ifndef $S_sd_clk
21 wconstant $S_sd_clk
]
[ifndef $S_sd_do
16 wconstant $S_sd_do
]
\
\
\
\ SD CONFIG PARAMETERS END
\
\
