cd ..
OSX/bstl.osx -p 3 results/outputFiles/StartKernel.eeprom
gocmd $1 $2 1 v w r scripts/mp/buildMpOptKernel.txt

OSX/bstl.osx -p 3 results/outputFiles/mp/mpOptKernel.eeprom
gocmd $1 $2 1 v w r scripts/mp/buildMpKernel.txt
