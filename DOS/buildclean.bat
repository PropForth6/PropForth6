set domakeerr=0

if %INGOSHELL% neq 1 set domakerr=999
if %domakeerr% neq 0 goto end

rmdir MAKE\results /S /Q
mkdir MAKE\results
mkdir MAKE\results\runLogs
mkdir MAKE\results\resultFiles
mkdir MAKE\results\outputFiles

:end
echo buildclean.bat result: %domakeerr%

