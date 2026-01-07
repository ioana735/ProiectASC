assume cs:code,ds:data
data segment
	s db 3Fh, 7Ah, 12h, 5Ch, 20h, 11h, 0FFh, 08h
    l equ $-s
    nrMaxim db 0
    pozitiaMaxima db 0
    mesaj1 db 13,10,'Sir sortat descrescator: $'
    mesaj2 db 13,10,'Pozitia octetului cu cei mai multi biti 1 (>3): $'
data ends
code segment
start:
    mov ax,data
    mov ds,ax

; sortare descrescatoare
; algoritm: bubble sort

    mov cx,l
    dec cx     ; in cx va fi l-1

sortare:
    mov si,0
    mov bx,cx
comparare:
    mov al,s[si]
    mov dl,s[si+1]
    cmp al,dl
    jae nu_interschimba

    mov s[si],dl 
    mov s[si+1],al 

nu_interschimba:
    inc si 
    dec bx
    jnz comparare 

    dec cx
    jnz sortare

; octetul cu cel mai mare numar de biti 1

    mov cx,l
    mov si,0
    mov dl,0
    mov nrMaxim

next_elem:
    mov al,s[si]
    mov bl,al 
    xor bh,bh
    mov ch,8

numara_biti:
    shr bl,1
    adc bh,0
    dec ch 
    jnz numara_biti

    cmp bh,nrMaxim
    jbe next
    cmp bh, 3
    jbe next

    mov nrMaxim, bh
    mov pozitiaMaxima,dl 

next:
    inc si 
    inc dl 
    dec cx
    jnz next_elem


; afisarea pozitiei 
    mov dx, offset mesaj2
    mov ah,09h
    int 21h

    mov al, pozitiaMaxima
    add al,'0'
    mov dl,al 
    mov ah,02h
    int 21h

    mov ax,4C00h 
    int 21h
code ends
end start