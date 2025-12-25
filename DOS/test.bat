set PROPCOMM=COM19
set PROPBAUD=230400
set PROPFLOWCONTROL=1

call dev\buildDevKernel.bat
echo buildDevKernel.bat result: %domakeerr%
if %domakeerr% neq 0 goto end

call dev\buildDevKernelSpin.bat
echo buildDevKernelSpin.bat result: %domakeerr%
if %domakeerr% neq 0 goto end

call mp\buildMpKernel.bat
echo buildMpKernel.bat result: %domakeerr%
if %domakeerr% neq 0 goto end

call mp\buildMpKernelSpin.bat
echo buildMpKernelSpin.bat result: %domakeerr%
if %domakeerr% neq 0 goto end

