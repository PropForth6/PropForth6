#!/bin/bash

serport="/dev/ttyUSB0"
serbaud=230400

# build lac
bstl.linux -p 3 results/outputFiles/dev/devKernel.eeprom
gocmd $serport $serbaud 1 v w r scripts/dev/buildlac.txt

# build LacKernel
bstl.linux -p 3 results/outputFiles/dev/devKernel.eeprom
gocmd $serport $serbaud 1 v w r scripts/dev/buildLacKernel.txt

# build  LacKernel spin
bstl.linux -p 3 results/outputFiles/dev/lacKernel.eeprom
gocmd $serport $serbaud 1 v w r scripts/dev/buildLacKernelSpin.txt

