; *********************************
; * � Stephan Behnke
; * Homepage: www.tcltk.de.vu
; * E-Mail: stephan.behnke@gmx.net
; *********************************

; Errechnet N�herungen von Pi und e
; PS: Unterstriche unter Linux entfernen

    GLOBAL _e, _pi

    ; Variablen:
    SECTION .data
    exponent dw 10000
    nenner   dw 1
    fak      dw 4
    zw       dw 0

    ; Code:
    SECTION .text

    CODE
    FINIT

    ; ===============
    ; Eulersche Zahl:
    ; ===============
    _e:
        PUSH EBX
        MOV ECX,0                 ; Durchl�ufe initalisieren

        FLD1                      ; 1 auf den Stack laden
        FILD WORD [exponent]      ; Exponent (der Nenner) auf den Stack laden
        FDIVP st1                 ; 1/Exponent berechnen
        FLD1                      ; Weitere 1 auf den Stack laden
        FADDP st1                 ; Bruch mit 1 addieren
        FST DWORD [zw]            ; Wert in Variable zwischenspeichern

    e_schleife:
        INC ECX                   ; Anzahl der Durchl�ufe erh�hen
        CMP ECX, 10000            ; Durchl�ufe mit Exponent vergleichen
        JE  fertig                ; Bei ausreichend Durchl�ufen beenden

        FLD DWORD [zw]            ; Klammerinhalt auf Stack laden
        FMULP st1                 ; N�herungswert in st0 mit st1 mulitplizieren

        JMP e_schleife


    ; ==========
    ; Kreiszahl:
    ; ==========
    _pi:
        PUSH EBX
        MOV ECX,1                 ; Durchl�ufe initalisieren
        FLD1                      ; 1 auf Stack laden

    pi_schleife:
        INC ECX                   ; Anzahl der Durchl�ufe erh�hen
        ADD [nenner], DWORD 2     ; Nenner um 2 erh�hen

        CMP ECX,15000
        JE  pi_fertig             ; Bei ausreichend Durchl�ufen beenden

        FLD1                      ; 1 auf den Stack laden
        FILD WORD [nenner]        ; Nenner auf den Stack laden
        FDIVP st1                 ; 1/Nenner rechnen

        XOR EDX,EDX               ; EDX leeren
        MOV EAX,ECX               ; Durchl�ufe in EAX schreiben
        MOV EBX,2                 ; Teiler, 2, in EBX schreiben
        DIV EBX                   ; Durchl�ufe durch 2 Dividieren

        CMP EDX,0                 ; Rest mit 0 vergleichen
        JE  minus                 ; IF (EDX == 0) minus
        JMP plus                  ; IF (EDX != 0) plus

    plus:
        FADDP st1                 ; Bruch addieren
        JMP pi_schleife           ; Schleife widerholen

    minus:
        FSUBP st1                 ; Bruch subtrahieren
        JMP pi_schleife           ; Schleife wiederholen

    pi_fertig:
        FILD  DWORD [fak]         ; Faktor 4 in Stack laden
        FMULP st1                 ; N�herungswert mit 4 multiplizieren
        JMP fertig
        
    fertig:
        POP EBX
        RET
        END
