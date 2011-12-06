; *********************************
; * © Stephan Behnke
; * Homepage: www.tcltk.de.vu
; * E-Mail: stephan.behnke@gmx.net
; *********************************

; Errechnet das Produkt aus den Zahlen z1 und z2 aus dem C-Programm
; PS: Unterstriche unter Linux entfernen

    GLOBAL _aeg_mult
    EXTERN _z1, _z2

    SECTION .text

    ; Register:
    ; AX, beinhaltet das Produkt
    ; BX und CX, beinhalten die Faktoren
    ; DX, beinhaltet zwischenzeitlich CX, Zwischenspeicher

    CODE

    _aeg_mult:

        PUSH BX
        MOV AX,0            ; AX auf 0 setzen
        MOV BX,[_z1]        ; BX und
        MOV CX,[_z2]        ; CX mit den Faktoren füllen

    schleife:
        CMP CX,0            ; CX mit 0 vergleichen
        JZ fertig           ; IF (CX == 0) Beenden
        JA mult             ; IF (CX > 0)  Multiplizieren

    mult:
        MOV DX,CX           ; CX nach DX bewegen (sichern)
        AND CX,1            ; Überprüfen ob CX ungerade ist, 1 falls ja
        CMP CX,1            ; Register CX mit 1 vergleichen, CX ist ungerade
        JZ summe            ; IF (CX == 1) Addieren
        JB halb             ; IF (CX < 0)  Halbieren

    summe:
        ADD AX,BX           ; AX = BX + AX
        JMP halb            ; Faktoren verdoppeln/halbieren

    halb:
        MOV CX,DX           ; DX nach CX schieben (wiederherstellen)
        SHR CX,1            ; CX halbieren
        SHL BX,1            ; BX verdoppeln
        JMP schleife        ; Schleife wiederholen

    fertig:
        POP BX
        RET
        END

