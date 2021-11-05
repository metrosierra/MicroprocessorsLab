	#include <xc.inc>

psect	code, abs
	
main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100
start:
	movlw 	0x0
	movwf	TRISC, A	    ; Port C all outputs
	movlw	0xFF
	movwf	TRISD, A
	movlw	0x0
    	bra 	test
loop:
	movff 	0x06, PORTC	    ; 2c
	incf 	0x06, W, A	    ; 1c
test:
	movwf	0x06, A		    ; 1c, Test for end of loop condition
	movf	PORTD, W, A	    ; 1c
	cpfsgt 	0x06, A		    ; 1c
	bra 	loop		    ; 2c, Not yet finished goto start of loop again
				    ; 8c total, 4x8 = 32 clock cycles, 5e-7s for 1 loop, hi
	goto 	0x0		    ; Re-run program from start

	end	main
