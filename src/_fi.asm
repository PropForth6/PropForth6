
-1 _rasms
C_treg1
                       jmp		# C_a_next
C_treg2
                       0
\
\ C_IP is initialized during the build process to fstart PFA
\
C_IP
						0

C_a_lxasm
                        add     C_IP , # 3
                        andn    C_IP , # 3
                        rdlong  C_treg2 , C_IP
                        
                        movd    __a_lxasm1 , C_treg2
                        mov     C_treg1 , C_treg2
                        add     C_treg1 , # 1
__a_lxasm1                        
                        cmp     C_treg2 , C_treg2 wz
              if_z      jmp     C_treg1                       
                        
                        movd    __a_lxasm2 , C_treg2
                        shr     C_treg2 , # 9
                        and     C_treg2 , # h1FF
                       
__a_lxasm2
                        rdlong  C_varEnd , C_IP
                        add     __a_lxasm2 , C_fDestInc
                        add     C_IP , # 4
                        djnz    C_treg2 , # __a_lxasm2

                        jmp     C_treg1
C_a__xasm2>flagIMM
                        rdword  C_treg1 , C_IP
                        add     C_IP , # 2
                        jmp		# __a__xasm2>flag1
C_a__xasm2>flag
                        jmpret		C_a_stpopC_treg_ret , # C_a_stpopC_treg
__a__xasm2>flag1
                        rdword  C_treg6 , C_IP
                        movi    __a__xasm2>flagi , C_treg6
                        add     C_IP , # 2
                        
                        andn    __a__xasm2>flagf1 , C_fCondMask
                        andn    __a__xasm2>flagf2 , C_fCondMask
                        shl     C_treg6 , # 6
                        and     C_treg6 , C_fCondMask  wz

                if_nz   or      __a__xasm2>flagf1 , C_treg6
                if_nz   xor     C_treg6 , C_fCondMask
                if_nz   or      __a__xasm2>flagf2 , C_treg6                     
__a__xasm2>flagi                        
                        and     C_stTOS , C_treg1
__a__xasm2>flagf1
                        mov     C_stTOS , C_fLongMask
__a__xasm2>flagf2
                        mov     C_stTOS , # 0     
                        jmp		# C_a_next


C_a__xasm2>1IMM
                        rdword  C_treg1 , C_IP
                        add     C_IP , # 2
                        jmp		# __a__xasm2>1s1
C_a__xasm2>1
                        jmpret	C_a_stpopC_treg_ret , # C_a_stpopC_treg
__a__xasm2>1s1
                        rdword  C_treg6 , C_IP
                        movi    __a__xasm2>1i , C_treg6
                        add     C_IP , # 2
__a__xasm2>1i                        
                        and     C_stTOS , C_treg1

                        jmp		# C_a_next

C_a__xasm1>1
                        rdword  C_treg1 , C_IP
                        movi    __a__xasm1>1i , C_treg1
                        add     C_IP , # 2
__a__xasm1>1i                        
                        abs     C_stTOS , C_stTOS
                        jmp		# C_a_next

C_a__xasm2>0
                        rdword  C_treg1 , C_IP
                        movi    __a__xasm2>0i , C_treg1
                        add     C_IP , # 2
                        jmpret	C_a_stpopC_treg_ret , # C_a_stpopC_treg
__a__xasm2>0i                        
                        abs     C_stTOS , C_treg1
C_a_drop
                        jmpret	C_a_stPop_ret , # C_a_stPop
                        jmp		# C_a_next
C_a_RSat
                        add     C_stTOS , C_rsPtr
                        add     C_stTOS , # 1
                        cmp     C_stTOS , # __rsTop-1           wc wz
              if_a      mov     C_treg6 , # 4
              if_a      jmp		# C_a_reset
                        jmp		# C_a_COGat
                        
C_a_STat
                        add     C_stTOS , C_stPtr
                        add     C_stTOS , # 1
                        cmp     C_stTOS , # __stTop-1         wc wz
              if_ae     mov     C_treg6 , # 3
              if_ae     jmp		# C_a_reset
                                               
C_a_COGat
                        movs    __a_COGatget , C_stTOS
\ necessary , really needs to be documented
                        nop
__a_COGatget
						mov     C_stTOS , C_stTOS
                        jmp # C_a_next

