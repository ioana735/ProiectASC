# ProiectASC
Documentație  

1. Descrierea generală a programului 

Programul, scris pentru 8086, în TASM/TLINK, mod 16-biți, permite utilizatorului să 
introducă între 8 și 16 valori hexadecimale. Acesta realizează o serie de operații de 
manipulare a datelor la nivel de bit, sortări și calcule aritmetice.  

2. Structura 
A. Citirea și Validarea Datelor 

Utilizăm funcția AH=0Ah a INT 21h pentru a citi un buffer de caractere. 

• Validare: Codul verifică variabila numar_octeti după citire. Dacă acesta este sub 8 sau peste 16 programul se termină. 

• Conversie: Fiecare pereche de caractere ASCII este transformată în valoare numerică. De exemplu, pentru 'A' și 'B', scădem codul ASCII corespunzător pentru a obține 0Ah și 0Bh, apoi shiftăm prima cifră cu 4 poziții și o adunăm pe a doua: octet = A*16+B 

B. Calculul Cuvântului de Control C_word (16 biți) 

Calculul este împărțit în trei pași: 

1. Pas 1 (Biții 0-3): Operație XOR între primii 4 biți ai primului octet și ultimii 4 biți ai ultimului octet. 

2. Pas 2 (Biții 4-7): Se parcurge tot șirul și se aplică OR între biții 2-5 ai fiecărui octet. Rezultatul se stochează în C_word. 

3. Pas 3 (Biții 8-15): Se realizează suma aritmetică a tuturor octeților. Se păstrează doar restul împărțirii la 256, conform regulii modulo 256. 

C. Manipularea Șirului 

• Sortare: S-a implementat algoritmul Bubble Sort. Acesta parcurge șirul în mai multe treceri, comparând elementele adiacente și interschimbându-le dacă nu sunt în ordine descrescătoare. 

• Identificare Octet: Se parcurge șirul sortat și, pentru fiecare octet, se numără biții de "1" prin shiftări succesive la dreapta (SHR) și adunarea flag-ului de Carry (ADC). Programul reține poziția primului octet care are cel mai mare număr de biți de "1", cu condiția ca acest număr să fie mai mare de 3. 

• Pentru fiecare octet din șir:  
  - Se calculează suma primilor 2 biți ai octetului → rezultatul este N.
  - Octetul se rotește spre stânga cu N poziții (rotire circulară).
  - Se afișează șirul rezultat după rotiri, atât în binar, cât și în hex. 

D. Afișarea Rezultatelor 

Afișarea se face bit cu bit pentru binar (folosind SHL și verificarea flag-ului de Carry) și prin mesaje text pentru poziții. 

3. Dificultăți Întâlnite și Rezolvări 

• Conversia ASCII în Hex: Inițial, programul nu gestiona corect spațiile dintre octeți. 
Rezolvarea a constat în adăugarea unei instrucțiuni inc si suplimentare și a unei 
verificări cmp [si], ' ' pentru a sări peste separatori. 

• Folosirea lui CX pt doua loop-uri intercalate nu se putea și astfel am folosit jump-uri 
sau lucrul cu stiva. 

4. Instrucțiuni de Rulare 
• tasm/zi proiect.asm 
• tlink/v proiect.obj 
• td proiect.exe 

Exemplu de rulat: 

Date pentru citire: 3Fh, 7Ah, 12h, 5Ch, 20h, 11h, 00h, 08h 

Rezultat C_word (binar): 01100000 11110001 

Sir sortat descrescator: 01111010 01011100 00111111 00100000 00010010 00010001 00001000 00000000 

Pozitia octetului cu cei mai multi biti 1 (>3): 2 (00111111 are 6 de 1) 

Sirul sortat rotit: 11110100 F4

10111000 B8 

00111111 3F 

00100000 20

00010010 12

00010001 11 

00001000 08 

00000000 00

  
Diagrama Bloc

![DiagramaFinalFinal](https://github.com/user-attachments/assets/34ebcf37-d55a-4cd4-b57d-7bd01192f847)
