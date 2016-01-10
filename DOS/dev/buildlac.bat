set domakeerr=0

if %INGOSHELL% neq 1 set domakerr=999
if %domakeerr% neq 0 goto end

cd ..
DOS\propellent /PORT %PROPCOMM% /EEPROM results\outputFiles\dev\devKernel.eeprom
if %ERRORLEVEL% neq 0 set domakeerr=998
if %domakeerr% neq 0 goto end

goterm %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/dev/buildlac.txt
if %ERRORLEVEL% neq 0 set domakeerr=2
if %domakeerr% neq 0 goto end

:end
echo buildlac.bat result: %domakeerr%

cd DOS
