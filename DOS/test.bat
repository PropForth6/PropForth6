set PROPCOMM=COM3
set PROPBAUD=230400
set PROPFLOWCONTROL=1
set INGOSHELL=1
set PATH=%PATH%;tools\mygo\bin

call mp\buildMpKernel.bat
echo buildMpKernel.bat result: %domakeerr%
if %domakeerr% neq 0 goto end

call mp\buildMpKernelSpin.bat
echo buildMpKernelSpin.bat result: %domakeerr%
if %domakeerr% neq 0 goto end

