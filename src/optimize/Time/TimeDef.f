\
\ 2013-Dec-18 Status: Beta
\
\ Provides a high resolution long time system timer by using one cog
\ to update a 64-bit counter as rapidly as possible. The task is
\ bgTimer_t. This task ensures the time is updated time slice cycle. 
\
\ When this words starts it sets the default time zone,
\ Sets the default time to 2012-01-01_12:00:00 UTC,
\ and adjusts the parameters to the current clkfreq 
\
\ This word will be run in one background task at system startup.
\
\ Counts system clock cycles (ticks) since system startup as an
\ unsigned double long.
\
\ This is because we have to use a lock, to update, or to read the
\ 2 longs that make up the double counter.
\
\ The word which updates the double counter, and which reads the
\ double counter, are written in assembler to ensure maximum resolution.
\ 
\ This provides a range of about 7,311 years at 80 Mhz
\ 2^64 / 80,000,000 / 60 / 60 / 24 / 365
\
\ The range will vary if the clock frequency changes, the design point
\ on this was an 80 Mhz system
\
\ Time is then calculated as ticks since 1970-Jan-01_00:00:00
\ only unsigned counts are considered, so minimum date is 1970-Jan-01_00:00:00
\
\ So for the unix people, you can generate a unix time stamp easily
\
\ NOTE: UTC -> local timezone conversion can cause an underflow. 
\
\ setTimeZone ( h m -- ) - sets the time zone h and m can be positive or negative
\
\ setTime ( y m d h m s -- ) sets the UTC time
\
\ setLocalTime ( y m d h m s -- ) subtracts the time zone, then sets UTC time
\
\ getTime ( -- y m d h m s ticks -- ) gets UTC time
\
\ getLocalTime ( -- y m d h m s ticks -- ) gets local time
\ 
\ formatTime ( -- y m d h m s ticks -- cstr) formats a to a printable sortable string
\
\ getTimeStr( -- cstr) get the current UTC time as a string
\
\ getLocalTimeStr( -- cstr) get the current local time as a string
\
\ time ( -- ) print the local time
\
\ setDriftCorrection ( n1 -- ) sets the time correction to n1 ticks per day
\
\ utc ( -- ) print the utc time
\
\ timeStamp ( -- lo hi) gets a number which is the time stamp in microseconds (UTC)
\                       the number of microseconds since 1970-01-01_00:00:00
\                       print with d. or the double format words 
\
\ unixTimeStamp ( -- lo hi) gets a number which is the time stamp in seconds (UTC)
\                           the number of seconds since 1970-01-01_00:00:00
\                           print with d. or the double format words
\
\
1 wconstant build_time
