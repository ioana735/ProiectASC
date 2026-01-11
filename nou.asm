assume cs:code, ds:data

data segment
    ; ===== PRIMUL COD (nemodificat) =====
    msg_intro      db 'Introdueti octeti in format hex (8-16 valori): $'
    msg_too_few    db 13,10,'Trebuie sa introduceti minim 8 octeti.$'
    msg_too_many   db 13,10,'Nu se pot introduce mai mult de 16 octeti.$'

    lungime_maxima     db 50
    lungime_introdusa  db ?
    sir_introdus       db 50 dup(0)

    sir_octeti_binari  db 16 dup(?)
    numar_octeti       db 0

    cifra_hex_superioara db 0
    cifra_hex_inferioara db 0
    octet_binar          db 0

    ; ===== REZULTAT FINAL =====
    C_word dw ?
data ends

code segment
start:
    mov ax, data
    mov ds, ax

    ; ===== COD 1: CITIRE + CONVERSIE =====
    mov ah, 09h
    mov dx, offset msg_intro
    int 21h

    mov ah, 0Ah
    mov dx, offset lungime_maxima
    int 21h

    mov si, offset sir_introdus
    mov di, offset sir_octeti_binari
    mov numar_octeti, 0

prelucrare_octeti:
    mov al, [si]
    cmp al, 13
    je verificare_numar

    cmp al, '9'
    jle cifra_superioara_cifra
    sub al, 'A' - 10
    jmp gata_superioara
cifra_superioara_cifra:
    sub al, '0'
gata_superioara:
    mov cifra_hex_superioara, al
    inc si
    mov al, [si]

    cmp al, '9'
    jle cifra_inferioara_cifra
    sub al, 'A' - 10
    jmp gata_inferioara
cifra_inferioara_cifra:
    sub al, '0'
gata_inferioara:
    mov cifra_hex_inferioara, al

    mov al, cifra_hex_superioara
    shl al, 4
    add al, cifra_hex_inferioara
    mov [di], al
    inc di
    inc numar_octeti

    inc si
    cmp byte ptr [si], ' '
    jne prelucrare_octeti
    inc si
    jmp prelucrare_octeti

verificare_numar:
    mov al, numar_octeti
    cmp al, 8
    jb prea_putini
    cmp al, 16
    ja prea_multi

    ; ===== COD 2: CALCUL C_word (MODIFICAT) =====

    ; PAS 1: biti 0–3
    mov al, sir_octeti_binari
    shr al, 4
    and al, 0Fh

    mov bl, numar_octeti
    dec bl
    mov si, bx
    mov bh, sir_octeti_binari[si]
    and bh, 0Fh
    xor al, bh
    mov bl, al

    ; PAS 2: biti 4–7
    xor al, al
    mov cx, numar_octeti
    mov si, 0

pas2_loop:
    mov ah, sir_octeti_binari[si]
    shr ah, 2
    and ah, 0Fh
    or al, ah
    inc si
    loop pas2_loop

    shl al, 4
    or al, bl
    mov bl, al

    ; PAS 3: biti 8–15
    xor al, al
    mov cx, numar_octeti
    mov si, 0

pas3_loop:
    add al, sir_octeti_binari[si]
    inc si
    loop pas3_loop

    mov bh, al

    mov ax, bx
    mov C_word, ax

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

terminare:
    mov ax, 4C00h
    int 21h




;dnjsncs
;dnjdsn
code ends
end start