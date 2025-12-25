set domakeerr=0

cd ..
gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts\buildinterpreter-1.txt
if %ERRORLEVEL% neq 0 set domakeerr=1
if %domakeerr% neq 0 goto end

:end
echo buildinterpreter.bat result: %domakeerr%

cd DOS
