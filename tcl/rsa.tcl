#Programm zum Verschlüsseln von Dateien
# © ® Stephan Behnke ™

 #Liste der Buchstaben
 set letters { " " a b c d e f g h i j k l m n o p q r s t u v w x y z ä ö ü "." ","}

 #Liste der Zahlen in Wörtern
 set numbers { null eins zwei drei vier fuenf sechs sieben acht neun }

 set e ""
 set d ""
 set n ""
 set p ""
 set q ""

#===============================
#Prozedur zum Öffnen einer Datei
#===============================
proc openFile { seite } {

 #Pfad ermitteln
 set pfad [tk_getOpenFile]

 #Fehlerkontrolle
 if { $pfad == "" } { return }

 #Inhalt der Textfelder löschen
 .links.text delete 1.0 end
 .rechts.text delete 1.0 end

 #Datei einlesen
 set stream  [open $pfad r]

 #Datei auslesen
 set text [read $stream]

 #Inhalt ausgeben
 .$seite.text insert end $text

 #Kanal schließen
 close $stream

 #Variabeln löschen
 unset pfad
 unset text
 unset stream

}

#==================================
#Prozedur zum Speichern einer Datei
#==================================
proc saveFile { seite } {

 #Pfad einlesen
 set pfad [tk_getSaveFile]

 #Fehlerkontrolle
 if { $pfad == "" } { return }

 #Daten in String einlesen
 set data [.$seite.text get 1.0 end]

 #Datenstrom erstellen
 set stream [open $pfad w 0755]

 #String in Datei schreiben
 puts -nonewline $stream $data

 #Datenstrom schließen
 flush $stream
 close $stream

 #Variabeln löschen
 unset pfad
 unset data
 unset stream

}

#=============================================
#Prozedur zum Ent- und Verschlüsseln der Datei
#=============================================
proc codieren {art} {
global e d n

 #Text codieren und ausgeben
 if {$art == "ent"} {
 	.links.text delete 1.0 end
 	.links.text insert end [number2letter [rsa [.rechts.text get 1.0 end] $d $n]]
        .rechts.text delete 1.0 end
 } else {
 	.rechts.text delete 1.0 end
 	.rechts.text insert end [rsa [vorbereiten [.links.text get 1.0 end]] $e $n]
 	.links.text delete 1.0 end
 }

 .mitte.1.ver configure -state normal
 .mitte.3.ent configure -state normal
 .mitte.4.schl configure -state normal

 #Löschen
 unset art

}

#====================================
#Prozedur zum Erzeugen von Primzahlen
#====================================
proc prim {} {

 set liste {}

 for {set i 0} {$i<2} {incr i} {

 	set zahl 0
        while {![check $zahl 5] && $zahl!=[lindex $liste 0]} {
 		set zahl [expr int(rand()*200)+3]
 	}

 	lappend liste $zahl
 }

 return $liste

}

#===========================================
#Prozedur zum Erzeugen der Variabeln e und d
#===========================================
proc keys {} {
global e d p q n

 set t 1
 set erg 0
 set teiler [expr ($p-1)*($q-1)]

 if {$e!="" && $d!=""} {
 	if {[expr ($e*$d)%$teiler]!=1} {set e 0; set d 0}
 }

 for {set i 1} {$t} {incr i} {

        set produkt [expr $teiler*$i+1]
        if {![check $produkt 5]} {
 		for {set j 2} {$j<[expr $produkt/2+1]} {incr j} {
                	if {![expr $produkt%$j] && $j!=[expr $produkt/$j] && $j>$e} {
                  		set e $j
                        	set t 0
                        	break
               	 	}
 		}
 	}
 }

 set d [expr $produkt/$e]
 set n [expr $p * $q]

}

