#Programm zum Entschlüsseln von Dateien
# © ® Stephan Behnke ™

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
 .unten.key configure -text ""
 .unten.hack configure -state normal

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

#=========================================
#Prozedur zum Ermitteln der Schlüssellänge
#=========================================
proc friedman {text} {
global letters

 set haeufig {}

 #Liste definieren
 for {set i 0} {$i < [llength $letters]} {incr i} {
 	lappend haeufig 0
 }

 #Schleife bis an String-Ende
 for {set i 0} {$i < [string length $text]} {incr i} {
 	set index [lsearch $letters [string index $text $i]]
 	set haeufig [lreplace $haeufig $index $index [expr [lindex $haeufig $index]+1]]
 }

 set summe 0

 #Summe errechnen (ni*(ni-1))
 for {set i 0} {$i < [llength $letters]} {incr i} {
 	incr summe [expr [lindex $haeufig $i]*([lindex $haeufig $i]-1)]
 }

 #Koinzidenzindex berechnen
 set K [expr double($summe.0/([string length $text].0*[expr [string length $text]-1].0))]
 set L [expr double((0.0377*[string length $text])/([expr [string length $text]-1]*$K-(0.0385*[string length $text])+0.0762))]

 #Variabeln löschen
 unset text
 unset K
 unset i

 puts "Schlüssellänge: $L"
 set L [expr round($L)]
 return $L

}

#=====================================
#Prozedur zum Ermitteln des Schlüssels
#=====================================
proc knacken {} {
global letters

 #Eingabefelder etc. sperren
 .unten.hack configure -state disable

 #Status ausgeben
 update
 .unten.key configure -text "Errechne Schlüssellänge"
 update

 #String fürs Analysieren vorbereiten
 set text [vorbereiten [.mitte.text get 1.0 end]]

 set loesung 0
 set ver ""

 #Schlüssellänge bestimmen
 set keylength [friedman $text]

 #Liste vorbereiten
 set haeufig {}
 for {set i 0} {$i < $keylength} {incr i} {
 	lappend haeufig 0
 }

 #Status ausgeben
 update
 .unten.key configure -text "Ermittelte Schlüssellänge: $keylength"
 update

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
	append ver [lindex $letters [expr ([lsearch $haeufig [lindex $sort 0]]-[lsearch $letters "e"])%[llength $letters]]]
 }

 #Ausgeben
 update
 .unten.key configure -text "Entschlüsseln läuft..."
 update
 codieren $text $ver
 .unten.key configure -text "Schlüssel: $ver"
 update

 #Eingabefelder etc. konfigurieren
 .unten.hack configure -state normal

}

#====================================
#Prozedur zum Entschlüsseln der Datei
#====================================
proc codieren { text schluessel } {

 #Fehlerkontrolle
 if { $schluessel == "" } { return }

 #Text codieren und ausgeben
 .mitte.text delete 1.0 end
 .mitte.text insert end [vigenere $schluessel $text]

 #Variabeln löschen
 unset schluessel
 unset text

}

#=================
#Prozedur Vigenere
#=================
proc vigenere { verschieben zeichen}  {
global letters numbers

 #Alle Buchstaben auf Kleinbuchstaben setzen
 set verschieben [vorbereiten $verschieben]
 set zeichen [vorbereiten $zeichen]

 #Schlüssel als Liste schreiben
 set schluessel [split $verschieben {}]

 set krypt ""

 #Schleife durch den String
 for { set i 0 } { $i < [string length $zeichen] } { incr i } {

	#Zeichen suchen
	set pos [lsearch $letters [string index $zeichen $i]]

	#Neues Zeichen setzen
	set neu [expr $pos - [lsearch $letters [lindex $schluessel [expr $i % [llength $schluessel]]]]]

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
 label .unten.key -text "Verschlüsselten Text laden" -relief sunken -width 70

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
 button .unten.hack -text "Schlüssel ermitteln!" -command { set abbruch 0; knacken }

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

 pack .unten.hack -padx 5 -pady 5
 pack .unten.key -pady 5 -fill x

 wm title . "Vigenere Verschlüsselung mit Friedman Test knacken"

# © ® Stephan Behnke ™


