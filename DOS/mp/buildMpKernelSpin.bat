set domakeerr=0

cd ..
Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\mp\mpOptKernel.eeprom
if %ERRORLEVEL% neq 0 set domakeerr=998
if %domakeerr% neq 0 goto end

gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts\mp\buildMpOptKernelSpin.txt
if %ERRORLEVEL% neq 0 set domakeerr=2
if %domakeerr% neq 0 goto end

Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\mp\mpKernel.eeprom
if %ERRORLEVEL% neq 0 set domakeerr=998
if %domakeerr% neq 0 goto end

gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts\mp\buildMpKernelSpin.txt
if %ERRORLEVEL% neq 0 set domakeerr=2
if %domakeerr% neq 0 goto end

:end
echo buildDevKernelSpin.bat result: %domakeerr%

cd DOS
