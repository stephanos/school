; *********************************
; * © Stephan Behnke
; * Homepage: www.tcltk.de.vu
; * E-Mail: stephan.behnke@gmx.net
; *********************************

; Errechnet den ggt für Zahlen z1 und z2 aus dem C-Programm
; PS: Unterstriche unter Linux entfernen

    GLOBAL _ggt
    EXTERN _z1, _z2

    SECTION .text

    CODE

    _ggt:

        PUSH BX
        MOV EAX, [_z1]          ; Variablen in Register ABX und
        MOV EBX, [_z2]          ; EBX schieben

    schleife:
        CMP EAX, EBX            ; Zahlen vergleichen
        JZ  fertig              ; IF (EAX == EBX) beenden
        JB  kleiner             ; IF (EAX  < EBX) EAX von EBX subtrahieren

        SUB EAX, EBX            ; EAX = EAX - EBX
        JMP schleife            ; Schleife wiederholen
	
    kleiner:
        SUB EBX, EAX            ; EBX = EBX - EAX
        JMP schleife            ; Schleife wiederholen

    fertig:
        POP BX
        RET
        END
