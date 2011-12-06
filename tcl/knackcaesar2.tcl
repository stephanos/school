#Programm zum Entschlüsseln von Dateien
# © ® Stephan Behnke ™
# Homepage: www.tcltk.de.vu
# E-Mail: stephan.behnke@gmx.net

 #Liste der Buchstaben
 set letters { a b c d e f g h i j k l m n o p q r s t u v w x y z }

 #Liste der Zahlen in Wörtern
 set numbers { null eins zwei drei vier fuenf sechs sieben acht neun }

 set abweichung 4

#===============================
#Prozedur zum Öffnen einer Datei
#===============================
proc openFile {} {

 #Pfad ermitteln
 set pfad [tk_getOpenFile]

 #Fehlerkontrolle
 if { $pfad == "" } { return }

 #Inhalt des Textfeldes löschen
 .mitte.text delete 1.0 end

 #Datei einlesen
 set stream  [open $pfad r]

 #Datei auslesen
 set text [read $stream]

 #Inhalt ausgeben
 .mitte.text insert end $text

 #Kanal schließen
 close $stream

 #Eingabefelder etc. konfigurieren
 .unten.2.key configure -text ""
 .unten.1.hack configure -state normal
 .unten.1.quote configure -state normal -bg white

 #Variabeln löschen
 unset stream
 unset pfad
 unset text

}

