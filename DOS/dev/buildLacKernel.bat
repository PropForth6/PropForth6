set domakeerr=0

cd ..
Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\dev\devKernel.eeprom
if %ERRORLEVEL% neq 0 set domakeerr=998
if %domakeerr% neq 0 goto end

gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/dev/buildLacKernel.txt
if %ERRORLEVEL% neq 0 set domakeerr=2
if %domakeerr% neq 0 goto end

:end
echo buildLacKernel.bat result: %domakeerr%

cd DOS
