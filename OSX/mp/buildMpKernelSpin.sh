cd ..
OSX/bstl.osx -p 3 results/outputFiles/mp/mpOptKernel.eeprom
goterm $1 $2 1 v w r scripts/mp/buildMpOptKernelSpin.txt

OSX/bstl.osx -p 3 results/outputFiles/mp/mpKernel.eeprom
goterm $1 $2 1 v w r scripts/mp/buildMpKernelSpin.txt
