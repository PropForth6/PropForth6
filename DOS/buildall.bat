set domakeerr=0

if %INGOSHELL% neq 1 set domakerr=999
if %domakeerr% neq 0 goto end

call buildclean.bat
echo buildclean.bat result: %domakeerr%
if %domakeerr% neq 0 goto end

call buildasm.bat
echo buildasm.bat result: %domakeerr%
if %domakeerr% neq 0 goto end

call buildinterpreter.bat
echo buildinterpreter.bat result: %domakeerr%
if %domakeerr% neq 0 goto end

call buildStartKernel.bat
echo buildStartKernel.bat result: %domakeerr%
if %domakeerr% neq 0 goto end

call buildStartKernelSpin.bat
echo buildStartKernelSpin.bat result: %domakeerr%
if %domakeerr% neq 0 goto end

call buildopts.bat
echo builopts.bat result: %domakeerr%
if %domakeerr% neq 0 goto end

call buildOptKernel.bat
echo buildOptKernel.bat result: %domakeerr%
if %domakeerr% neq 0 goto end

call buildMpOptKernel.bat
echo  buildMpOptKernel.bat result: %domakeerr%
if %domakeerr% neq 0 goto end


:end
echo buildall.bat result: %domakeerr%

