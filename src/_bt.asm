
\
\ cog 0 is used by the spin interpreter to start
\ the fpga version has no spin interpreter
\
\ do not change the name - the length is important
\ do no change load address - the assembler generates a long containing parameters and the boot code must start at 0
\
\ if there is critical initialization to be done as fast as possbile after boot, this is where to do it
\ use the supplied subroutine
\

-1 :rasm
	coginit __initparam
__lforever
	jmp # __lforever
__initparam
	0
;asm _bt

