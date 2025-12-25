cd ..
Linux/bstl.linux -p 3 src/devKernel.eeprom
gocmd $1 $2 1 v w r scripts/dev/buildlac.txt
