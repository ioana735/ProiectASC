DATA    SEGMENT
    octeti DB 3Fh, 7Ah, 12h, 5Ch, 20h        ; șir de octeți (poți adăuga oricâți)
    lungime DB 5                               ; numărul de octeți (schimbă după nevoie)
    C_word  DW ?                               ; cuvântul C (16 biți)
DATA    ENDS

CODE    SEGMENT
ASSUME CS:CODE, DS:DATA

START:
  
    ; inițializare segment date

    MOV AX, DATA
    MOV DS, AX


    ; PAS 1: Biții 0–3
    ; primii 4 biți ai primului octet XOR ultimii 4 biți ai ultimului octet

    MOV AL, octeti       ; AL = 3Fh (0011 1111)
    MOV AH, AL           ; AH = 3Fh
    SHR AL, 4            ; AL = 0011 1111 >> 4 = 0000 0011

    AND AL, 0Fh             ; mascare primii 4 biți

    ; găsim ultimul octet
    MOV BX lungime         ; BL = lungimea șirului
    DEC BX                 ; indexul ultimului octet = lungime-1
    MOV SI, BX              ; SI = indexul ultimului octet
    MOV BH, octeti[SI]      ; BH = ultimul octet
    AND BH, 0Fh             ; ultimii 4 biți 

    XOR AL, BH              ; biții 0–3 ai lui C
    MOV BL, AL              ; salvăm temporar biții inferiori


    ; PAS 2: Biții 4–7
    ; OR între biții 2–5 ai fiecărui octet
    
    XOR AL, AL              ; AL = 0, pentru OR final
    MOV CX, lungime         ; contor = număr octeți
    MOV SI, 0               ; index în șir

PAS2_LOOP:  ;0110 1100->0001 1011
    MOV AH, octeti[SI]      ; octet curent
    SHR AH, 2               ; mutăm biții 2–5 la poziția 0–3
    AND AH, 0Fh             ; păstrăm doar 4 biți-> 0000 1011
    OR AL, AH               ; OR în AL
    INC SI
    LOOP PAS2_LOOP

    SHL AL, 4               ; mutăm în poziția 4–7
    OR AL, BL               ; combinăm cu biții inferiori
    MOV BL, AL              ; BL = octet inferior complet


    ; PAS 3: Biții 8–15
    ; suma tuturor octeților modulo 256
 
    XOR AL, AL
    MOV CX, lungime
    MOV SI, 0

PAS3_LOOP:
    ADD AL, octeti[SI]
    INC SI
    LOOP PAS3_LOOP

    MOV BH, AL              ; BH = partea superioară a lui C


    ; construim cuvântul C

    MOV AX, BH
    SHL AX, 8               ; partea superioară în biții 8–15
    OR AX, BL               ; combinăm cu partea inferioară
    MOV C_word, AX          ; salvăm C


       
    MOV AX, 4C00h
    INT 21h

CODE    ENDS
END START
