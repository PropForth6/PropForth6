
set PROPCOMM=COM19
set PROPBAUD=230400
set PROPFLOWCONTROL=1

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

REM build asm
Propellent.exe /port %PROPCOMM% /eeprom src\StartKernel.eeprom
gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/buildasm-0.txt

REM build interprter
gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/buildinterpreter-1.txt

REM build StartKernel
Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\Tmp01Kernel.eeprom
gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/buildStartKernel-2.txt

REM build StartKernel spin
Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\StartKernel.eeprom
gocmd $serport $serbaud  1 v w r scripts/buildStartKernelSpin-3.txt

REM build opts
Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\StartKernel.eeprom
gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/buildopts-4.txt

REM build OptKernel
Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\StartKernel.eeprom
gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/buildOptKernel-5.txt

REM build OptKernel spin
Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\OptKernel.eeprom
gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/buildOptKernel-7.txt

REM build DevKernel
Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\optKernel.eeprom
gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/dev/buildDevKernel.txt

REM build DevKernel spin
Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\dev\devKernel.eeprom
gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/dev/buildDevKernelSpin.txt

REM build MpKernel
Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\StartKernel.eeprom
gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/mp/buildMpOptKernel.txt
Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\mp\mpOptKernel.eeprom
gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/mp/buildMpKernel.txt

REM build MpKernel spin
Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\mp\mpOptKernel.eeprom
gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/mp/buildMpOptKernelSpin.txt
Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\mp\mpKernel.eeprom
gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/mp/buildMpKernelSpin.txt

REM build lac
Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\dev\devKernel.eeprom
gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/dev/buildlac.txt

REM build LacKernel
Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\dev\devKernel.eeprom
gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/dev/buildLacKernel.txt

REM build LacKernel spin
Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\dev\lacKernel.eeprom
gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/dev/buildLacKernelSpin.txt

REM build FsKernel
Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\dev\devKernel.eeprom
gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/dev/buildFsKernel.txt

REM build FsKernel spin
Propellent.exe /port %PROPCOMM% /eeprom results\outputFiles\dev\fsKernel.eeprom
gocmd %PROPCOMM% %PROPBAUD% %PROPFLOWCONTROL% v w r scripts/dev/buildFsKernelSpin.txt