#===============================================
#Prozedur zum Überprüfen auf Primzahleigenschaft
#===============================================
proc check {zahl1 zahl2} {

 if {$zahl1==$zahl2} {return 0}
 if {$zahl1<1||$zahl2<1} {return 0}
 if {$zahl1==""||$zahl2==""} {return 0}
 if {$zahl1==" "||$zahl2==" "} {return 0}

 for {set i 1} {$i<3} {incr i} {

 	set div 3
 	if {$i==1} {set var $zahl1} else {set var $zahl2}

 	#Zahl ($var) sofort auf Teilbarkeit von 2 untersuchen
	if {[expr $var % 2]==0}  {return 0}

 	#Bei den Zahlen 2,3 und 5 sofort als Primzahl ausgeben
 	if {$var==3||$var==5}  {return 1}

	#Schleife bis zur Hälfte der zu testenden Zahl ($var)
	while {[expr $div*2+1] <= $var}  {

		if {[expr $var % $div] == 0} {
			#Schleife beenden
			return 0
		} else {
			#Divisor um 2 erhöhen
			incr div 2
		}
	}
 }

 return 1

}

#=============================================
#Prozedur fürs Toplevel für Schlüsselerzeugung
#=============================================
proc schluessel {} {
global e d p q n

 #Stand ausgeben
 .menuleiste.aktuell configure -text "Bitte alle Zahlen sachgerecht eintragen oder einfach berechnen lassen!"
 update

 set d ""; set e ""; set p ""; set q ""; set n ""

 #Altes Fenster ggf. löschen
 catch [destroy .ver]

 #Toplevel erstellen
 toplevel .ver

 #Widgets deklarieren
 frame .ver.oben
 frame .ver.mitte
 frame .ver.unten
 label .ver.oben.lp -text "p:"
 entry .ver.oben.p -textvariable p -width 7
 label .ver.oben.lq -text "q:"
 entry .ver.oben.q -textvariable q -width 7
 label .ver.mitte.le -text "e:"
 entry .ver.mitte.e -textvariable e -width 7 -state disable -bg gray
 label .ver.mitte.ld -text "d:"
 entry .ver.mitte.d -textvariable d -width 7 -state disable -bg gray
 button .ver.unten.ok -text "Ok" -command {set ok 1}
 button .ver.oben.prim -text "Primzahlen erzeugen" -command {set liste [prim]; set p [lindex $liste 0]; set q [lindex $liste 1]; set e ""; set d ""}
 button .ver.mitte.ber -text "Berechnen" -command {if {[check $p $q]} {keys} else {.menuleiste.aktuell configure -text "P und Q sind keine Primzahlen!"; update}}

 #Packen
 pack .ver.oben .ver.mitte .ver.unten -side top
 pack .ver.oben.lp .ver.oben.p .ver.oben.lq .ver.oben.q .ver.oben.prim -side left -pady 10 -padx 5
 pack .ver.mitte.le .ver.mitte.e .ver.mitte.ld .ver.mitte.d .ver.mitte.ber -side left -padx 5 -pady 10
 pack .ver.unten.ok -pady 5

 #Fenster konfigurieren
 wm resizable .ver no no
 wm title .ver "Schlüssel generieren"

 vwait ok

 #Stand ausgeben
 .menuleiste.aktuell configure -text "Öffentlicher Schlüssel lautet ($e, $n)"
 update

 set p ""; set q ""

}

#======================================================
#Prozedur zum Vorbereiten (fürs Codieren) eines Strings
#======================================================
proc vorbereiten {String} {
global letters numbers

 #Alle Buchstaben auf Kleinbuchstaben setzen
 set String [ string tolower $String 0 end ]

 #Ersetzen
 regsub -all "\t" $String " " String
 regsub -all "\n" $String " " String
 regsub -all "ß" $String "ss" String
 for { set i 0 } { $i < 10 } { incr i } {
	regsub -all "$i" $String  "[lindex $numbers $i]" String
 }

 set temp ""
 set laenge [string length $String]

 #Buchstaben umwandeln
 for { set i 0 } { $i < $laenge } { incr i } {
	set z [lsearch $letters [string index $String $i]]
	if {$z!=-1} {
		if {$z<9} { append temp 0 }
		append temp "$z "
	}
 }

 #String übergeben
 set String $temp
 unset temp

 return [string range $String 0 [expr [string length $String]-2]]

}

