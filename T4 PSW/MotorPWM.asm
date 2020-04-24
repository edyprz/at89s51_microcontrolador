;*********************************************
; Control de velociades de motor. PMW
;*********************************************


;definición de variables y constantes
TECLADOM	EQU P2
TEC_ANT		EQU 10H

PWM_DUTY 	equ 7FH     	;CICLO DE TRABAJO
PWM_TMP1 	equ 7EH
PWM_TMP2 	equ 7DH
PWM_OUT 	equ P3.2        ;señal pwm
PWM_OUT1 	equ P3.3        ;señal pwm
REST		EQU 76H

AUX		EQU 7DH
CENTENAS    	EQU 7CH
DECENAS     	EQU 7BH
UNIDADES    	EQU 7AH
ACEN 		EQU 79H
ADEC	     	EQU 78H
AUNI		EQU 77H
LCD		EQU P1
EN		EQU P3.0
RS		EQU P3.1
;**************************************

  org 0
	SJMP INICIO

;-------------------------------------------------------   
; ------- PWM Service interruption -------
;-------------------------------------------------------

Org 0BH                      ;vector de interrupción del Timer0
	push 	Acc 
	MOV 	A,PWM_DUTY
	JZ 	APAGADO
	MOV 	A,AUX
	CJNE 	A,#'D',DERECHA
	SJMP 	IZQUIERDA

DERECHA:
	djnz 	PWM_TMP1,PWM_CHK
	mov 	PWM_TMP1,#200
	clr 	PWM_OUT
	SETB 	PWM_OUT1

	pop Acc
	reti

PWM_CHK: 
	xch 	A,PWM_TMP1
	cjne 	A,PWM_DUTY,PWM_fin
	setb 	PWM_OUT
	SETB 	PWM_OUT1

	SJMP 	PWM_fin



IZQUIERDA:
	djnz 	PWM_TMP1,PWM_CHK1
	mov 	PWM_TMP1,#200
	clr 	PWM_OUT1
	SETB 	PWM_OUT
	pop 	Acc
	reti

PWM_CHK1: 
	xch 	A,PWM_TMP1
	cjne 	A,PWM_DUTY,PWM_fin
	setb 	PWM_OUT1
	SETB 	PWM_OUT


PWM_fin:
	xch 	A,PWM_TMP1
	pop Acc
	reti

APAGADO:
	SETB PWM_OUT
	SETB PWM_OUT1
	RETI
;*************************************
; ------- Inicio de programa principal -------
;-------------------------------------------------------

INICIO: 
		ACALL COND_INI
		ACALL EDOINI		;ESTADO INICIAL DE 000
		ACALL INICIALIZA_LCD
EDOINI_:	
		ACALL MSJ_INICIO	;MENSAJE DE INTRODUZCA PORCENTAJE
		ACALL MSJ_PORCENTAJE	;000
		ACALL RETARDO
		ACALL CENTE		;INGRESA CENTENAS
		ACALL DECE
		ACALL UNID
		ACALL RETARDO
		ACALL SENTIDO
		ACALL CONVERSION	;LOS VALORES ASCII SE CONVIERTEN A DECIMAL Y SE SUMAN PARA DAR EL PORCENTAJE DE TRABAJO
		ACALL RETARDO	
		SJMP  EDOINI_
EDOINI:	
		MOV UNIDADES,#'0'
		MOV DECENAS,#'0'
		MOV CENTENAS,#'0'
		RET
	
SENTIDO:
		ACALL OBT1DIG
		MOV A,TEC_ANT
		MOV AUX,A
		RET
	
RETARDO: 
	djnz R7,$
	djnz R6,RETARDO
	ret
;==================================================

UNID:
	ACALL 	RETARDO
	ACALL 	OBT1DIG
	MOV 	A,TEC_ANT
	MOV 	UNIDADES,A
	MOV 	AUNI,A
	ACALL 	MSJ_PORCENTAJE
	ACALL 	RETARDO
	RET

DECE:
	ACALL 	RETARDO
	ACALL 	OBT1DIG
	MOV 	A,TEC_ANT
	MOV 	DECENAS,A
	MOV 	ADEC,A
	ACALL 	MSJ_PORCENTAJE
	ACALL 	RETARDO
	RET

CENTE:
	ACALL 	RETARDO
	ACALL 	OBT1DIG
	MOV 	A,TEC_ANT
	MOV 	CENTENAS,A
	MOV 	ACEN,A
	ACALL 	MSJ_PORCENTAJE
	ACALL 	RETARDO
	RET


CONVERSION:
	MOV 	A,AUNI
	ANL 	A,#0FH
	MOV 	AUNI,A
	MOV 	A,ADEC
	ANL 	A,#0FH
	MOV 	ADEC,A
	MOV 	A,ACEN
	ANL 	A,#0FH
	MOV 	ACEN,A
	MOV 	B,#100
	MUL 	AB
	MOV 	ACEN,A
	MOV 	A,ADEC
	MOV 	B,#10
	MUL 	AB
	ADD 	A,ACEN
	ADD 	A,AUNI
	MOV 	B,#2
	MUL 	AB
	MOV 	B,A
	MOV 	A,#200
	SUBB 	A,B
	MOV 	PWM_DUTY,A
	RET

;*************************************
; ------- Rutina de configuración del sistema -------
;--------------------------------------------------------

