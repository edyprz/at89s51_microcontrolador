LCD		EQU P0
RS		EQU P2.7
EN		EQU P2.6
UNIDADES	EQU 7FH
DECENAS	EQU 7EH	
CENTENAS	EQU 7DH
MILLARES	EQU 7CH
TEC		EQU 7BH
TIEMPO	EQU 7AH
SENTIDO	EQU 79H

	ORG 0H
	SJMP INICIO
;=============================================================
	ORG 23H
	CLR EA	;DESHABILITA LAS INTERRUPCIONES
	PUSH ACC
	JNB RI,$
	CLR RI
	MOV A,SBUF
	MOV TEC,A
	ACALL REVISAT
	SETB EA		;HABILITA LAS INTERRUPCIONES
	POP ACC
	RETI

REVISAT:
	MOV A,TEC
	CJNE A,#'1',TI1
	MOV TIEMPO,#1
	RET

TI1:	CJNE A,#'2',TI2
	MOV TIEMPO,#64
	RET

TI2:	CJNE A,#'3',TI3
	MOV TIEMPO,#128
	RET

TI3:	CJNE A,#'4',TI4
	MOV TIEMPO,#255
	RET

TI4:
	CJNE A,#'D',FIN
	MOV SENTIDO,#'D'
	RET
FIN:
	MOV SENTIDO,#'A'
	RET
;===========================================================

INICIO:	

	MOV	TIEMPO,#255
	MOV 	SENTIDO,#'A'
	ACALL INICIALIZA_LCD
	ACALL INI_UART
	ACALL BIENVENIDA
	ACALL NLINEA
INI:	ACALL INI1

IM:	ACALL IMPRIMEVALS
	ACALL RETARDO_1S

REVISA_S:
	MOV A,SENTIDO
	CJNE A,#'A',DESCIENDE
	ACALL ASCIENDE

	SJMP IM





BIENVENIDA:
		ACALL NLINEA
		MOV DPTR,#MSJA
		ACALL M
		ACALL NLINEA
		MOV DPTR,#MSJB
		ACALL M
		ACALL NLINEA
		MOV DPTR,#MSJC
		ACALL M
		ACALL NLINEA
		MOV DPTR,#MSJD
		ACALL M
		ACALL NLINEA

		RET

M:
		CLR EA	
B1:		CLR A	
		MOVC A,@A+DPTR
		JZ FINM
		ACALL ENVIA
		INC DPTR
		SJMP B1

FINM:	
		SETB EA
		RET

NLINEA:
		CLR EA
		MOV A,#0AH
		ACALL ENVIA
		MOV A,#0DH
		ACALL ENVIA
		SETB EA
		RET


;===============================================================
;======CUENTA ASCENDENTE========================================
ASCIENDE:

	ACALL ADDUNI
	RET

ADDUNI:	
	MOV A,UNIDADES
	INC A
	CJNE A,#':',FUNI
	MOV UNIDADES,#'0'
	ACALL ADDDECE
	RET

FUNI:
	MOV UNIDADES,A
	RET

ADDDECE:
	MOV A,DECENAS
	INC A
	CJNE A,#':',FDEC
	MOV DECENAS,#'0'
	ACALL ADDCENTE
	RET

FDEC:
	MOV DECENAS,A
	RET	


ADDCENTE:
	MOV A,CENTENAS
	INC A
	CJNE A,#':',FCEN
	MOV CENTENAS,#'0'
	ACALL ADDMILLAR
	RET

FCEN:
	MOV CENTENAS,A
	RET	



ADDMILLAR:
	MOV A,MILLARES
	INC A
	CJNE A,#':',FMILL
	ACALL INI1
	RET

FMILL:
	MOV MILLARES,A
	RET	
;===============================================================
;======CUENTA DESCENDENTE========================================


DESCIENDE:
	ACALL SUBBUNI
	LJMP IM

SUBBUNI:	
	MOV A,UNIDADES
	DEC A
	CJNE A,#'/',FUNI
	MOV UNIDADES,#'9'
	ACALL SUBBDECE
	RET


SUBBDECE:
	MOV A,DECENAS
	DEC A
	CJNE A,#'/',FDEC
	MOV DECENAS,#'9'
	ACALL SUBBCENTE
	RET


SUBBCENTE:
	MOV A,CENTENAS
	DEC A
	CJNE A,#'/',FCEN
	MOV CENTENAS,#'9'
	ACALL SUBBMILLAR
	RET


SUBBMILLAR:
	MOV A,MILLARES
	DEC A
	CJNE A,#'/',FMILL
	ACALL INI2
	RET
	
INI2:
	MOV MILLARES,#'9'
	MOV CENTENAS,#'9'
	MOV DECENAS,#'9'
	MOV UNIDADES,#'9'
	RET	
	

;====================================================


INI1:
	MOV MILLARES,#'0'
	MOV CENTENAS,#'0'
	MOV DECENAS,#'0'
	MOV UNIDADES,#'0'
	RET

IMPRIMEVALS:
	CLR EA

	MOV A,#0DH
	ACALL ENVIA

	MOV A,#0C4H
	ACALL CMD_LCD
	MOV A,MILLARES
	ACALL ESCRIBE
	ACALL ENVIA
	MOV A,CENTENAS
	ACALL ESCRIBE
	ACALL ENVIA

	MOV A,DECENAS
	ACALL ESCRIBE
	ACALL ENVIA

	MOV A,UNIDADES
	ACALL ESCRIBE
	ACALL ENVIA
	SETB EA
	RET
	
ENVIA:
	MOV SBUF,A
	JNB TI,$
	CLR TI
	RET

INICIALIZA_LCD:	
		MOV A,#38h	;FUNCTION SET
		ACALL CMD_LCD
		MOV A,#01h	; CLEAR LCD
		ACALL CMD_LCD
		MOV A,#0CH	
		ACALL CMD_LCD
		MOV A,#80H	
		ACALL CMD_LCD
		RET 


CMD_LCD:
	CLR RS
	SJMP ENABLE

ESCRIBE:
	SETB RS
	;MOV A,AUX
ENABLE:
	MOV LCD,A
	DJNZ R7,$
	DJNZ R7,$
	CLR EN
	DJNZ R7,$
	DJNZ R7,$
	SETB EN
	RET


RETARDO_1S: MOV R6,TIEMPO
RETARDO:	DJNZ R7, $
		DJNZ R6, RETARDO
		RET
		
RETARDITO: 
RET1:		DJNZ R7, $
		DJNZ R6, RETARDO
		RET
		

;**********************************
; Rutina de configuracion de la UART
;---------------------------------------------


INI_UART:
	mov SCON,#50H ;transmisión en modo 1, habilita recepción serial
	mov TMOD,#20H ;timer 1 en modo 2 autorrecargable
	mov TH1,#0FDH ;baud_rate a 9600 @ 11.0592 MHz
	mov TL1,#0FDH
	setb TR1 ;inicia el baud_rate
	mov 	IE,#90H
	ret
;---------------------------------------------
MSJA:	DB 'BIENVENIDO, PRESIONE: ',0
MSJB:	DB 'VELOCIDAD: 1(MAS RAPIDO) - 4(MAS LENTO):',0
MSJC:	DB 'A: CUENTA ASCENDENTE ',0
MSJD:	DB 'D: CUENTA DESCENDENTE',0