#================================================
#Prozedur fürs Umwandeln von Zahlen in Buchstaben
#================================================
proc number2letter {String} {
global letters numbers

 set temp ""
 set buchstaben [llength $letters]
 set liste [split $String " "]
 set laenge [llength $liste]

 for {set i 0} {$i < $laenge} {incr i} {

	#Block einlesen
 	set number [lindex $liste $i]

 	#Kontrolle
	if {[string index $number 0]==0&&[string length $number]>1} {regsub "0" $number "" number}

 	append temp [lindex $letters [expr $number%$buchstaben]]
 }

 set liste $temp
 set String [join $liste]

 #Wörter durch Zahlen ersetzen
 for { set i 0 } { $i < 10 } { incr i } {
	regsub -all "[lindex $numbers $i]" $String  "$i" String
 }

 #Löschen
 unset liste
 unset temp

 return $String

}

#===========================================
#Prozedur zum Errechnen der einzelnen Blöcke
#===========================================
proc berechne {zahl potenz n} {

 set potenzen {}
 set ergebnisse {}
 set temp $potenz

 #Potenz in 2er Potenzen auflösen
 for {set i 1} {$temp>1} {incr i} {

	set hoch [expr int(pow(2,$i))]
 	set teil [expr int($temp/$hoch)]

        if {$teil==1} {
        	lappend potenzen $hoch
        	incr temp -$hoch
        	set i 0
        }
 }

 #Rest hinzufügen
 if {$temp} {lappend potenzen 1}

 set erg [expr $zahl%$n]
 if {[lsearch $potenzen $i]>=0} {append ergebnisse $erg}

 #Potenzen mit Modulu berechnen
 for {set i 2} {$i <= [lindex $potenzen 0]} {set i [expr $i*2]} {

        set erg [expr int(pow($erg,2))%$n]

        if {[lsearch $potenzen $i]>=0} {
        	lappend ergebnisse $erg
        }
 }

 #Rest errechnen
 set erg [lindex $ergebnisse 0]
 for {set i 1} {$i < [llength $ergebnisse]} {incr i} {
        set erg [expr ($erg * [lindex $ergebnisse $i])%$n]
 }

 #Löschen
 unset zahl
 unset temp
 unset potenz
 unset potenzen
 unset ergebnisse

 return $erg

}

#============
#Prozedur RSA
#============
proc rsa {zeichen potenz n} {
global letters numbers

 .mitte.1.ver configure -state disable
 .mitte.3.ent configure -state disable
 .mitte.4.schl configure -state disable

 #Stand ausgeben
 .menuleiste.aktuell configure -text "0 % abgeschlossen"
 update

 set zeichen [split $zeichen " "]
 set laenge [llength $zeichen]
 set krypt {}

 #Ver- & Entschlüsseln
 for {set i 0} {$i < $laenge} {incr i} {

 	#Zahl einlesen
 	set number [lindex $zeichen $i]

	#Zahl formatieren
	if {[string index $number 0]==0 && [string length $number]>1} {regsub "0" $number "" number}

	#Ergebnis berechnen
       	set erg [berechne $number $potenz $n]

	#Ergebnis speichern
	if {$erg<10} {
		lappend krypt "0$erg"
	} else {
		lappend krypt "$erg"
	}

	#Stand ausgeben
	.menuleiste.aktuell configure -text "[expr (100*$i)/$laenge] % abgeschlossen"
	update
 }

 #Stand ausgeben
 .menuleiste.aktuell configure -text "100% abgeschlossen"
 update

 #Variabeln löschen
 unset zeichen
 unset potenz

 return [join $krypt]

}

#======
#Frames
#======
 frame .code
 frame .oben
 frame .links
 frame .mitte
 frame .rechts
 frame .mitte.1
 frame .mitte.2
 frame .mitte.3
 frame .mitte.4
 frame .menuleiste

