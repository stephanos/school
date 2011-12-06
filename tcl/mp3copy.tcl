# Programm zum automatischen editieren der MP3-Namen

proc kopieren {pfad} {

	global src dest

	cd $pfad

   	set files [glob -nocomplain *]
	regsub $src $pfad "" v

   	foreach f $files {

		set file "$pfad/$f"

  		if {[file isdirectory $file]} {
			if {[string index $f 0] == "-"} {
				set f [string range $f 1 [expr [string length $f] - 1]]
				file mkdir "$dest$v"
				file copy "$file" "$dest$v/$f"
			} elseif {[string index $f 0] == "+"} {

			} else {
				kopieren $file
			}
    		}
   	}
}


  # Verzeichniss
  set src  [tk_chooseDirectory -initialdir D:/]
  set dest "D:/Files/Music"

  # MP3s kopieren
  kopieren $src

  # Beenden
  exit

  # � � Stephan Behnke �