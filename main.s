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
	
     	movlw	0x0
	movwf	TRISC, A	    ; Port C all outputs
	
	movlw	0xFF
	movwf	TRISD, A	    
	movlw	0x0
	

	goto	start
	; ******* My data and where to put it in RAM *
	

	
myData:
	db	0x01, 0x02, 0x04, 0x08
;	db	'h', 'e', 'y'
	myArray EQU 0x400 ;RAM add
	counter EQU 0x02  
	align	2	;align???


;myTable:
;	db	'T','h','i','s',' ','i','s',' ','v','e','r','y'
;	db	' ','p','a','i','n',' ','t','o','d','o'
;	myArray EQU 0x400	; Address in RAM for data
;	counter EQU 0x10	; Address of counter variable
;	align	2		; ensure alignment of subsequent instructions ????
	
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
	
	movlw	4		; 4 bytes to read
	movwf 	counter, A	; our counter register
loop:
        tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0	; move read data from TABLAT to (FSR0), increment FSR0	
	decfsz	counter, A	; count counter down to zero
	bra	loop		; keep going until finished ; branch unconditionally
	
	goto	0

	end	main
