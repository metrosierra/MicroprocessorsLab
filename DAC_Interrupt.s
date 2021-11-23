#include <xc.inc>
	
global	DAC_Setup, DAC_Int_Hi
    
psect	dac_code, class=CODE
	
DAC_Int_Hi:	
	btfss	TMR0IF		; check that this is timer0 interrupt
	retfie	f		; if not then return
	incf	LATJ, F, A	; increment PORTJ
	
	movlw	0x00
	movwf	PORTD, A
        nop
	nop
	bcf	TMR0IF		; clear interrupt flag
	movlw	0x01
	movwf	PORTD, A


	retfie	f		; fast return from interrupt

DAC_Setup:
	clrf	TRISJ, A	; Set PORTJ as all outputs
	clrf	LATJ, A		; Clear PORTJ outputs
	movlw	10000000B	; Set timer0 to 16-bit, Fosc/4/256
	movwf	T0CON, A	; = 62.5KHz clock rate, approx 1sec rollover
	bsf	TMR0IE		; Enable timer0 interrupt
	bsf	GIE		; Enable all interrupts
	return
	
	end

