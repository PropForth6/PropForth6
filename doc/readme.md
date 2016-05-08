
Stock Kernels are at:

PropForth6/refResults/outputFiles/

---

Propforth6 can be downloaded as a spin or eeprom file, ready to load into your prop board, and will propforth will be active after next power cycle.  This is desirable if you just want the stock development kernel, and want to jump in and start bit-banging. 

Alternatively, Propforth6 can built from scratch using the source code and tools identical to what the author uses. This is desirable if  you want a custom kernel that builds in (for example) a special driver that starts propforth from a storage media other than eeprom or SD card memory; or build a custom FPGA version of the prop that for example adds more cogs (cpu cores) and cog memory and/or hub memory.  Sal's "stock" FPGA propforth builds a 16 cog (?)  128k hub ram (?) [check these, as this may change during development] on the BEMicro XXXXX.  

---

To download the Ready-to-Run reference kernels for Propforth6, in this github repository, navigate to the directory:  

PropForth6/refResults/outputFiles/

Locate the xxx.spin or xxx.eeprom that looks like the one you want.   

We usually want:
 * The optimized development kernel - devKernel.spin
 * Optimized Dev kernel with support for upper 32K EEprom used as storage - EEpromKernel.spin
 * Optimized Dev kernel with support for external SD card used as storage - SDkerenl.spin

The SPIN file can be loaded to the prop using any tool that loads spin files to the prop.  The EEPROM files can be loaded to the prop with any tool that loads EEPROM files to the prop.  The EEprom version of the above is an EEprom image rather than a spin source code file. Once loaded, the image in the prop will be identical using either, unless some error has occured.

Load, power cycle, and the propforth command prop wll be available on the prop serial connection.  Any terminal program capable of communicating with the FTDI US virtyual comm port will be sufficient for a terminal session.   

Propforth6 by default is 230400 baud, and needs the terminal program to add LF.  The terminal program needs to be set for hardware flow control on/off and software flow control on/off.  If the output looks strange toggle these settings. 

---

To build (any) Propforth6 kernel(s) (stock or custom) from source code:

Follow the instructions in the README-setup-notes.txt file.  These may be terse or cryptic, please point out any difficulties or deficiences and I will try to address issues. 

The README-setup-notes.txt file references the individual files for setting up each of the constituent parts pf the tool chain. Some commands are only run once, some are run every time we re-compile as these launch the compiler. Please follow the instructions closely until you are familiar with the steps.  Then provide feed back as to how we should change these instructions to make them more useful. 














