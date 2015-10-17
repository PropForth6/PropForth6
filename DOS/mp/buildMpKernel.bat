
if %INGOSHELL% neq 1 set domakerr=999
if %domakeerr% neq 0 goto end

cd ..
DOS\propellent /PORT %PROPCOMM% /EEPROM results\outputFiles\StartKernel.eeprom
if %ERRORLEVEL% neq 0 set domakeerr=998
if %domakeerr% neq 0 goto end

goterm %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/mp/buildMpOptKernel.txt
if %ERRORLEVEL% neq 0 set domakeerr=2
if %domakeerr% neq 0 goto end

DOS\propellent /PORT %PROPCOMM% /EEPROM results\outputFiles\mp\mpOptKernel.eeprom
if %ERRORLEVEL% neq 0 set domakeerr=997
if %domakeerr% neq 0 goto end

goterm %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/mp/buildMpKernel.txt
if %ERRORLEVEL% neq 0 set domakeerr=3
if %domakeerr% neq 0 goto end

:end
echo buildMpKernel.bat result: %domakeerr%

cd DOS
