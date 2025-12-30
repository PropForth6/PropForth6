set PROPCOMM=COM17
set PROPBAUD=230400
set PROPFLOWCONTROL=1

call dev\buildlac.bat
echo buildlac.bat result: %domakeerr%
if %domakeerr% neq 0 goto end


call dev\buildLacKernel.bat
echo buildLacKernel.bat result: %domakeerr%
if %domakeerr% neq 0 goto end

call dev\buildLacKernelSpin.bat
echo builLacKernelSpin.bat result: %domakeerr%
if %domakeerr% neq 0 goto end

:end
echo test.bat result: %domakeerr%
