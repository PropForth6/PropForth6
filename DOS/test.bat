set PROPCOMM=COM3
set PROPBAUD=230400
set PROPFLOWCONTROL=1
set INGOSHELL=1
set PATH=%PATH%;tools\mygo\bin
call buildStartKernel.bat
echo buildStartKernel.bat result: %domakeerr%
if %domakeerr% neq 0 goto end
