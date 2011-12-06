# Programm zum automatischen editieren der MP3-Namen

proc einlesen {pfad} {

	global dir src

	cd $pfad

   	set files [glob -nocomplain *]
   	set songs ""
   	regsub $src $pfad "" v

   	foreach f $files {
  		if {[file isdirectory "$pfad/$f"]} {
			append songs [einlesen "$pfad/$f"]
  			update
  		} else {
  			append songs "$v/$f"
  			append songs "?"
  		}
   	}

   	return $songs
}

    # Verzeichniss
    set src [tk_chooseDirectory -initialdir D:/]
    cd $src

    set id "X"

    label .l1 -width 50 -text "Bearbeiten der Musikdateien"
    label .l2 -width 50
    pack  .l1 .l2 -expand true -fill both

    # Musikst�cke suchen
    set songs [split [einlesen $src] "?"]

    # Anzahl der Songs
    set anzahl [llength $songs]

	# MP3s bearbeiten
	for {set i 0} {$i < $anzahl} {incr i} {

  		.l2 config -text "[expr int(($i/$anzahl.0)*100)] %"
	  	update

      		set song [lindex $songs $i]

		set ordner [file dirname $song]

      		set name [file tail $song]
      		set old  $name


			#regsub -- "Dresden Tolls" $name "Dresden Dolls" name
			#regsub -- "\\.rzte" $name " �rzte" name


      		set name [string tolower $name]

      		regsub -all "_" $name " " name

      		if {[regexp -- {-+ [0-9]+ -+} $name str] || [regexp -- { -+ [0-9]+ -+ } $name str]} {
      			regsub -- $str $name " - " name
      		}

      		regsub -- "-" $name " - " name

      		while {[regsub -all "  " $name " " name]} {}

		regsub -all "\\)" $name " )" name
		regsub -all "\\(" $name "( " name

		set name [split $name " "]

      		for {set j 0} {$j < [llength $name]} {incr j} {
      			set str   [lindex $name $j]
      			set first [string index $str 0]
      			set str   "[string toupper $first][string range $str 1 [string length $str]]"
      			set name  [lreplace $name $j $j $str]
      		}

      		regsub -all "\\( " $name "(" name
		regsub -all " \\)" $name ")" name

		set name [join $name]

		if {[regexp ".mp3" $name] && $name != $old} {
			file rename -force "$src$song" "$src$ordner/$name$id"
			file rename -force "$src$ordner/$name$id" "$src$ordner/$name"
		}
	}

  # Beenden
  unset songs
  exit

  # � � Stephan Behnke �