C_a_RS!
                        add     C_stTOS , C_rsPtr
                        add     C_stTOS , # 1
                        cmp     C_stTOS , # __rsTop-1           wc wz
              if_a      mov     C_treg6 , # 2
              if_a      jmp		# C_a_reset
                        jmp		# C_a_COG!
                                   
C_a_ST!
                        add     C_stTOS , C_stPtr
                        add     C_stTOS , # 2
                        cmp     C_stTOS , # __stTop-1         wc wz
              if_ae     mov     C_treg6 , # 2
              if_ae     jmp # C_a_reset
C_a_COG!
                        movd    __a_COG!put , C_stTOS
                        jmpret	C_a_stPop_ret , # C_a_stPop
__a_COG!put
						mov     C_stTOS , C_stTOS    
                        jmp		# C_a_drop
C_a_branch
\ the next word
                        rdword  C_treg1 , C_IP
\ add the offset
                        add     C_IP , C_treg1 
                        and     C_IP , C_fAddrMask
                        jmp		# C_a_next
C_a_doconw
                        jmpret	C_a_stPush_ret , # C_a_stPush
                        rdword  C_stTOS , C_IP
                        jmp		# C_a_exit
C_a_dovarl
                        add     C_IP , # 3
                        andn    C_IP , # 3
C_a_dovarw
                        jmpret	C_a_stPush_ret , # C_a_stPush
                        mov     C_stTOS , C_IP       
                        jmp		# C_a_exit
C_a_doconl                 
                        jmpret	C_a_stPush_ret , # C_a_stPush
                        add     C_IP , # 3
                        andn    C_IP , # 3
                        rdlong  C_stTOS , C_IP
                        jmp		# C_a_exit


C_a_litl               
                        jmpret	C_a_stPush_ret , # C_a_stPush
                        add     C_IP , # 3
                        andn    C_IP , # 3
                        rdlong  C_stTOS , C_IP
                        add     C_IP , # 4
                        jmp		# C_a_next
C_a_litw
                        jmpret	C_a_stPush_ret , # C_a_stPush       
                        rdword  C_stTOS , C_IP
C_a_litw1                        
                        add     C_IP , # 2
                        jmp		# C_a_next
C_a_exit
                        jmpret	C_a_rsPop_ret , # C_a_rsPop
                        mov     C_IP , C_treg5
\                        jmp # C_a_next        SINCE WE ARE ALREADY There
C_a_next                                                
                        rdword  C_treg1 , C_IP
                        testn   C_treg1 , # h1FF    wz
                        add     C_IP , # 2
        if_z            jmp     C_treg1
                        mov     C_treg5 , C_IP
                        mov     C_IP , C_treg1       
                        jmpret	C_a_rsPush_ret , # C_a_rsPush
                        jmp		# C_a_next
C_a__maskin
                        and     C_stTOS , ina      wz
                        muxnz   C_stTOS , C_fLongMask
                        jmp		# C_a_next

C_a__maskouthi
                        jmp		# __a__maskoutex            wz

C_a__maskoutlo
                        test    C_stTOS , # 0       wz
__a__maskoutex
                        muxnz   outa , C_stTOS
                        jmp		# C_a_drop
                                                
C_a_r>
                        jmpret	C_a_rsPop_ret , # C_a_rsPop
                        jmpret	C_a_stPush_ret , # C_a_stPush
                        mov     C_stTOS , C_treg5
                        jmp		# C_a_next
C_a_2>r
                        mov     C_treg5 , C_stTOS
                        jmpret	C_a_stPop_ret , # C_a_stPop
                        jmpret	C_a_rsPush_ret , # C_a_rsPush       
C_a_>r
                        mov     C_treg5 , C_stTOS
                        jmpret	C_a_stPop_ret , # C_a_stPop
                        jmpret	C_a_rsPush_ret , # C_a_rsPush
                        jmp		# C_a_next
C_a_(loop)
                        mov     C_treg1 , # 1
                        jmp		# __a_(+loop)1
C_a_(+loop)
                        jmpret	C_a_stpopC_treg_ret , # C_a_stpopC_treg        
