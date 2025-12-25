
cd ..
Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\StartKernel.eeprom
if %ERRORLEVEL% neq 0 set domakeerr=998
if %domakeerr% neq 0 goto end

gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts\mp\buildMpOptKernel.txt
if %ERRORLEVEL% neq 0 set domakeerr=2
if %domakeerr% neq 0 goto end

Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\mp\mpOptKernel.eeprom
if %ERRORLEVEL% neq 0 set domakeerr=997
if %domakeerr% neq 0 goto end

gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts\mp\buildMpKernel.txt
if %ERRORLEVEL% neq 0 set domakeerr=3
if %domakeerr% neq 0 goto end

:end
echo buildMpKernel.bat result: %domakeerr%

cd DOS
