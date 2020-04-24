;*****************************************************
; Contador con display de 7 segmentos con velocidad
;****************************************************


;Decalaracion de variables


unidades	equ	7FH
decenas 	equ	7EH
centenas	equ	7DH
millar		equ	7CH
tiempo  	equ	7BH

;--------------------------------


INICIO:	
 		mov	unidades,#0FH
		mov	decenas,#1FH
		mov	centenas,#3FH
		mov	millar,#7FH

imprime:	
		mov	A,unidades  ;Movemos unidades al acumulador
		acall	escara      ;Llamamos a escara para enmascarar lo que hay en el acumulador
		mov	A,decenas   ;Movemos decenas en acumulador
		acall	escara
		mov	A,centenas  ;Sobreescribimos el acumulador con centenas
		acall	escara
		mov	A,millar  ;Sobreescribimos el acumulador con millares
		acall	escara
		ret 

incremil:	
		inc	millar     ;Incremento millares
increcen:	
		inc	centenas   ;Incremento centenas
incredec:	
		inc	decenas	   ;Incremento decenas
increuni:	
		inc	unidades   ;Incremento unidades
		acall	tiempo_    ;LLamamos a tiempo_


escara:
		swap	A        ;Intercambia nibbles en el acumulador, los enmascara
		mov	p1,A
		mov	R3,#10   ;Mueve el dato en el registro3

sig:	
		djnz	R4,$    ;Salta a la misma posicion si es diferente de cero
		djnz	R3,sig
		ret

		mov	R7,tiempo 

tiempo_:
		jb	p2.0,tim_1  ;Salta a tim_1 si p2.0 es uno
		jb	p2.1,tim_2  ;Salta si es uno
		mov	tiempo,#7
		ret
tim_1:	
		jb	p2.1,tim_3  ;Salta a tim_3 si p2.1 es uno
		mov	tiempo,#14  ;Mueve el dato a tiempo
		ret
tim_2:	
		mov	tiempo,#28  ;Mueve el dato a tiempo
		ret
tim_3:		
		mov	tiempo,#56  ;Mueve el dato al tiempo
		ret

;-------------------------------------------------------------------------------

RETARDO_:	
		mov	A,#19H	  	;Limite de unidades sera el nueve		
		subb	A,unidades
		jnz	increuni		;Incrementamos valor
		mov	unidades,#0FH

		mov	A,#29H		;Limite de decenas sera el nueve
		subb	A,decenas
		jnz	incredec	
		mov	decenas,#1FH 
		
		mov	A,#49H		;Limite de centenas sera el nueve
		subb	A,centenas
		jnz	increcen	
		mov	centenas,#3FH
		
		mov	A,#89H		;Limite de millar sera el nueve
		subb	A,millar	
		jnz	incremil	
		ljmp	INICIO          	;Salto largo a inicio
                 

		acall	imprime
		djnz	R7,RETARDO_

