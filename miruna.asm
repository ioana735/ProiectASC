assume cs:code, ds:data

data segment
    ; mesasejele de afisare
    ; $ marchează sfârșitul pentru funcția AH=09h.
    msg_intro      db 'Introduceti octeti in format hex (8-16 valori): $'
    ; 13,10 = trecere la linie nouă .
    msg_too_few    db 13,10,'Trebuie sa introduceti minim 8 octeti.$'
    msg_too_many   db 13,10,'Nu se pot introduce mai mult de 16 octeti.$'


    lungime_maxima     db 50
    lungime_introdusa  db ?
    sir_introdus       db 50 dup(0)

    ; sirul cu rezultatul
    sir_octeti_binari db 16 dup(?)
    ; contor pentru câți octeți au fost convertiți
    numar_octeti      db 0

    ; alte variabile
    cifra_hex_superioara db 0
    cifra_hex_inferioara db 0
    octet_binar          db 0

data ends

code segment
start:
    mov ax, data
    mov ds, ax

    ; afisam mesajul de introducere
    mov ah, 09h
    mov dx, offset msg_intro
    int 21h

    ; ===== CITIRE BUFFER DOS =====
    mov ah, 0Ah
    mov dx, offset lungime_maxima
    int 21h

    ; punem in si offsetul sirului nostru cu elemente in hexa
    ; punem in di offsetul sirului pe care vrem sa l obtinem cu valori in binar
    mov si, offset sir_introdus
    mov di, offset sir_octeti_binari
    mov numar_octeti, 0

prelucrare_octeti:
    mov al, [si]
    cmp al, 13              ; verifica daca este enter
    je verificare_numar     ; verifica apoi daca avem intre 8-16 numere introduse

    ;Verificarea primei cifre din hex
    ;verifica daca este cifra
    cmp al, '9'
    jle cifra_superioara_cifra
    sub al, 'A' - 10
    ; daca e cifra trece direct la conversi, daca e litera o trsf in cifre
    jmp gata_superioara
cifra_superioara_cifra:
    ; o pastreaza cifra
    sub al, '0'
gata_superioara:
    ; converteste litera hex in cifra
    mov cifra_hex_superioara, al
    inc si
    mov al, [si]

    ; A doua cifra hex
    cmp al, '9'
    jle cifra_inferioara_cifra
    sub al, 'A' - 10
    jmp gata_inferioara
cifra_inferioara_cifra:
    sub al, '0'
gata_inferioara:
    mov cifra_hex_inferioara, al

    ; Transformare din hexa in binar 
    ; ex: AB- nr in hexa
    ; octet= A* 16+ B 
    mov al, cifra_hex_superioara
    shl al, 4               ; inmultire cu 16= shiftare cu 4 pozitii la stanga
    add al, cifra_hex_inferioara
    mov octet_binar, al

    ; adaugam in sirul pe care il construim
    mov al, octet_binar
    mov [di], al
    inc di

    ; crestem contorul
    inc numar_octeti

    ; sarim peste spatiu
    inc si
    cmp byte ptr [si], ' '
    jne prelucrare_octeti
    inc si
    jmp prelucrare_octeti

verificare_numar:
    ; vrifica daca sirul are minim 8 elemente
    mov al, numar_octeti
    cmp al, 8
    jb prea_putini

    ; verifica daca are masim 16 elemente
    cmp al, 16
    ja prea_multi

    jmp terminare

prea_putini:
    mov ah, 09h
    mov dx, offset msg_too_few
    int 21h
    jmp terminare

prea_multi:
    mov ah, 09h
    mov dx, offset msg_too_many
    int 21h
    jmp terminare

terminare:
    mov ax, 4C00h
    int 21h

code ends
end start
