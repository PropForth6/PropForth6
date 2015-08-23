\
\
1 wconstant build_LogicAnalyzer
\
\
{
\ demo run on cog6


\ example1
\ 40 cycles clkfreq 40 2* /

c" 0 1000000 setHza 1  500000 setHzb" 0 cogx
c" 2  250000 setHza 3  125000 setHzb" 1 cogx
lac

\ example2
\ 41 cycles clkfreq 41 2* /
c" 0 975610 setHza 1 487805 setHzb" 0 cogx
c" 2 243902 setHza 3 121951 setHzb" 1 cogx
lac

\ example3
\ 50 cycles clkfreq 50 2* /

c" 0 800000 setHza 1 400000 setHzb" 0 cogx
c" 2 200000 setHza 3 100000 setHzb" 1 cogx
lac



\
\
\ if laconsole is not defined
\ example1
\ 40 cycles clkfreq 40 2* /

c" 0 1000000 setHza 1  500000 setHzb" 0 cogx
c" 2  250000 setHza 3  125000 setHzb" 1 cogx
80 0 la_sample+Trigger
40 0 la_sample+Trigger
20 0 la_sample+Trigger
4 0 la_sample+Trigger
1 0 la_sample+Trigger

\ example2
\ 41 cycles clkfreq 41 2* /
c" 0 975610 setHza 1 487805 setHzb" 0 cogx
c" 2 243902 setHza 3 121951 setHzb" 1 cogx
82 0 la_sample+Trigger
41 0 la_sample-Trigger
20 0 la_sample-Trigger
4 0 la_sample-Trigger
1 0 la_sample-Trigger

\ example3
\ 50 cycles clkfreq 50 2* /

c" 0 800000 setHza 1 400000 setHzb" 0 cogx
c" 2 200000 setHza 3 100000 setHzb" 1 cogx
50 la_sampleNoTrigger
25 la_sampleNoTrigger
4 la_sampleNoTrigger
1 la_sampleNoTrigger

}
\ a cog special register
[ifndef ctra
h1F8	wconstant ctra
]

\ a cog special register
[ifndef ctrb
h1F9	wconstant ctrb 
]

\ a cog special register
[ifndef frqa
h1FA	wconstant frqa 
]

\ a cog special register
[ifndef frqb
h1FB	wconstant frqb 
]

\ a cog special register
[ifndef phsa
h1FC	wconstant phsa 
]

\ a cog special register
[ifndef phsb
h1FD	wconstant phsb 
]

