#include <xc.inc>

global  ADC_Setup, ADC_Read

psect	udata_acs   ; reserve data space in access ram
ARG1H:	ds  1    ; kH 
ARG1L:	ds  1	 ; kL
	
ARG2H:	ds  1	 ; voltage H
ARG2L:	ds  1	 ; voltage L

RES3:	ds  1	; final output 3
RES2:	ds  1	; final output 2
RES1:	ds  1	; final output 1
RES0:	ds  1	; final output 0
    
OUT3:	ds  1	; decimal in hex output 3
OUT2:	ds  1	; decimal in hex output 2
OUT1:	ds  1	; decimal in hex output 1
OUT0:	ds  1	; decimal in hex output 0

psect	adc_code, class=CODE
    
ADC_Setup:
	bsf	TRISA, PORTA_RA0_POSN, A  ; pin RA0==AN0 input
	movlb	0x0f
	bsf	ANSEL0	    ; set AN0 to analog
	movlb	0x00
	movlw   0x01	    ; select AN0 for measurement
	movwf   ADCON0, A   ; and turn ADC on
	movlw   0x30	    ; Select 4.096V positive reference
	movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
	movlw   0xF6	    ; Right justified output
	movwf   ADCON2, A   ; Fosc/64 clock and acquisition times
	return

ADC_Read:
	bsf	GO	    ; Start conversion by setting GO bit in ADCON0
adc_loop:
	btfsc   GO	    ; check to see if finished
	bra	adc_loop
	call	HexDec_Convert_Rough
	return

; using initial k kernel = decimal 66
HexDec_Convert_Rough:
	; k lower
	movlw	0x42
	movwf	ARG1L, A
	; k higher
	movlw	0x00
	movwf	ARG1H, A
	
	; voltage lower
	movf	ADRESL, W, A
	movwf	ARG2L, A
	; voltage higher
	movf	ADRESH, W, A
	movwf	ARG2H, A
	
	call	MUL16x16
	movff	RES2, OUT3, A
	clrf	RES2, A
	
	; decimal 10 lower
	movlw	0x0A
	movwf	ARG1L, A
	; decimal 10 higher, leave arg1 as is
	movlw	0x00
	movwf	ARG1H, A
	; residue lower
	movf	RES0, W, A
	movwf	ARG2L, A
	; residue higher
	movf	RES1, W, A
	movwf	ARG2H, A
	call	MUL16x16
	movff	RES2, OUT2, A
	clrf	RES2, A
	; residue lower
	movf	RES0, W, A
	movwf	ARG2L, A
	
	; residue higher
	movf	RES1, W, A
	movwf	ARG2H, A
	call	MUL16x16
	movff	RES2, OUT1, A
	clrf	RES2, A
	; residue lower
	movf	RES0, W, A
	movwf	ARG2L, A
	
	; residue higher
	movf	RES1, W, A
	movwf	ARG2H, A
	
	call	MUL16x16
	movff	RES2, OUT0, A
	clrf	RES2, A
	
	rlncf	OUT3, A
	rlncf	OUT3, A
	rlncf	OUT3, A
	rlncf	OUT3, W, A
	addwf	OUT2, W, A
	movwf	ADRESH, A
	
	rlncf	OUT1, A
	rlncf	OUT1, A
	rlncf	OUT1, A
	rlncf	OUT1, W, A
	addwf	OUT0, W, A
	movwf	ADRESL, A	
	
	return
   
