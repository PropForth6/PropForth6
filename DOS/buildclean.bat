set domakeerr=0

rmdir /S /Q results
mkdir results
mkdir results\runLogs
mkdir results\resultFiles
mkdir results\outputFiles

mkdir results\runLogs\dev
mkdir results\resultFiles\dev
mkdir results\outputFiles\dev

mkdir results\runLogs\mp
mkdir results\resultFiles\mp
mkdir results\outputFiles\mp

cd DOS
:end
echo buildclean.bat result: %domakeerr%

