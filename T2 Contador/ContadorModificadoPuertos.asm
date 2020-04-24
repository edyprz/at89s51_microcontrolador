;*****************************************************
; Contador con display de 7 segmentos con velocidad
;****************************************************


;Decalaracion de variables


uno		equ	7FH
dos 		equ	7EH
tres		equ	7DH
cuatro		equ	7CH
tiempo  	equ	7BH

;--------------------------------


INICIO:	
 		mov	uno,#0FH
		mov	dos,#02H
		mov	tres,#04H
		mov	cuatro,#08H

imprime:	
		mov	A,uno  ;Movemos unidades al acumulador
		acall	escara      ;Llamamos a escara para enmascarar lo que hay en el acumulador
		mov	A,dos   ;Movemos decenas en acumulador
		acall	escara
		mov	A,tres  ;Sobreescribimos el acumulador con centenas
		acall	escara
		mov	A,cuatro  ;Sobreescribimos el acumulador con millares
		acall	escara
		ret 

increcuatro:	
		inc	cuatro     ;Incremento millares
incretres:	
		inc	tres   ;Incremento centenas
incredos:	
		inc	dos	   ;Incremento decenas
increuno:	
		inc	uno   ;Incremento unidades
		acall	tiempo_    ;LLamamos a tiempo_


escara:
		swap	A        ;Intercambia nibbles en el acumulador, los enmascara
		mov	p2,A
		mov	R3,#10   ;Mueve el dato en el registro3

sig:	
		djnz	R4,$    ;Salta a la misma posicion si es diferente de cero
		djnz	R3,sig
		ret

		mov	R7,tiempo 

tiempo_:
		jb	p2.0,lee1  	;Salta a tim_1 si p2.0 es uno
		jb	p2.1,lee2  	;Salta si es uno
		mov	tiempo,#7
		ret
lee1:	
		jb	p2.1,lee3   ;Salta a tim_3 si p2.1 es uno
		mov	tiempo,#14  ;Mueve el dato a tiempo
		ret
lee2:	
		mov	tiempo,#28  ;Mueve el dato a tiempo
		ret
lee3:		
		mov	tiempo,#56  ;Mueve el dato al tiempo
		ret

;-------------------------------------------------------------------------------

RETARDO_:	
		mov	A,#19H	  	;Limite de unidades sera el nueve		
		subb	A,uno
		jnz	increuno		;Incrementamos valor
		mov	uno,#0FH

		mov	A,#29H		;Limite de decenas sera el nueve
		subb	A,dos
		jnz	incredos	
		mov	dos,#1FH 
		
		mov	A,#49H		;Limite de centenas sera el nueve
		subb	A,tres
		jnz	incretres	
		mov	tres,#3FH
		
		mov	A,#89H		;Limite de millar sera el nueve
		subb	A,cuatro	
		jnz	increcuatro	
		ljmp	INICIO          	;Salto largo a inicio
                 

		acall	imprime
		djnz	R7,RETARDO_

