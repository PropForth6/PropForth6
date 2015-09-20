cd ..
LinuxOSX/bstl.linux -p 3 results/outputFiles/mp/mpOptKernel.eeprom
goterm $1 $2 1 v w r scripts/mp/buildMpOptKernelSpin.txt

Linux/bstl.linux -p 3 results/outputFiles/mp/mpKernel.eeprom
goterm $1 $2 1 v w r scripts/mp/buildMpKernelSpin.txt
