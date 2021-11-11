	#include <xc.inc>
	
	
	; program reads user defined data within the program memory
	; PORTC input for update speed control
	; PORTD outpur for serial data output 
	
	
psect	code, abs
main:
	org 0x0
	goto	setup
	
	org 0x100		    ; Main code starts here at address 0x100

	; ******* Programme FLASH read Setup Code ****  
setup:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	
	call	 SPI_MasterInit
	
	movlw	0x0
	
	goto	start

	
	
	
SPI_MasterInit:	; Set Clock edge to negative
	bcf CKE2	; CKE bit in SSP2STAT,
	; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)
	movlw 	(SSP2CON1_SSPEN_MASK)|(SSP2CON1_CKP_MASK)|(SSP2CON1_SSPM1_MASK)
	movwf 	SSP2CON1, A
	; SDO2 output; SCK2 output
	bcf	TRISD, PORTD_SDO2_POSN, A	; SDO2 output ; for data
	bcf	TRISD, PORTD_SCK2_POSN, A	; SCK2 output ; for clock
	return 	
	
	
SPI_MasterTransmit:  ; Start transmission of data (held in W)
	movwf 	SSP2BUF, A 	; write data to output buffer
	
Wait_Transmit:	; Wait for transmission to complete 
	btfss 	SSP2IF		; check interrupt flag to see if data has been sent
	bra 	Wait_Transmit
	bcf 	SSP2IF		; clear interrupt flag
	return 	
	
	
	
	
start:		
	movlw	0x04
	call	SPI_MasterTransmit	; output to PORTD

	end	main

