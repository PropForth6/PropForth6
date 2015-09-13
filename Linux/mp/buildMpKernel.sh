cd ..
Linux/bstl.linux -p 3 results/outputFiles/StartKernel.eeprom
goterm $1 $2 1 v w r scripts/mp/buildMpOptKernel.txt

Linux/bstl.linux -p 3 results/outputFiles/mp/mpOptKernel.eeprom
goterm $1 $2 1 v w r scripts/mp/buildMpKernel.txt
