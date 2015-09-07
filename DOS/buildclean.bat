set domakeerr=0

if %INGOSHELL% neq 1 set domakerr=999
if %domakeerr% neq 0 goto end

rmdir MAKE\results /S /Q
mkdir MAKE\results
mkdir MAKE\results\runLogs
mkdir MAKE\results\resultFiles
mkdir MAKE\results\outputFiles

mkdir MAKE\results\runLogs\dev
mkdir MAKE\results\resultFiles\dev
mkdir MAKE\results\outputFiles\dev

mkdir MAKE\results\runLogs\mp
mkdir MAKE\results\resultFiles\mp
mkdir MAKE\results\outputFiles\mp


:end
echo buildclean.bat result: %domakeerr%

