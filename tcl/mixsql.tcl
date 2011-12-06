proc getPfad {} {

 #Pfad ermitteln
 set pfad [tk_getOpenFile]

 #Fehlerkontrolle
 if { $pfad == "" } { return }

 return $pfad
}

proc openFile {pfad} {

 #Datei einlesen
 set stream [open $pfad r]

 #Datei auslesen
 set text [read $stream]

 #Kanal schließen
 close $stream

 #Variabeln löschen
 unset pfad
 unset stream

 return $text
}

proc saveFile {data pfad} {

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

proc edit {data} {

   set data [split $data "\n"]
   set neu ""

   for {set i 0} {$i<[llength $data]} {incr i} {

	set part [lindex $data $i]

	#Schüler
   	if {[regexp {apm_schueler VALUES} $part]} {

		regsub {\)} $part "" part
		regsub ";" $part "" part
		regsub {INSERT INTO apm_schueler VALUES \(} $part "" part
		regsub -all " " $part "" part

                set str "'abc$i'"

		set k 0
		set _part ""
		for {set j 0} {$j<[string length $part]} {incr j} {

		        set s [string index $part $j]

			if {$s == "'"} {
				if {$k == 1} {
					set k 0
				} else {
					set k 1
				}

				append _part $s

			} elseif {$s == ","} {
				if {$k == 0} {
					append _part $s
				}
			} else {
				append _part $s
			}

		}
		set part $_part

   		set eintrag [split $part ","]

		#Namen ersetzen
		set eintrag [lreplace $eintrag 1 1 $str]
		set eintrag [lreplace $eintrag 2 2 $str]
		set eintrag [lreplace $eintrag 11 11 $str]
		set eintrag [lreplace $eintrag 12 12 $str]
		set eintrag [lreplace $eintrag 13 13 $str]
		set eintrag [lreplace $eintrag 14 14 $str]
		set eintrag [lreplace $eintrag 15 15 $str]
		set eintrag [lreplace $eintrag 22 22 $str]

		#Adresse ersetzen
		set eintrag [lreplace $eintrag 7 7   $str]
		set eintrag [lreplace $eintrag 8 8   $str]
		set eintrag [lreplace $eintrag 10 10 $str]
		set eintrag [lreplace $eintrag 22 22 $str]
		set eintrag [lreplace $eintrag 15 15 $str]

		#Telefonnummer
		set eintrag [lreplace $eintrag 16 16 $str]
		set eintrag [lreplace $eintrag 23 23 $str]

		#Eintrag updaten
		set eintrag [join $eintrag]
		regsub -all " " $eintrag "," eintrag
		set eintrag "INSERT INTO apm_schueler VALUES ($eintrag);"

		append neu $eintrag

   	#Lehrer
   	} elseif {[regexp {apm_lehrer VALUES} $part]} {

		regsub {\)} $part "" part
		regsub ";" $part "" part
		regsub {INSERT INTO apm_lehrer VALUES \(} $part "" part

		set eintrag [split $part ","]

                set str "'abc$i'"

                #Datum ändern
               	set eintrag [lreplace $eintrag 3 3 "'2005-01-01'"]

               	#Ort ändern
 		set eintrag [lreplace $eintrag 4 4 $str]
 		set eintrag [lreplace $eintrag 5 5 "0"]
 		set eintrag [lreplace $eintrag 6 6 $str]

 		#Eintrag updaten
		set eintrag [join $eintrag]
		regsub -all " " $eintrag "," eintrag
		set eintrag "INSERT INTO apm_lehrer VALUES ($eintrag);"

		append neu $eintrag

	} elseif {[regexp -- {^--} [lindex $data $i]]} {

   	} else {
   		append neu [lindex $data $i]
   	}

   	append neu "\n"
   }

   return $neu
}

#Pfad ermitteln
if {$argv != ""} {
	set pfad $argv
} else {
	set pfad [getPfad]

	if {$pfad == ""} {
		puts "Kein Pfad angegeben!"
		exit
	}
}

#Text holen
set text [openFile $pfad]

regsub ".sql" $pfad "_edited.sql" pfad

if {$text != ""} {
	saveFile [edit $text] $pfad
	puts "Datei geändert"
} else {
	puts "Datei konnte nicht geladen werden!"
}

exit
