# Programm zum automatischen editieren der MP3-Namen

proc einlesen {pfad} {

	global dir src

	cd $pfad

   	set files [glob -nocomplain *]
   	set songs []
   	regsub $src $pfad "" v

   	foreach f $files {
  		if {[file isdirectory "$pfad/$f"]} {
			if {[string index $f 0] == "+" || [string index $f 0] == "-"} {
				lappend songs [string range $f 1 [expr [string length $f]-1]]
			} else {
				set songs [concat $songs [einlesen "$pfad/$f"]]
			}
  		}
   	}

	return $songs
}

    # Verzeichniss
    set src  [tk_chooseDirectory -initialdir D:/]
    cd $src

    set files [glob -nocomplain *]
    set songs []

    foreach f $files {
  	if {[file isdirectory "$src$f"]} {
	
		regsub $src "$src$f" "" v
		lappend songs "\n$v:"
		set songs [concat $songs [lsort [einlesen "$src$f"]]]
	}
    }

    set str ""

    foreach s $songs {
	append str "$s\n"
    }

	console show
	puts $str
  # � � Stephan Behnke �