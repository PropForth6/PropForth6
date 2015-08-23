
[ifndef sliceLock
7 wconstant sliceLock
]
[ifndef numBG
\ minimum 32
d_128 wconstant numBG
]
[ifndef sqz
\ +1 for the queue space ( head cannot equal tail), + 1 for queue/dequeue + 
numBG d_9 + 1+ -2 and wconstant sqz
]
[ifndef sliceQ
\ + 4 bytes for the queue overhead
h8000 sqz 2 lshift 4 + - wconstant sliceQ
]
[ifndef bgQ
\ + 4 bytes for the queue overhead
sliceQ sqz 1 lshift  4 + -  wconstant bgQ
]


