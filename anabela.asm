assume cs:code, ds:data

data segment
    ; mesasejele de afisare
    ; $ marchează sfârșitul pentru funcția AH=09h.
    msg_intro      db 'Introdueti octeti in format hex (8-16 valori): $'
    ; 13,10 = trecere la linie nouă 
    msg_too_few    db 13,10,'Trebuie sa introduceti minim 8 octeti.$'
    msg_too_many   db 13,10,'Nu se pot introduce mai mult de 16 octeti.$'
    msg_sir_sortat db 13,10,'Sir sortat descrescator: $'
    msg_pozitia db 13,10,'Pozitia octetului cu cei mai multi biti 1 (>3): $'
    msg_cword_bin db 13,10,'Rezultat C_word (binar): $'

    lungime_maxima     db 50
    lungime_introdusa  db ?
    sir_introdus       db 50 dup(0)

    ; sirul cu rezultatul
    sir_octeti_binari  db 16 dup(?)
    ; contor pentru câți octeți au fost convertiți
    numar_octeti       db 0

    ; alte variabile
    cifra_hex_superioara db 0
    cifra_hex_inferioara db 0
    octet_binar          db 0

    ; variabile pentru aflarea pozitie maxime
    nr_maxim db 0
    pozitia_maxima db 0


    C_word dw ?
data ends

code segment
start:
    mov ax, data
    mov ds, ax

    ; afisam mesajul de introducere
    mov ah, 09h
    mov dx, offset msg_intro
    int 21h

    ; CITIRE BUFFER DOS 
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
    cmp al, 13             ; verifica daca este enter
    je verificare_numar    ; verifica apoi daca avem intre 8-16 numere introduse


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
    shl al, 4                   ; inmultire cu 16= shiftare cu 4 pozitii la stanga
    add al, cifra_hex_inferioara

    ; adaugam in sirul pe care il construim
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

    jmp incepe_calcule

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

incepe_calcule:
            ; CALCUL C_word 

; PAS 1: biti 0–3 
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

;          AFISARE C_word IN BINAR 
    mov dx, offset msg_cword_bin
    mov ah, 09h
    int 21h

    mov bx, C_word    ; Incarcam valoarea pe 16 biti
    mov cx, 16        ; Vom afisa 16 biti

afisare_C_binar:
    shl bx, 1         ; Shiftam la stanga, bitul de semn ajunge in Carry Flag (CF)
    jc pune_unu_C
    
    mov dl, '0'
    jmp tipareste_C

pune_unu_C:
    mov dl, '1'

tipareste_C:
    mov ah, 02h
    int 21h
    
    ; punem un spatiu dupa primii 8 biti
    cmp cx, 9
    jne skip_spatiu
    mov dl, ' '
    mov ah, 02h
    int 21h
skip_spatiu:

    loop afisare_C_binar


	;Sortarea sir + afisare pozitie

; sortare descrescatoare
; algoritm: bubble sort

    mov al, numar_octeti
    mov ah,0   ; convertim numar_octeti de la byte la word

    mov cx,ax
    dec cx     ; in cx va fi l-1

sortare:
    mov si,0        ; index pt parcurgerea sirului 
    mov bx,cx       
comparare:
    mov al,sir_octeti_binari[si]      ; elementul curent
    mov dl,sir_octeti_binari[si+1]    ; elementul urmator
    cmp al,dl                         ; comparare
    jae nu_interschimba               ; daca al >= dl nu interschimbam

    ; interschimbare al cu dl
    mov sir_octeti_binari[si],dl 
    mov sir_octeti_binari[si+1],al 

nu_interschimba:
    inc si          ; trecem la urmatorul element din sir
    dec bx
    jnz comparare 

    loop sortare

; afisare sir sortat descrescator

    mov dx, offset msg_sir_sortat
    mov ah,09h
    int 21h

    mov si,0
    mov al, numar_octeti
    mov ah,0   ; convertim numar_octeti de la byte la word

    mov cx,ax   ; in cx avem nr de octeti

afisare_sir_sortat:
    mov bl,sir_octeti_binari[si]
    mov dh,8      ; nr de biti de afisat

biti:
    shl bl,1
    jc bit_1

bit_0:
    mov dl,'0'
    jmp afisare_bit

bit_1: 
    mov dl,'1'

afisare_bit:
    mov ah,02h
    int 21h

    dec dh
    jnz biti

; spatiu intre octeti

    mov dl,' '
    mov ah,02h
    int 21h

    inc si
    loop afisare_sir_sortat

; octetul cu cel mai mare numar de biti 1

    mov al, numar_octeti
    mov ah,0   ; convertim numar_octeti de la byte la word

    mov cx,ax  ; in cx avem nr de octeti
    mov si,0   ; indexul curent 
    mov dl,0   ; pozitia curenta in sir
    mov nr_maxim,0   ; nr maxim de biti 1 gasiti 

next_elem:
    mov al,sir_octeti_binari[si]
    mov bl,al 
    xor bh,bh   ; bh = 0, in bh vom numara bitii 1
    mov dh,8  ;dh Numara bitii octetului

numara_biti:
    shr bl,1     ; shiftare la dreapta
    adc bh,0      ; adunam CF la BH → contor biti 1
    dec dh 
    jnz numara_biti

    ; verificam daca octetul curent are mai multi biti 1 decat maximul gasit

    cmp bh,nr_maxim
    jbe next   ; daca nu depaseste masimul, trecem la urmatorul
    cmp bh, 3  
    jbe next   ; daca are <= 3 biti 1, ignoram

    ; actualizam maximul si pozitia
    mov nr_maxim, bh
    mov pozitia_maxima,dl 

next: 
    inc si      ; trecem la urmatorul octet
    inc dl      ; incrementam pozitia curenta
    dec cx
    jnz next_elem


; afisarea pozitiei 
    mov dx, offset msg_pozitia
    mov ah,09h
    int 21h

    mov al, pozitia_maxima
    add al,'0'
    mov dl,al 
    mov ah,02h
    int 21h


terminare:
    mov ax, 4C00h
    int 21h

code ends
end start