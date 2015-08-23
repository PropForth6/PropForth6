\
\ Output of assembling OpimizeAsmSrc.f goes above this comment block
\
\
\
\ u* ( u1 u2 -- u1*u2) u1 multiplied by u2
: u*
	um* drop
;

\ u/mod ( u1 u2 -- remainder quotient ) \ unsigned divide & mod  u1 divided by u2
: u/mod
	0 swap um/mod
;

\
\
\ u/ ( u1 u2 -- u1/u2) u1 divided by u2
: u/
	u/mod nip
;
