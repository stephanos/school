# © ® Stephan Behnke ™
# Homepage: www.tcltk.de.vu
# E-Mail: stephan.behnke@gmx.net

proc save {filename text} {

 #Datenstrom erstellen
 set stream [open $filename w 0755]

 #String in Datei schreiben
 puts -nonewline $stream $text

 #Datenstrom schließen
 flush $stream
 close $stream
}

proc einlesen {pfad einrueck} {

	global dir src

	cd $pfad

   	set files [glob -nocomplain *]
   	set text ""
   	regsub $src $pfad "" v
	
	set einrueck1 $einrueck
	append einrueck "  "

   	foreach f $files {
  		if {[file isdirectory "$pfad/$f"]} {
			append text $einrueck1
			append text ">"
			append text $f
			append text "\n"
			append text [einlesen "$pfad/$f" $einrueck]
  		} else {
			append text $einrueck
			append text [string range $f 0 [expr [string length $f]-1]]
			append text "\n"
		}
   	}

	return $text
}

# Verzeichniss
set src [lindex $argv 0]

set text [einlesen $src ""]
save "$src/files.txt" $text
exit

# © ® Stephan Behnke ™