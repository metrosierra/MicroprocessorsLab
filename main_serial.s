	#include <xc.inc>
	
	
	; program reads user defined data within the program memory
	; and displays contents byte by byte via LEDs on PORTC
	; PORTD will allow us to control led update speed and start/stop
	
	
psect	code, abs
main:
	org 0x0
	goto	setup
	
	org 0x100		    ; Main code starts here at address 0x100

	; ******* Programme FLASH read Setup Code ****  
setup:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	
     	movlw	0xFF
	movwf	TRISC, A	    ; Port C input for speed
 
	
	call	 SPI_MasterInit
	
	movlw	0x0
	
	goto	start
	; ******* My data and where to put it in RAM *
	
myData:
	db	0x01, 0x02, 0x04, 0x08, 0x16, 0x32, 0x64
	myArray EQU 0x400 ;RAM add
	counter EQU 0x02  
	align	2	; ensure alignment of subsequent instructions


	; ******* Main programme *********************
start:	
	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myData)	; address of data in PM
 	movwf	TBLPTRU, A	; load upper bits to TBLPTRU
	movlw	high(myData)	; address of data in PM
	movwf	TBLPTRH, A	; load high byte to TBLPTRH
	movlw	low(myData)	; address of data in PM
	movwf	TBLPTRL, A	; load low byte to TBLPTRL
	; above reads myData
	
	movlw	8		; 4 bytes to read
	movwf 	counter, A	; our counter register
	

loop:
        tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0	; move read data from TABLAT to (FSR0), increment FSR0	
	
	movf	TABLAT, W, A
	call	SPI_MasterTransmit	; output to PORTD

	; for delay
	movf	PORTC, W, A
	movwf	0x06, A
	call delay
	
	decfsz	counter, A	; count counter down to zero
	bra	loop		; keep going until finished ; branch unconditionally
	goto	0x0

	
	
SPI_MasterInit:	; Set Clock edge to negative
	bcf CKE2	; CKE bit in SSP2STAT,
	; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)
	movlw 	(SSP2CON1_SSPEN_MASK)|(SSP2CON1_CKP_MASK)|(SSP2CON1_SSPM1_MASK)
	movwf 	SSP2CON1, A
	; SDO2 output; SCK2 output
	bcf	TRISD, PORTD_SDO2_POSN, A	; SDO2 output
	bcf	TRISD, PORTD_SCK2_POSN, A	; SCK2 output
	return 	
	
	
SPI_MasterTransmit:  ; Start transmission of data (held in W)
	movwf 	SSP2BUF, A 	; write data to output buffer
	
Wait_Transmit:	; Wait for transmission to complete 
	btfss 	SSP2IF		; check interrupt flag to see if data has been sent
	bra 	Wait_Transmit
	bcf 	SSP2IF		; clear interrupt flag
	return 	
	
delay:
	; for subdelay
	movlw	0xFF
	movwf	0x07, A
	call	subdelay
	
	decfsz	0x06,A	
	bra	delay
	return	0

subdelay:
	movlw	0xFF
	movwf	0x08, A
	call	subdelay2
	
    
	decfsz	0x07, A
	bra	subdelay
	return	0
	
subdelay2:
	decfsz	0x08, A
	bra	subdelay2
	return	0
	
	
	
	
	end	main

