cd ..
OSX/bstl.osx -p 3 results/outputFiles/StartKernel.eeprom
goterm $1 $2 1 v w r scripts/mp/buildMpOptKernel.txt

OSX/bstl.osx -p 3 results/outputFiles/mp/mpOptKernel.eeprom
goterm $1 $2 1 v w r scripts/mp/buildMpKernel.txt
