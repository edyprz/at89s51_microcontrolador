decc		equ	7DH
uni		equ	7CH
cen_		equ	7BH
temp		equ	7AH
acall 	ini_LCD
;-------------------------------------------------------
;PROGRAMA PRINCIPAL
;-------------------------------------------------------
INICIO:	acall 	mensaje
inicio_:	setb   	TXD
		mov 		A,P2
		mov 		temp,A
		acall 	CHD8B
		acall 	imptemp
		clr		TXD
		sjmp 		inicio_
;---------------------------------------------------
;CONVERTIDO DE 16 BITS DE HEXDECIMAL A DECIMAL 
;---------------------------------------------------
CHD8B:			
		mov 	B,#100
		div 	AB
		mov 	cen_,A
		mov 	A,B
		mov 	B,#10
		div 	AB
		mov 	decc,A
		mov 	uni,B
		ret
;-------------------------------------------------------------------
;RUTINA QUE MANDA A IMRIMIR EL VALOR DE LA TEMPERATURA ALA LCD 
;-------------------------------------------------------------------
imptemp:	mov 	A,#0C2H
		acall C_LCD

		mov 	A,cen_
		orl 	A,#00110000B
		acall D_LCD
		mov 	A,decc
		orl 	A,#00110000B
		acall D_LCD
		mov 	A,uni
		orl 	A,#00110000B
		acall D_LCD
		mov 	A,#0DFH
		acall D_LCD
		mov 	A,#'C'
		acall D_LCD
		ret
;--------------------------------------------------------------
;RUTINA QUE INILISA LA LCD 
;--------------------------------------------------------------
ini_LCD:	mov 	A,#38H
		acall C_LCD
		mov 	A,#01H
		acall C_LCD
		mov 	A,#0CH
		acall C_LCD
		mov 	A,#80H
		acall C_LCD
		ret
;---------------------------------------------------------------
; Rutinas para enviar un comando y/o dato al DISPLAY LCD
;---------------------------------------------------------------
C_LCD:
	clr 	WR ;envia comando
	sjmp 	L00

D_LCD:
	setb 	WR ;envia dato en ascii
L00:
	mov 	P1,A
	djnz 	R7,$
	djnz 	R7,$
	clr 	RD ;habilita la pantalla
	djnz 	R7,$
	djnz 	R7,$
	setb 	RD  ;deshabilita la pantalla
	ret
;-----------------------------------------------------------------
;RUTINA QUE ENVIA UN MENSAJE POR LA LCD	
;-----------------------------------------------------------------
	
mensaje:
	MOV 	A,#80H
	ACALL C_LCD
	mov 	DPTR,#TEMP_
	ACALL MSJ
	ret
MSJ:	
	CLR 	A
	MOVC 	A,@A+DPTR
	JZ 	FIN
	ACALL D_LCD
	mov 	sbuf,A
	jnb 	TI,$
	clr 	TI
	INC 	DPTR
	SJMP 	MSJ
	
FIN:
	RET	
TEMP_:		
	DB 'TEMPERATURA:',0
		
		