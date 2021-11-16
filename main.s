	#include <xc.inc>

    
    
psect   code, abs
      
main:
	org 0x0
	goto	setup
	
	org 0x100

setup: 
	
    
    
 
	banksel	PADCFG1	; enter bank with PADCFG1
	bsf	REPU 	; point to Flash program memory with bit 1
	banksel	0	; come back out to access bank
	
	clrf	LATE
	
	
	
	movlw	0xFF
	movwf	0x02 ; for delay
	call	delay
	
	
	
start:
	nop

loop:
	movlw	00001111B; binary instead	;output=0 input=1
	movwf	TRISE, A
	
	movff	PORTE, 0x06, A	; read all bits of PORTE
				; keypad -> PORTE  ; 0-3 rows  ; 4-7 columns
	
	movlw	11110000B  ; binary instead	;output=0 input=1
	movwf	TRISE, A    
	
	movff	PORTE, 0x07, A
	
	movf	0x06, W, A
	addwfc	0x07, 0x08, A
		
	bra	loop
	
    
delay: 

	decfsz	0x02, A 	; decrement until zero
	bra	delay
	return
	
	end	main