COND_INI: 
	mov 	TMOD,#02H
	mov 	TL0,#48H
	mov 	TH0,#48H            ;T = 20mSeg, xtal 11.059 MHz
	setb 	TR0
	mov 	IE,#82H
	clr 	PWM_OUT 
	MOV 	PWM_DUTY,#199       ;valor de inicio 0º
	mov 	PWM_TMP1,#200
	MOV 	AUX,#'A'
	ret
;***************************************


;=============LCD==============================================
INICIALIZA_LCD:	
		MOV 	A,#38h	 	;FUNCTION SET
		ACALL 	CMD_LCD
		MOV 	A,#01h		; CLEAR LCD
		ACALL 	CMD_LCD
		MOV 	A,#0CH	
		ACALL 	CMD_LCD
		MOV 	A,#80H	
		ACALL 	CMD_LCD
		RET
CMD_LCD:
	CLR 	RS
	SJMP 	ENABLE

ESCRIBE:
	SETB RS
ENABLE:
	MOV 	LCD,A
	DJNZ 	R7,$
	DJNZ 	R7,$
	CLR 	EN
	DJNZ 	R7,$
	DJNZ 	R7,$
	SETB 	EN
	RET

;-------------------------------------------------------

MSJ_INICIO:	
		MOV 	A,#01H
		ACALL 	CMD_LCD
		MOV 	A,#80H
		ACALL 	CMD_LCD
		MOV 	DPTR,#INICIOM		;INGRESE %
		ACALL 	MSJB
		RET
MSJB:		CLR 	A
		MOVC 	A,@A+DPTR
		JZ 	FINB
		ACALL 	ESCRIBE
		INC 	DPTR
		SJMP 	MSJB
FINB:				
		RET

MSJ_PORCENTAJE:
	MOV 	A,#0C4H
	ACALL 	CMD_LCD
	MOV 	A,#25H
	ACALL 	ESCRIBE
	MOV 	A,CENTENAS
	ACALL 	ESCRIBE
	MOV 	A,DECENAS
	ACALL 	ESCRIBE
	MOV 	A,UNIDADES
	ACALL 	ESCRIBE
	RET

;==========RUTINA PARA OBTENER 1 DIGITO POR TECLADO =================
;	Acc, R6-R7 (TECLADO). En Acc regresa el valor equivalente hex
;====================================================================

OBT1DIG:	ACALL 	TECLADO		;ESPERA OPCION 
		CJNE 	A,#10H,OBT1DIG01
		MOV 	TEC_ANT,A
		SJMP 	OBT1DIG

OBT1DIG01:	CJNE 	A,#11H,OBT1DIG02	;SE PRESIONA MAS DE UNA TECLA
		MOV 	TEC_ANT,A
		SJMP 	OBT1DIG

OBT1DIG02:	CJNE 	A,TEC_ANT,OBT1DIG03
		SJMP 	OBT1DIG

OBT1DIG03:	MOV 	TEC_ANT,A
		RET

;================RUTINA DEL TECLADO====================================
TECLADO:
	mov R6,#0EFH ;inicia las columnas (nibble alto)
	mov A,R6

CHK_TEC:
	mov 	TECLADOM,A 	;envia columna
	djnz 	R7,$
	mov 	A,TECLADOM 	;lee el renglón
	mov 	R5,A
	anl 	A,#0FH
	cjne 	A,#0FH,TEC_00 	;verifica si hay tecla
	mov 	A,R6
	rl 	A 		;siguiente columna
	mov 	R6,A
	cjne 	A,#0FEH,CHK_TEC ;verifica última columna
	mov 	A,#10H 		;código de no_tecla
	ret
;------------------------------------------------------------

TEC_00:	
		mov 	A,R5	
		cjne 	A,#7EH,TEC_01
		mov 	A,#'D'
		ret

TEC_01:	
		cjne 	A,#7DH,TEC02
		mov 	A,#'+'
		ret

TEC02:	
		cjne 	A,#7BH,TEC03
		mov 	A,#'='
		ret

TEC03:	
		cjne 	A,#77H,TEC04
		mov 	A,#'+'
		ret

TEC04:	
		cjne 	A,#0BEH,TEC05
		mov 	A,#'9'
		ret

TEC05:	
		cjne 	A,#0BDH,TEC06
		mov 	A,#'6'
		ret
 
TEC06:	
		cjne 	A,#0BBH,TEC07
		mov 	A,#'3'
		ret

TEC07:	
		cjne 	A,#0B7H,TEC08
		mov 	A,#'N'
		ret

TEC08:	
		cjne 	A,#0DEH,TEC09
		mov 	A,#'8'
		ret

TEC09:	
		cjne 	A,#0DDH,TEC0A
		mov 	A,#'5'
		ret

TEC0A:	
		cjne 	A,#0DBH,TEC0B
		mov 	A,#'2'
		ret

TEC0B:	
		cjne 	A,#0D7H,TEC0C
		mov 	A,#'0'
		ret

TEC0C:	
		cjne 	A,#0EEH,TEC0D
		mov 	A,#'7'
		ret

TEC0D:	
		cjne 	A,#0EDH,TEC0E
		mov 	A,#'4'
		ret

TEC0E:	
		cjne 	A,#0EBH,TEC0F
		mov 	A,#'1'
		ret

TEC0F:	
		cjne 	A,#0E7H,TEC_ERR
		mov 	A,#'Y'
		ret

TEC_ERR:	
		mov 	A,#11H 	;código de más de una tecla
		ret

MOVING:	
	DB 'TRABAJANDO AL:',0

INICIOM:	
	DB 'INGRESE % :',0

end
