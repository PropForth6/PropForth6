#!/bin/bash

serport="/dev/ttyUSB0"
serbaud=230400

# build clean
rm -rf results
mkdir results
mkdir results/runLogs
mkdir results/resultFiles
mkdir results/outputFiles
mkdir results/runLogs/dev
mkdir results/resultFiles/dev
mkdir results/outputFiles/dev
mkdir results/runLogs/mp
mkdir results/resultFiles/mp
mkdir results/outputFiles/mp

# build asm
bstl.linux -p 3 src/StartKernel.eeprom
gocmd $serport $serbaud 1 v w r scripts/buildasm-0.txt

# build interprter
gocmd $serport $serbaud 1 v w r scripts/buildinterpreter-1.txt

# build StartKernel
bstl.linux -p 3 results/outputFiles/Tmp01Kernel.eeprom
gocmd $serport $serbaud 1 v w r scripts/buildStartKernel-2.txt

# build StartKernel spin
bstl.linux -p 3 results/outputFiles/StartKernel.eeprom
gocmd $serport $serbaud  1 v w r scripts/buildStartKernelSpin-3.txt

# build opts
bstl.linux -p 3 results/outputFiles/StartKernel.eeprom
gocmd $serport $serbaud 1 v w r scripts/buildopts-4.txt

# build OptKernel
bstl.linux -p 3 results/outputFiles/StartKernel.eeprom
gocmd $serport $serbaud 1 v w r scripts/buildOptKernel-5.txt

# build OptKernel spin
bstl.linux -p 3 results/outputFiles/OptKernel.eeprom
gocmd $serport $serbaud 1 v w r scripts/buildOptKernel-7.txt

# build DevKernel
bstl.linux -p 3 results/outputFiles/optKernel.eeprom
gocmd $serport $serbaud 1 v w r scripts/dev/buildDevKernel.txt

# build DevKernel spin
bstl.linux -p 3 results/outputFiles/dev/devKernel.eeprom
gocmd $serport $serbaud 1 v w r scripts/dev/buildDevKernelSpin.txt

# build MpKernel
bstl.linux -p 3 results/outputFiles/StartKernel.eeprom
gocmd $serport $serbaud 1 v w r scripts/mp/buildMpOptKernel.txt
bstl.linux -p 3 results/outputFiles/mp/mpOptKernel.eeprom
gocmd $serport $serbaud 1 v w r scripts/mp/buildMpKernel.txt

# build MpKernel spin
bstl.linux -p 3 results/outputFiles/mp/mpOptKernel.eeprom
gocmd $serport $serbaud 1 v w r scripts/mp/buildMpOptKernelSpin.txt
bstl.linux -p 3 results/outputFiles/mp/mpKernel.eeprom
gocmd $serport $serbaud 1 v w r scripts/mp/buildMpKernelSpin.txt

# build lac
bstl.linux -p 3 results/outputFiles/dev/devKernel.eeprom
gocmd $serport $serbaud 1 v w r scripts/dev/buildlac.txt

# build LacKernel
bstl.linux -p 3 results/outputFiles/dev/devKernel.eeprom
gocmd $serport $serbaud 1 v w r scripts/dev/buildLacKernel.txt

# build  LacKernel spin
bstl.linux -p 3 results/outputFiles/dev/lacKernel.eeprom
gocmd $serport $serbaud 1 v w r scripts/dev/buildLacKernelSpin.txt

# build FsKernel
bstl.linux -p 3 results/outputFiles/dev/devKernel.eeprom
gocmd $serport $serbaud 1 v w r scripts/dev/buildFsKernel.txt

# build FsKernel spin
bstl.linux -p 3 results/outputFiles/dev/fsKernel.eeprom
gocmd $serport $serbaud 1 v w r scripts/dev/buildFsKernelSpin.txt