__a_(+loop)1
                        jmpret	C_a_rsPop_ret , # C_a_rsPop
                        mov     C_treg2 , C_treg5
                        jmpret	C_a_rsPop_ret , # C_a_rsPop
                        add     C_treg5 , C_treg1
                        cmps    C_treg2 , C_treg5       wc wz
                if_a    jmpret	C_a_rsPush_ret , # C_a_rsPush
                if_a    mov     C_treg5 , C_treg2
                if_a    jmpret	C_a_rsPush_ret , # C_a_rsPush
                if_a    jmp		# C_a_branch
                        jmp		# C_a_litw1        

C_a_0branch
                        jmpret	C_a_stpopC_treg_ret , # C_a_stpopC_treg
                        cmp     C_treg1 , # 0       wz
                if_z    jmp		# C_a_branch 
                        jmp		# C_a_litw1

C_a_reset
                        mov     C_treg5 , par
\
\ must align with the lasterr definition in forth
\
\ the last error offset is patched by the build process
\
C_a_lasterr
                        add     C_treg5 , # hCC 
                        wrword  C_treg6 , C_treg5  
                        coginit C_resetDreg
                        
                        

\ C_a_stPush - push C_stTOS on to stack

C_a_stPush
                        movd    C_a_stPush1 , C_stPtr    
                        cmp     C_stPtr , # C_stBot           wc
              if_b      mov     C_treg6 , # 1
              if_b      jmp		# C_a_reset
C_a_stPush1
						mov     C_stPtr , C_stTOS               
                        sub     C_stPtr , # 1
C_a_stPush_ret                        
                        ret                                  

\ C_a_rsPush - push C_treg5 on to return stack

C_a_rsPush
                        movd    C_a_rsPush1 , C_rsPtr    
                        cmp     C_rsPtr , # C_rsBot           wc
              if_b      mov     C_treg6 , # 2
              if_b      jmp		# C_a_reset
C_a_rsPush1
						mov     C_treg1 , C_treg5              
                        sub     C_rsPtr , # 1
C_a_rsPush_ret                        
                        ret



\ C_a_stpopC_treg - move C_stTOS to C_treg1 , and pop C_stTOS from stack


C_a_stpopC_treg                                                    
                        mov     C_treg1 , C_stTOS    


\ C_a_stPop - pop C_stTOS from stack


C_a_stPop
                        add     C_stPtr , # 1       
                        movs    C_a_stPop1 , C_stPtr    
                        cmp     C_stPtr , # C_stTop           wc wz
              if_ae     mov     C_treg6 , # 3
              if_ae     jmp	# C_a_reset
C_a_stPop1
						mov     C_stTOS , C_stPtr
C_a_stPop_ret
C_a_stpopC_treg_ret
                        ret                       
                               


\ C_a_rsPop - pop C_treg5 from return stack


C_a_rsPop
                        add     C_rsPtr , # 1
                        movs    C_a_rsPop1 , C_rsPtr    
                        cmp     C_rsPtr , # C_rsTop           wc wz
              if_ae     mov     C_treg6 , # 4
              if_ae     jmp		# C_a_reset
C_a_rsPop1
                        mov     C_treg5 , C_treg1
C_a_rsPop_ret                        
                        ret

'
' variables used by the forth interpreter
'
                        
C_fDestInc
						h00000200
C_fCondMask
						h003C0000
C_fAddrMask
						h7FFF
C_fLongMask
						hFFFFFFFF
C_resetDreg
						0
\ C_IP
\						0
C_stPtr
						long __stTop-1
C_rsPtr
						long __rsTop-1
C_stTOS
						0



\ These variables can be overlapped with the cog data area variables to save space
\ not useful any more??

C_cogdata

\ C_treg1
\ 						0
\ C_treg2
\						0
C_treg3
						0
C_treg4
						0
C_treg5
						0
C_treg6
						0						
C_stBot
						0
						0
						0
						0

						0
						0
						0
						0

						0
						0
						0
						0

						0
						0
						0
						0

						0
						0
						0
						0

						0
						0
						0
C_this
__stTop-1
						0

\                        long    0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
\                        long    0 , 0 , 0 , 0 , 0 , 0 , 0
\ C_this
\                        long    0
                        
                        
C_stTop
C_rsBot
\                        long    0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
\                        long    0 , 0 , 0 , 0 , 0 , 0
						0
						0
						0
						0

						0
						0
						0
						0

						0
						0
						0
						0

						0
						0
						0
						0

						0
						0
						0
						0

						0
__rsTop-1
						0

C_rsTop


C_varEnd  



;asm _fi