; higher initial k value = 16778
HexDec_Convert_Precise:
	; k lower
	movlw	0x8A
	movwf	ARG1L, A
	; k higher
	movlw	0x41
	movwf	ARG1H, A
	
	; voltage lower
	movf	ADRESL, W, A
	movwf	ARG2L, A
	; voltage higher
	movf	ADRESH, W, A
	movwf	ARG2H, A
	
	call	MUL16x16
	movff	RES3, OUT3, A
	clrf	RES3, A
	
	; decimal 10 lower
	movlw	0x0A
	movwf	ARG1L, A
	
	; RES2, RES1, RES0 -> ARG1H, ARG2H, ARG2L
	
	; residue RES2 -> ARG1H
	movf	RES2, W, A
	movwf	ARG1H, A
	; residue RES1 -> ARG2H
	movf	RES1, W, A
	movwf	ARG2H, A
	; residue RES0 -> ARG2L
	movf	RES0,W, A
	movwf	ARG2L, A
	
	call	MUL8x24
	
	; residue higher
	movf	RES1, W, A
	movwf	ARG2H, A
	call	MUL16x16
	movff	RES2, OUT1, A
	clrf	RES2, A
	; residue lower
	movf	RES0, W, A
	movwf	ARG2L, A
	
	; residue higher
	movf	RES1, W, A
	movwf	ARG2H, A
	
	call	MUL16x16
	movff	RES2, OUT0, A
	clrf	RES2, A
	
	rlncf	OUT3, A
	rlncf	OUT3, A
	rlncf	OUT3, A
	rlncf	OUT3, W, A
	addwf	OUT2, W, A
	movwf	ADRESH, A
	
	rlncf	OUT1, A
	rlncf	OUT1, A
	rlncf	OUT1, A
	rlncf	OUT1, W, A
	addwf	OUT0, W, A
	movwf	ADRESL, A	
	
	return
    
MUL16x16:
	; multiplication
	
	MOVF	ARG1L, W
	MULWF	ARG2L	; ARG1L * ARG2L->
			; PRODH:PRODL
	MOVFF	PRODH, RES1 ;
	MOVFF	PRODL, RES0 ;
    ;
	MOVF	ARG1H, W
	MULWF	 ARG2H ; ARG1H * ARG2H->
		    ; PRODH:PRODL
	MOVFF	PRODH, RES3 ;
	MOVFF	PRODL, RES2 ;
    ;
	MOVF	ARG1L, W
	MULWF	ARG2H ; ARG1L * ARG2H->
		    ; PRODH:PRODL
	MOVF	PRODL, W ;
	ADDWF	RES1, F ; Add cross
	MOVF	PRODH, W ; products
	ADDWFC	RES2, F ;
	CLRF	WREG ;
	ADDWFC	RES3, F ;
    ;
	MOVF	ARG1H, W ;
	MULWF	ARG2L ; ARG1H * ARG2L->
		    ; PRODH:PRODL
	MOVF	PRODL, W ;
	ADDWF	RES1, F ; Add cross
	MOVF	PRODH, W ; products
	ADDWFC	RES2, F ;
	CLRF	WREG ;
	ADDWFC	RES3, F ;
	
	return 


	
MUL8x24:
	; ARG1L = 8bit number 
	; ARG1H, ARG2H, ARG2L => 24bit number (highest, high, low)
	; We have RES3, RES2, RES1, RES0 to play with 
	; multiplication
	CLRF	RES3
	CLRF	RES2
	CLRF	RES1
	CLRF	RES0
	BCF	3, 0
	
	MOVF	ARG1L, W, A
	MULWF	ARG2L	; ARG1L * ARG2L->
			; PRODH:PRODL
	MOVFF	PRODH, RES1 ;
	MOVFF	PRODL, RES0 ;
	
	MOVF	ARG1L, W, A
	MULWF	ARG2H ; ARG1L * ARG1H->
;		    ; PRODH:PRODL
;	
	MOVF	PRODL, W, A
	ADDWF	RES1, A
	BTFSC	3, 0
	INCF	RES2, A
	
	MOVF	PRODH, W, A
	ADDWF	RES2, A
	
	MOVF	ARG1L, W, A
	MULWF	ARG1H
	MOVF	PRODL, W, A
	ADDWF	RES2, A
	BTFSC	3, 0
	INCF	RES3, A
	MOVF	PRODH, W, A
	ADDWF	RES3, A
	
	return 
end