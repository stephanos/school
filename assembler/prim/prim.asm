; *********************************
; * © Stephan Behnke
; * Homepage: www.tcltk.de.vu
; * E-Mail: stephan.behnke@gmx.net
; *********************************

; Errechnet ob alle Primzahlen aus einem Zahlenbereich, der durch
; das C-Programm definiert wird
; PS: Unterstriche unter Linux entfernen

    GLOBAL _prim
    EXTERN _bis, _von

    ; Variablen:
    SECTION .data
    zahl dw 0

    ; Code:
    SECTION .text

    CODE
    FINIT

    ; Register:
    ;   EAX, Anzahl der Primzahlen    (und temp. Kopie der Zahl)
    ;   EBX, Zahl
    ;   ECX, Teiler
    ;   EDX, Wurzel der Zahl          (und temp. Rest der Division)

    _prim:
        PUSH EBX

        MOV EAX,0                ; Anzahl der Primzahlen initalisieren
        MOV EBX,[_von]           ; Startzahl in EBX schieben

    schleife:
        CMP EBX,[_bis]           ; Aktuellen Zahl mit Grenze vergleichen
        JG  fertig               ; IF(EBX > bis) Beenden

        MOV [zahl],EBX           ; Aktuelle Zahl in Variable schreiben
        FILD DWORD [zahl]        ; Variable in Stack laden
        FSQRT                    ; Wurzel ziehen
        FISTP DWORD [zahl]       ; Ergebnis in Variable schreiben
        MOV EDX,[zahl]           ; Variable in EDX schreiben (Wurzel)

        MOV ECX,3                ; Teiler in ECX initalisieren
        JMP testen               ; Aktuelle Zahl testen

    testen:
        PUSH EDX
            XOR EDX,EDX          ; EDX leeren
            PUSH EAX
                MOV EAX,EBX      ; Kopie der Zahl in EAX schieben
                DIV ECX          ; EAX durch ECX teilen
            POP EAX
            CMP EDX,0            ; EDX, den Rest, mit 0 vergleichen
        POP EDX
        JE  schritt              ; Schritt weiter durchführen

        ADD ECX,2                ; Teiler um 2 erhöhen
        CMP ECX,EDX              ; Teiler mit der Wurzel vergleichen
        JG  primzahl             ; IF(ECX >= EDX) Primzahl

        JMP testen               ; Test wiederholen

    primzahl:
        ADD EAX,1                ; Anzahl der Primzahlen um 1 erhöhen

    schritt:
        ADD EBX,2                ; Zahl um 2 Schritte erhöhen
        JMP schleife             ; Schleife wiederholen

    fertig:
        POP EBX
        RET
        END
