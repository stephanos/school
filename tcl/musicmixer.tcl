# Programm zum automatischen Erstellen einer zufälligen Musikabfolge
# © ® Stephan Behnke ™
# Homepage: www.tcltk.de.vu
# E-Mail: stephan.behnke@gmx.net

proc getSongs {pfad selected} {

	global dir src

	cd $pfad

   	set files [glob -nocomplain *]
   	set songs ""
   	regsub $src $pfad "" v

   	foreach f $files {
   		if {[file isdirectory "$pfad/$f"]} {
   			if {![isBand $f] || [lsearch -exact $selected "Zufall"] != -1 || [lsearch -exact $selected [string range "$f" 1 [string length $f]]] != -1} {
  				append songs [getSongs "$pfad/$f" $selected]
  			}
  		} else {
  			if {[regexp ".mp3" $f] || [regexp ".ogg" $f] || [regexp ".wav" $f] || [regexp ".wma" $f]} {
  				append songs "$v/$f"
  				append songs "?"
  			}
  		}

  		update
   	}

   	return $songs
}


proc isBand {name} {

	if {[string index $name 0]=="-" || [string index $name 0]=="+"} {
		return 1
	}

   	return 0
}


proc getBands {pfad} {

	global dir src

	cd $pfad

   	set files [glob -nocomplain *]
   	set bands ""
   	regsub $src $pfad "" v

   	foreach f $files {
   		if {[file isdirectory "$pfad/$f"]} {
  			if {[isBand "$f"]} {
  				append bands [string range "$f" 1 [string length $f]]
  				append bands "?"
  			} else {
                		append bands [getBands "$pfad/$f"]
                	}
  		}
  	}

   	return $bands
}


proc kopieren {selected} {

	global dir src

	#Ziel abfragen
	set dest [tk_chooseDirectory -initialdir D:/]

	set widgets [winfo children .]
	foreach element $widgets {destroy $element}

    	label .l1 -width 50 -text "Löschen der Musikdateien ..."
    	label .l2 -width 50
    	pack  .l1 .l2 -expand true -fill both
	update;

	# MP3s löschen
	cd $dest
 	set songs [glob -nocomplain *.mp3]
 	foreach s $songs { 	 
		 #file delete -force "$s"
 	}

	label .l1 -width 50 -text "Suche Musikdateien ..."

    	# Musikstücke suchen
    	set songs [split [getSongs $src $selected] "?"]

    	# Anzahl der Songs
    	set anzahl [llength $songs]

    	# Liste für benutzte MP3s erstellen
    	set used {}

    	# Größe der Auswahl
    	set size 0

    	set max 1043169280

    	catch {
		# MP3s auswählen
    	 	while {$size < $max} {

			.l2 config -text "[expr int(($size/$max.0)*100)] %"
			update

			# Song auswählen
			set song [lindex $songs [expr int(($anzahl-1)*rand())]]

			# Schon benutzt?
			if {[lsearch $used $song]==-1} {

				set name [split $song "/"]
				set dir "-Sonstiges"
				set i 0;
				for {set i 0} {$i<[expr [llength $name]]} {incr i} {
					if {[isBand [lindex $name $i]] == 1} {
						set dir [lindex $name $i]
						break;
					}
				}

				.l1 config -text "Kopiere \"[file tail $song]\""

				if {[file isdirectory "$dest$dir"] == 0} {
					file mkdir "$dest$dir"
				}

				# Kopieren
				file copy -force "$src$song" "$dest$dir/[file tail $song]"

    				# Größe dazu addieren
      	      	incr size [file size "$src$song"]

            		lappend used $song
	    		}

			# Abbruch?
	    		if {[llength $songs] == [llength $used]} {
                        exit
	    		}
	 	}
	}

	# Beenden
  	unset songs
  	exit
}

 #Fenster
 pack [frame .main]
 pack [frame .main.oben]  -in .main
 pack [frame .main.unten] -in .main

 # Verzeichnisse
 set src  [tk_chooseDirectory -initialdir D:/]
 set dir  ""

 # Verzeichnis wechseln
 cd $src

 # Bands abfragen
 set bands [lsort -dictionary [split [getBands $src] "?"]]

 set Ymax [expr 2*round([expr sqrt([llength $bands])])]
 set j 0
 for {set i 0} {$i < [llength $bands]} {incr i} {
 	if {$i % $Ymax == 0} {
 		incr j
 		pack [frame ".main.oben.$j"] -side left -fill both -in .main.oben
 	}

	pack [checkbutton .main.oben.$j.$i -text "[lindex $bands $i]" -variable [lindex $bands $i]] -anchor w
 }
 pack [checkbutton .main.oben.$j.$i -text "Zufall" -variable "Zufall"] -anchor w

 wm title . "Gewünschte Bands auswählen"
 wm resizable . no no

 # Button
 button .main.unten.b -text "Erstellen!" -command {

	set selected {}

 	set frames [winfo children .main.oben]
 	foreach f $frames {
		set cbuttons [winfo children $f]
		foreach b $cbuttons {
			if {[set z [set [$b cget -variable]]]} {
				lappend selected [$b cget -text]
			}
		}
 	}

 	kopieren $selected
 }
 pack .main.unten.b -pady 5


 # © ® Stephan Behnke ™