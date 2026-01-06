set domakeerr=0

call dev\buildFsKernel.bat
echo buildFsKernel.bat result: %domakeerr%
if %domakeerr% neq 0 goto end

call dev\buildFsKernelSpin.bat
echo buildFsKernelSpin.bat result: %domakeerr%
if %domakeerr% neq 0 goto end

:end
echo test.bat result: %domakeerr%
