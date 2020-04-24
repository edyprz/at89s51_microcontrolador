;****************************************************************
;            TERMOMETRO 0° - 150°
;**************************************************************** 


;Declaracion de variables

LCD		EQU P1
RS		EQU P3.7
EN		EQU P3.6
WRT         EQU P3.1

DECENAS	equ	7DH
UNIDADES	equ	7CH
CENTENAS	equ	7BH
TEMPERATURA	equ	7AH


;----MOSTRAR MENSAJE------

		acall 	INICIALIZA_LCD


INICIO:	
		acall TEMPER1

;-----INICIO DE PROGRAMA-----

EDOINI:	
		setb    WRT
		mov 	A,P2
		mov 	TEMPERATURA,A
		acall 	CONVERTE_HD
		acall 	IMPRIME
		clr	WRT
		sjmp 	EDOINI

INICIALIZA_LCD:	
		mov 	A,#38H    ;Funcion SET
		acall 	CMD_LCD
		mov 	A,#01H    ;Clear LCD
		acall 	CMD_LCD
		mov 	A,#0CH
		acall 	CMD_LCD
		mov 	A,#80H
		acall 	CMD_LCD
		ret
		

;-----Convertir de Hexadecimal a decimal-----

CONVERTE_HD:			
		mov 	B,#100
		div 	AB
		mov 	CENTENAS,A
		mov 	A,B
		mov 	B,#10
		div 	AB
		mov 	DECENAS,A
		mov 	UNIDADES,B
		ret
	


;-------------------------------------------------------------------



IMPRIME:		
		mov 	A,#0C2H
		acall 	CMD_LCD

		mov 	A,CENTENAS
		orl 	A,#00110000B
		acall 	ESCRIBE
		mov 	A,DECENAS
		orl 	A,#00110000B
		acall 	ESCRIBE
		mov 	A,UNIDADES
		orl 	A,#00110000B
		acall 	ESCRIBE
		mov 	A,#0DFH
		acall 	ESCRIBE
		mov 	A,#'C'
		acall 	ESCRIBE
		ret		


CMD_LCD:
	clr 	RS  	;envia comando
	sjmp 	ENABLE 

ESCRIBE:
	SETB RS    ;Envia dato en ASCII

ENABLE:
	MOV LCD,A
	DJNZ R7,$
	DJNZ R7,$
	CLR  EN     ;Habilita la pantalla
	DJNZ R7,$
	DJNZ R7,$
	SETB EN
	RET        ;Deshabilita la pantalla

TEMPER1:

	MOV 	A,#80H
	ACALL 	CMD_LCD
	mov 	DPTR,#TEMPER2
	ACALL 	MSJ               ;Llama la rutina de mensaje
	ret

MSJ:	
	CLR 	A
	MOVC 	A,@A+DPTR
	JZ 	FIN
	ACALL 	ESCRIBE
	mov 	sbuf,A
	jnb 	TI,$
	clr 	TI
	INC 	DPTR
	SJMP 	MSJ	
FIN:
	RET
	
TEMPER2: DB 'TEMPERATURA:',0 