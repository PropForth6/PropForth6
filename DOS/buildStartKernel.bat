set domakeerr=0

if %INGOSHELL% neq 1 set domakerr=999
if %domakeerr% neq 0 goto end

cd ..
DOS\propellent /PORT %PROPCOMM% /EEPROM results\outputFiles\Tmp01Kernel.eeprom
if %ERRORLEVEL% neq 0 set domakeerr=998
if %domakeerr% neq 0 goto end

goterm %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/buildStartKernel-2.txt
if %ERRORLEVEL% neq 0 set domakeerr=2
if %domakeerr% neq 0 goto end

:end
echo buildstartkernel.bat result: %domakeerr%

cd DOS
