;******************************************************
;---Manejo de puertos. Funcionamiento de semaforo---
;******************************************************


;--------- VARIABLES----------- 

TIEMPO1    equ  33H
TIEMPO2    equ  73H
TIEMPO3    equ  53H

TIEMPO4    equ  66H
TIEMPO5    equ  67H
TIEMPO6    equ  65H



;---------- PROGRAMA ------------


INICIO:

			mov Acc,P0
			PUSH Acc
			anl Acc,#0FH
			jz  INICIO
						
;            ++++++  SEMAFORO 1 +++++

ciclo:		
			MOV P1,#TIEMPO1
			ACALL RETARDO_1s 
			dec Acc
			cjne A,#0H,ciclo    
		
			MOV P1,#TIEMPO2		
			ACALL RETARDO_1s

			MOV P1,#TIEMPO1	
			ACALL RETARDO_1s
		
			MOV P1,#TIEMPO2		
			ACALL RETARDO_1s
			 
			MOV P1,#TIEMPO1	
			ACALL RETARDO_1s
			
			MOV P1,#TIEMPO3		
			ACALL RETARDO_1s	
			POP Acc



;          ++++++  SEMAFORO 2 +++++


INICIO2:
			mov Acc,P0
			swap A
			anl Acc,#0FH
			jz  INICIO2

ciclo2:
			MOV P1,#TIEMPO4		
			ACALL RETARDO_1s
			dec Acc
			cjne A,#0H,ciclo2 

		
			MOV P1,#TIEMPO5		
			ACALL RETARDO_1s
			
			MOV P1,#TIEMPO4		
			ACALL RETARDO_1s
			
			MOV P1,#TIEMPO5		
			ACALL RETARDO_1s

			MOV P1,#TIEMPO4	
			ACALL RETARDO_1s


			MOV P1,#TIEMPO6		
			ACALL RETARDO_1s	

					
			sjmp INICIO



;---------- SUBRUTINAS -----------

			
                                                                                                               
RETARDO_1s:
		MOV R5,#8

RETARDO2:	DJNZ R7,$
	    	DJNZ R6,RETARDO2
		DJNZ R5,RETARDO2
		RET
			
