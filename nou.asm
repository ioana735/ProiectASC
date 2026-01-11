assume cs:code, ds:data

data segment
    msg_intro      db 'Introduceti octeti in format hex (8-16 valori): $'
    msg_too_few    db 13,10,'Trebuie sa introduceti minim 8 octeti.$'
    msg_too_many   db 13,10,'Nu se pot introduce mai mult de 16 octeti.$'
    msg_result     db 13,10,'C_word = $'

    input_buffer   db 50      ; lungime maxima
                   db ?       ; lungime reala completata de DOS
                   db 50 dup(?) ; spatiu stocare

    sir_octeti_binari  db 16 dup(?)
    numar_octeti       db 0

    cifra_hex_superioara db 0
    cifra_hex_inferioara db 0

    C_word dw ?
data ends

code segment
start:
    mov ax, data
    mov ds, ax

    ; afisare mesaj introducere
    mov ah, 09h
    mov dx, offset msg_intro
    int 21h

    ; citire sir de la tastatura
    mov ah, 0Ah
    lea dx, input_buffer
    int 21h

    xor cx, cx
    mov cl, [input_buffer+1]        
    mov si, offset input_buffer+2   
    mov di, offset sir_octeti_binari
    mov byte ptr [numar_octeti], 0

; ================= PARSARE HEX =================
parse_loop:
    cmp cl, 0
    jle verificare_numar
    mov al, [si]

    cmp al, ' '
    je skip_space
    
    cmp al, '9'
    jle high_digit
    sub al, 7       
high_digit:
    sub al, '0'
    mov cifra_hex_superioara, al
    
    inc si
    dec cl

    mov al, [si]
    cmp al, '9'
    jle low_digit
    sub al, 7
low_digit:
    sub al, '0'
    mov cifra_hex_inferioara, al

    mov al, cifra_hex_superioara
    push cx
    mov cl, 4
    shl al, cl      ; Shiftare corecta pentru 8086 folosind CL
    pop cx
    add al, cifra_hex_inferioara

    mov [di], al
    inc di
    inc byte ptr [numar_octeti]

skip_space:
    inc si
    dec cl
    jmp parse_loop

; ================= VERIFICARE =================
verificare_numar:
    mov al, [numar_octeti]
    cmp al, 8
    jb prea_putini
    cmp al, 16
    ja prea_multi

; ================= CALCUL C_word =================

; PAS 1: biti 0–3 (nibble superior din primul octet XOR nibble inferior din ultimul)
    mov al, [sir_octeti_binari]
    push cx
    mov cl, 4
    shr al, cl
    pop cx
    and al, 0Fh
    mov bl, al

    xor ah, ah
    mov al, [numar_octeti]
    dec al
    mov si, ax
    mov bh, [sir_octeti_binari + si] 
    and bh, 0Fh
    xor bl, bh      

; PAS 2: biti 4–7 (OR logic intre bitii 2-5 ai tuturor octetilor)
    xor al, al      
    xor ch, ch
    mov cl, [numar_octeti]
    mov si, 0
pas2_loop:
    mov dl, [sir_octeti_binari+si]
    push cx
    mov cl, 2
    shr dl, cl
    pop cx
    and dl, 0Fh
    or al, dl
    inc si
    loop pas2_loop

    push cx
    mov cl, 4
    shl al, cl      
    pop cx
    or al, bl       
    mov bl, al      

; PAS 3: biti 8–15 (LSB al sumei tuturor octetilor)
    xor ax, ax      
    mov si, 0
    mov cl, [numar_octeti]
    xor ch, ch
pas3_loop:
    xor dx, dx
    mov dl, [sir_octeti_binari+si]
    add ax, dx      
    inc si
    loop pas3_loop

    mov bh, al      ; LSB al sumei devine MSB pentru C_word
    mov C_word, bx

; ================= AFISARE =================
    mov ah, 09h
    mov dx, offset msg_result
    int 21h

    mov ax, C_word
    call PrintHexWord

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

; ================= SUBROUTINE =================

PrintHexWord proc
    push ax
    push bx
    push cx
    push dx
    
    mov bx, ax
    mov cx, 4       
print_digit:
    push cx
    mov cl, 4
    rol bx, cl      ; CORECTAT: 8086 accepta doar rotire cu 1 sau cu CL
    pop cx
    
    mov dl, bl
    and dl, 0Fh
    add dl, '0'
    cmp dl, '9'
    jbe ok_digit
    add dl, 7
ok_digit:
    mov ah, 02h
    int 21h
    loop print_digit
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
PrintHexWord endp

code ends
end start          