#====
#Menu
#====
 menubutton .oben.datei -text "Datei" -menu .oben.datei.m
 menu .oben.datei.m -tearoff 0
 menu .oben.datei.m.unver -tearoff 0
 menu .oben.datei.m.ver -tearoff 0

 .oben.datei.m add cascade -label "Unverschlüsseltes " -menu .oben.datei.m.unver
 .oben.datei.m add cascade -label "Verschlüsseltes " -menu .oben.datei.m.ver

 .oben.datei.m.unver add command -label "Öffnen" -command "openFile links"
 .oben.datei.m.unver add command -label "Speichern Unter" -command "saveFile links"
 .oben.datei.m.ver add command -label "Öffnen" -command "openFile rechts"
 .oben.datei.m.ver add command -label "Speichern Unter" -command "saveFile rechts"

 .oben.datei.m add command -label "Beenden" -command exit

#=====
#Label
#=====
 label .mitte.2.le -text "e: "
 label .mitte.2.ld -text "d: "
 label .mitte.2.ln -text "n: "
 label .mitte.4.leer -height 2
 label .menuleiste.aktuell -text "Zum Verschlüsseln Schlüsselpaar (e, n) oder zum Entschlüsseln Schlüsselpaar (d, n) eingeben!" -relief sunken -width 120

#====
#Text
#====
 text .links.text	-bg white -relief sunken \
			-yscrollcommand {.links.scrolly1 set } \
			-wrap word -width 50 -height 30

 text .rechts.text	-bg white -relief sunken \
			-yscrollcommand {.rechts.scrolly2 set } \
			-wrap word -width 50 -height 30

#=========
#Scrollbar
#=========
 scrollbar .links.scrolly1 -orient vertical -command ".links.text yview"
 scrollbar .rechts.scrolly2 -orient vertical -command ".rechts.text yview"

#=============
#Eingabefelder
#=============
 entry .mitte.schluessel -textvariable key -width 15
 entry .mitte.2.e -textvariable e -width 7
 entry .mitte.2.d -textvariable d -width 7
 entry .mitte.2.n -textvariable n -width 7

#======
#Button
#======
 button .mitte.1.ver -text "Verschlüsseln ->" -command { if {[.links.text get 1.0 end]!="\n" && $n!="" && $e!="" && $n!=0} {codieren "ver"}}
 button .mitte.3.ent -text "<- Entschlüsseln" -command { if {[.rechts.text get 1.0 end]!="\n" && $n!="" && $d!="" && $n!=0} {codieren "ent"}}
 button .mitte.4.schl -text "Schlüssel generieren" -command {schluessel; catch [destroy .ver]}

#========
#Bindings
#========
 bind . <Control-o> "openFile links"

#======
#Packen
#======

 pack .oben -fill x
 pack .code -expand true -fill both
 pack .oben.datei -side left
 pack .links -expand true -fill both -side left -in .code
 pack .mitte -side left -in .code
 pack .mitte.1 .mitte.2 .mitte.3 .mitte.4 -side top -pady 10
 pack .rechts -expand true -fill both -side left -in .code
 pack .menuleiste -pady 2 -fill x

 pack .links.text -side left -fill both -expand true -pady 5
 pack .links.scrolly1  -side right -fill y -pady 5

 pack .rechts.text -side left -fill both -expand true -pady 5
 pack .rechts.scrolly2  -side right -fill y -pady 5

 pack .menuleiste.aktuell -fill x

 pack .mitte.1.ver
 grid .mitte.2.le .mitte.2.e
 grid .mitte.2.ld .mitte.2.d -pady 5
 grid .mitte.2.ln .mitte.2.n
 pack .mitte.3.ent -padx 10
 pack .mitte.4.leer .mitte.4.schl -side top -padx 5

 wm title . "RSA Verschlüsselung"

# © ® Stephan Behnke ™