#==================================
#Prozedur zum Speichern einer Datei
#==================================
proc saveFile {} {

 #Pfad einlesen
 set pfad [tk_getSaveFile]

 #Fehlerkontrolle
 if { $pfad == "" } { return }

 #Daten in String einlesen
 set data [.mitte.text get 1.0 end]

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

#======================================================
#Prozedur zum Vorbereiten (fürs Codieren) eines Strings
#======================================================
proc vorbereiten {String} {
global letters numbers

 #Status ausgeben
 .unten.2.key configure -text "Text für Analyse formatieren"
 update

 #Alle Buchstaben auf Kleinbuchstaben setzen
 set String [ string tolower $String 0 end ]

 #Absätze, Tabulatoren und Leerzeichen entfernen
 regsub -all "\t" $String "" String
 regsub -all "\n" $String "" String
 regsub -all " " $String "" String

 #Umlaute ersetzen
 regsub -all "ü" $String "ue" String
 regsub -all "ä" $String "ae" String
 regsub -all "ö" $String "oe" String

 #Das ß durch ss ersetzen
 regsub -all "ß" $String "ss" String

 #Zahlen durch Wörter ersetzen
 for { set i 0 } { $i < 10 } { incr i } {
	regsub -all "$i" $String  "[lindex $numbers $i]" String
 }

 set temp ""

 #Alle Zeichen außer Buchstaben entfernen
 for { set i 0 } { $i < [string length $String] } { incr i } {
	foreach buchstabe $letters {
		if { [string index $String $i] == $buchstabe } {
			append temp [string index $String $i]
		}
	}
 }

 #String übergeben
 set String $temp
 unset temp

 return $String

}

#=====================================
#Prozedur zum Ermitteln des Schlüssels
#=====================================
proc knacken {} {
global letters abbruch abweichung

 #Eingabefelder etc. sperren
 .unten.1.hack configure -state disable
 .unten.1.quote configure -state disable -bg gray

 #String fürs Analysieren vorbereiten
 set text [vorbereiten [.mitte.text get 1.0 end]]

 set keylength 1

 while {!$abbruch} {

	set textlaenge [expr int([string length $text]/$keylength)]
	set haeufigkeit 0
	incr keylength

 	#Liste vorbereiten
	set haeufig {}
	for {set j 0} {$j < 26} {incr j} {
		lappend haeufig 0
	}

	#Schleife durch den String
 	for {set j 0} {[expr $j+$keylength] < $textlaenge} {incr j $keylength} {
 		set index [expr [lsearch $letters [string index $text $j]]]
 		set haeufig [lreplace $haeufig $index $index [expr [lindex $haeufig $index]+1]]
 	}

 	#Sortieren
	set sort [lsort -integer -decreasing $haeufig]

 	#Prozent ausrechnen
        set haeufigkeit [expr double((100*[lindex $sort 0].0)/($textlaenge.0/$keylength.0))]

	#Status ausgeben
	.unten.2.key configure -text "Probiere Schlüssellänge: $keylength -> [expr int($haeufigkeit)]% Häufigkeit"
	update

        #Schlüssellänge kontrollieren
        if {[expr double(17.4 - $haeufigkeit)] > $abweichung} {
        	continue
        }

        #Schlüssellängen durchgehen
 	for {set i 0} {$i < $keylength} {incr i} {

 		#Liste vorbereiten
		set haeufig {}
		for {set j 0} {$j < [llength $letters]} {incr j} {
			lappend haeufig 0
		}

		#Schleife durch den String
 		for {set j $i} {[expr $j+$keylength] < [string length $text]} {incr j $keylength} {
 			set index [lsearch $letters [string index $text $j]]
 			set haeufig [lreplace $haeufig $index $index [expr [lindex $haeufig $index]+1]]
 		}

		#Verschiebung errechnen
		set sort [lsort -integer -decreasing $haeufig]
	 	lappend ver [expr ([lsearch $haeufig [lindex $sort 0]]-[lsearch $letters "e"])%[llength $letters]]
	}

 	#Ausgeben
 	.unten.2.key configure -text "Entschlüsseln läuft..."
 	update
 	codieren $text $ver
 	.unten.2.key configure -text "Schlüssel: [join $ver]"
 	update

 	if {!$abbruch} {
 		#Richtigkeit erfragen
 		if {![tk_dialog .frage "Erfolg?!" "Ist der Text entschlüsselt?" question 0 "Ja" "Nein"]} {
        		catch [destroy .frage]
        		break
       		} else {
            		catch [destroy .frage]
            		.mitte.text delete 1.0 end
            		.mitte.text insert end [split $text {}]
 		}
 	}
 }

 #Eingabefelder etc. konfigurieren
 .unten.1.hack configure -state normal
 .unten.1.quote configure -state normal -bg white

}

#====================================
#Prozedur zum Entschlüsseln der Datei
#====================================
proc codieren { text schluessel } {

 #Fehlerkontrolle
 if { $schluessel == "" } { return }

 #Text codieren und ausgeben
 .mitte.text delete 1.0 end
 .mitte.text insert end [caesar $schluessel $text]

 #Variabeln löschen
 unset schluessel
 unset text

}

#===============
#Prozedur Caesar
#===============
proc caesar { verschieben zeichen}  {
global letters numbers

 #Schlüssel als Liste schreiben
 set schluessel [split $verschieben]

 set krypt ""

 #Schleife durch den String
 for { set i 0 } { $i < [string length $zeichen] } { incr i } {

	#Zeichen suchen
	set pos [lsearch $letters [string index $zeichen $i]]

	#Neues Zeichen setzen
	set neu [expr $pos - [lindex $schluessel [expr $i % [llength $schluessel]]]]

	#Zeichen kontrollieren
	set neu [expr $neu % [llength $letters]]

	#Zeichen schreiben
	append krypt "[lindex $letters $neu ] "

 }

 #Variabeln löschen
 catch [unset neu]
 catch [unset pos]
 unset verschieben
 unset schluessel
 unset zeichen
 unset i

 return $krypt

}

#======
#Frames
#======
 frame .oben
 frame .mitte
 frame .unten
 frame .unten.1
 frame .unten.2

#====
#Menu
#====
 menubutton .oben.datei -text "Datei" -menu .oben.datei.m
 menu .oben.datei.m -tearoff 0

 .oben.datei.m add command -label "Öffnen" -command "openFile"
 .oben.datei.m add command -label "Speichern Unter" -command "saveFile"
 .oben.datei.m add command -label "Beenden" -command exit

#=====
#Label
#=====
 label .unten.2.key -text "Verschlüsselten Text laden" -relief sunken -width 70
 label .unten.1.lquote -text "Max. Abweichung der Häufigkeit:"
 label .unten.1.prozent -text "%"

#=====
#Entry
#=====
 entry .unten.1.quote -textvariable abweichung -width 2

#====
#Text
#====
 text .mitte.text	-bg white -relief sunken \
			-yscrollcommand {.mitte.scrolly set } \
			-wrap word -width 70 -height 30

#=========
#Scrollbar
#=========
 scrollbar .mitte.scrolly -orient vertical -command ".mitte.text yview"

#======
#Button
#======
 button .unten.1.hack -text "Schlüssel ermitteln!" -command { set abbruch 0; knacken }
 button .unten.1.stop -text "Stop!" -command { set abbruch 1 }

#========
#Bindings
#========
 bind . <Control-o> "openFile"
 bind . <Control-s> "saveFile"

#======
#Packen
#======
 pack .oben -fill x
 pack .oben.datei -side left
 pack .mitte -expand true -fill both
 pack .unten -fill x

 pack .mitte.text -side left -fill both -expand true
 pack .mitte.scrolly  -side right -fill y

 pack .unten.1 -in .unten
 pack .unten.2 -in .unten -fill x

 pack .unten.1.hack -side left -padx 5 -pady 5
 pack .unten.1.stop -side left -padx 5 -pady 5
 pack .unten.1.lquote .unten.1.quote .unten.1.prozent -pady 5 -side left
 pack .unten.2.key -pady 5 -fill x

 wm title . "Polyalphabetische Cäsar Verschlüsselung knacken"

# © ® Stephan Behnke ™
