#Programm zum Veranschaulichen eines Wegsuche-Algorithmuses (A*)

set felder 18
set aktion "S"
set ausgabe "g"

#============================
#Prozedur f�r eine neue Karte
#============================
proc new {} {
global feld felder aktion ziel size start ausgabe felder

 #Anzeige
 .menuleiste.aktuell config -text "Level durch Hindernisse gestalten und Figur von Start zum Ziel schicken"

 #Feld anpassen
 feld

 #Variabeln
 set feld {}
 set start {1 1}
 set ziel [list [expr $felder-2] [expr $felder-2]]

 #Alles mit 1en f�llen
 for {set i 0} {$i < [expr $felder*$felder]} {incr i} {
       lappend feld 1
 }

 #Leerraum bestimmen
 for {set i $felder} {$i<[expr ($felder*$felder)-$felder]} {incr i} {
 	if {[expr $i%$felder]!=0 && [expr $i%$felder]!=[expr $felder-1]} {
 		set feld [lreplace $feld $i $i 0]
 	}
 }

 #Neuzeichnen
 draw

}

#======================================
#Prozedur um Eingabe ein-/auszuschalten
#======================================
proc bindings {value} {
global aktion ziel

 if {$value} {
 	.oben.datei configure -state normal
 	.links.b configure -state normal
 	.links.ok configure -state normal
	bind .rechts.c <Button-1> {
		if {$aktion=="hinderniss"} {
			object %x %y 1 1
		} else {
                	setzen %x %y $aktion
		}
	}
 	bind .rechts.c <Button-3> {if {$aktion=="hinderniss"} {object %x %y 0 1}}
 	bind . <Control-n> {new}
 	bind . <Control-s> {saveFile}
 	bind . <Control-l> {openFile}
	bind . <Control-o> {openFile}
	bind . <Return> {a}

 } else {
 	.oben.datei configure -state disable
 	.links.b configure -state disable
 	.links.ok configure -state disable
        bind .rechts.c <Button-1> {}
 	bind .rechts.c <Button-3> {}
 	bind . <Control-n> {}
 	bind . <Control-s> {}
 	bind . <Control-l> {}
	bind . <Control-o> {}
	bind . <Return> {}
 }

}

#==========================================
#Prozedur um Hinderniss zu setzen/entfernen
#==========================================
proc object {x y setzen delete} {
global feld felder size ziel start

  if {$delete} {
  	catch [.rechts.c delete linie]
  	catch [.rechts.c delete l]
  }

  #Anzeige
 .menuleiste.aktuell config -text "Level durch Hindernisse gestalten und Figur von Start zum Ziel schicken"

  #Farbe
  set color "beige"
  if {$setzen} {set color "white"}

  #Koordinaten anpassen
  set x [expr int($x/$size)*$size]
  set y [expr int($y/$size)*$size]

  #Umrechnen
  set xy [list [expr int($x/$size)] [expr int($y/$size)]]

  #Pr�fen
  set pos [expr [lindex $xy 0]+([lindex $xy 1]*$felder)]
  if {[lindex $feld $pos] == 2} {return 0}
  if {[lindex $xy 0]<=0 || [lindex $xy 0]>=[expr $felder-1]} {return 0}
  if {[lindex $xy 1]<=0 || [lindex $xy 1]>=[expr $felder-1]} {return 0}
  if {[lindex $ziel 0]==[lindex $xy 0] && [lindex $ziel 1]==[lindex $xy 1]} {return 0}
  if {[lindex $start 0]==[lindex $xy 0] && [lindex $start 1]==[lindex $xy 1]} {return 0}

  #Zeichnen
  .rechts.c create rectangle $x $y [expr $x+$size] [expr $y+$size] -fill $color

  #Liste
  set feld [lreplace $feld $pos $pos $setzen]

}

#==========================================
#Prozedur um neues Ziel f�r Figur zu setzen
#==========================================
proc setzen {x y text} {
global ziel size feld felder start

  #Anzeige
 .menuleiste.aktuell config -text "Level durch Hindernisse gestalten und Figur von Start zum Ziel schicken"

  #Koordinaten anpassen
  set x [expr int($x/$size)*$size]
  set y [expr int($y/$size)*$size]

  #Umrechnen
  set xy [list [expr int($x/$size)] [expr int($y/$size)]]

  #Pr�fen
  set pos [expr [lindex $xy 0]+([lindex $xy 1]*$felder)]
  if {[lindex $feld $pos]==1} {return 0}
  if {[lindex $start 0]==[lindex $xy 0] && [lindex $start 1]==[lindex $xy 1]} {return 0}

  #Fallunterscheidung Start/Ziel
  if {$text=="Z"} {
  	set ziel [list [lindex $xy 0] [lindex $xy 1]]
  } else {
  	set start [list [lindex $xy 0] [lindex $xy 1]]
  }

  #Zeichnen
  catch [.rechts.c delete ende]
  catch [.rechts.c delete l]
  .rechts.c create text [expr [lindex $ziel 0]*$size+$size/2] [expr [lindex $ziel 1]*$size+$size/2] -text Z -fill red -tags ende
  .rechts.c create text [expr [lindex $start 0]*$size+$size/2] [expr [lindex $start 1]*$size+$size/2] -text S -fill darkgreen -tags ende

}

#=============================
#Prozedur um den Weg zu suchen
#=============================
proc a {} {
global start ziel felder feld size langsam ausgabe

 catch [.rechts.c delete linie]
 catch [.rechts.c delete l]

 #Bindings ausschalten
 bindings 0

 #Zeit nehmen
 set zeit [clock clicks]

 #Hinweis ausgeben
 .menuleiste.aktuell config -text "Weg wird berechnet..."

 #Listen initialisieren
 set Parents {}
 set ClosedList {}
 set OpenList [list [lindex $start 0] [lindex $start 1] 0 0]

 #Schleife bis Ziel
 while {[llength $OpenList]} {

        #BestNode finden
        set BestNode {}
        for {set i 0; set j 0; set least [expr $felder*$felder*$felder]} {$i<[llength $OpenList]} {incr i 4} {
        	set f [expr [lindex $OpenList [expr $i+2]]+[lindex $OpenList [expr $i+3]]]
                if {$f<$least} {
                	set BestNode [lrange $OpenList $i [expr $i+3]]
                        set least $f
                        set j $i
                }
        }

        #BestNode aus OpenList entfernen
        set OpenList [concat [lrange $OpenList 0 [expr $j-1]] [lrange $OpenList [expr $j+4] [expr [llength $OpenList]-1]]]

	#BestNode zur ClosedList hinzuf�gen
        set ClosedList [concat $ClosedList $BestNode]

        #Die N�chsten Punkte ausmachen (sternf�rmig)
        set pos [expr [lindex $BestNode 0]+([lindex $BestNode 1]*$felder)]
        for {set i -1} {$i<2} {incr i} {
        	for {set j -1} {$j<2} {incr j} {

			set punkt [expr $pos+$j+($i*$felder)]

                        #Wenn Punkt keine Wand & nicht BestNode ist
                        if {[lindex $feld $punkt]!=1 && ($j || $i)} {

				set temp {}

                        	#X & Y berechnen
                        	set x [expr [lindex $BestNode 0]+$j]
                        	set y [expr [lindex $BestNode 1]+$i]
                        	lappend temp $x $y

                        	#Eck-K�stchen-�berschreitungen ausschlie�en
                                if {$j && $i} {

					#Positionen bestimmen
                                        set xx [expr [lindex $BestNode 0]-$x]
                                        set yy [expr [lindex $BestNode 1]-$y]

                                        #Pr�fen
                                        if {[lindex $feld [expr $punkt+$xx]] || [lindex $feld [expr $punkt+$yy*$felder]]} {
                                        	continue
                                        }
                                }

                        	#g berechnen
				if {$j && $i} {set plus 14} else {set plus 10}
				incr plus [expr 10*[lindex $feld $punkt]]
                        	lappend temp [expr [lindex $BestNode 2]+$plus]

                                #Wenn der Punkt in OpenList ist...
				if {[g $x $y $OpenList]!=-1} {

                                	#Besserer Weg?
                                        if {[g $x $y $OpenList] > [lindex $temp 2]} {
                                        	set Parents [updaten $x $y $BestNode $Parents]
                                        	set OpenList [change_g $x $y [lindex $temp 2] $OpenList]
                                        }

                                #Wenn der Punkt in ClosedList ist...
                        	} elseif {[g $x $y $ClosedList]!=-1} {

                                        #Besserer Weg?
                                        if {[g $x $y $ClosedList] > [lindex $temp 2]} {
						set Parents [updaten $x $y $BestNode $Parents]
						set ClosedList [change_g $x $y [lindex $temp 2] $ClosedList]
                                        }

                                #Wenn der Punkt auf keiner Liste ist...
                                } else {

					#h berechnen
                        		lappend temp [expr 10*(abs($x-[lindex $ziel 0])+abs($y-[lindex $ziel 1]))]

                                        #Zu OpenList hinzuf�gen
                        		set OpenList [concat $OpenList $temp]

                                        #Parent definieren
                                        set Parents [concat $Parents [list [lindex $BestNode 0] [lindex $BestNode 1] $x $y]]
                                }
                        }
        	}
        }

        #Am Ziel?
	if {[lrange $BestNode 0 1]==$ziel} {break}
	if {$langsam && $ausgabe!="k"} {numbers $ClosedList $OpenList; after 50}
        update
 }

 #Gefunden?
 if {![llength $OpenList]} {

 	#Anzeige
 	.menuleiste.aktuell config -text "Der Weg konnte leider nicht berechnet werden."

 } else {

	#Zeit errechnen
	set string [expr ([clock clicks]-$zeit)/1000]
        if {$string>1000} {
        	set string "[expr round($string/1000)] Sekunden"
        } else {
        	append string " Millisekunden"
        }

 	#Anzeige
 	catch [.rechts.c delete l]
 	numbers $ClosedList $OpenList
 	set schritte [linie $Parents]
 	if {$schritte==1} {set schritte "einem Schritt"} else { append schritte " Schritten"}
 	.menuleiste.aktuell config -text "Das Ziel konnte mit $schritte erreicht werden! Berechnungsdauer: $string"
 }

 #Bindings anschalten
 bindings 1

}

#================================
#Prozedur zum Updaten von Parents
#================================
proc updaten {x y BestNode Parents} {

 #Parent �ndern
 for {set i 0} {$i<[llength $Parents]} {incr i 4} {
       	if {[lindex $Parents [expr $i+2]]==$x && [lindex $Parents [expr $i+3]]==$y} {
        	set Parents [lreplace $Parents $i $i [lindex $BestNode 0]]
                set Parents [lreplace $Parents [expr $i+1] [expr $i+1] [lindex $BestNode 1]]
                break
       }
 }

 return $Parents

}

#=================================
#Prozedur um den g-Wert anzupassen
#=================================
proc change_g {x y g liste} {

 #g-Wert suchen
 for {set i 0} {$i<[llength $liste]} {incr i 4} {
 	if {[lindex $liste $i]==$x && [lindex $liste [expr $i+1]]==$y} {
                set liste [lreplace $liste [expr $i+2] [expr $i+2] $g]
                return $liste
 	}
 }

}

#================================
#Prozedur um Zahlen einzuzeichnen
#================================
proc numbers {liste1 liste2} {
global size ziel start ausgabe

 #Ausgabe anpassen
 set g 0; set h 0
 if {$ausgabe=="k"} {
 	return 0
 } elseif {$ausgabe=="g"} {
 	set g 1
 } elseif {$ausgabe=="h"} {
        set h 1
 } else {
        set g 1; set h 1
 }

 #Zeichnen
 for {set j 0} {$j<2} {incr j} {

 	if {!$j} {set liste $liste2} else {set liste $liste1}

 	for {set i 0} {$i<[llength $liste]} {incr i 4} {

 		#Farbe
                set color lightblue
                if {$j} {set color blue}

 		#Start/Ziel
 		if {[lindex $liste $i]==[lindex $start 0] && [lindex $liste [expr $i+1]]==[lindex $start 1]} {continue}
 		if {[lindex $liste $i]==[lindex $ziel 0] && [lindex $liste [expr $i+1]]==[lindex $ziel 1]} {continue}

 		#Feld r�umen
 		object [expr ([lindex $liste $i]+0.5)*$size] [expr ([lindex $liste [expr $i+1]]+0.5)*$size] 0 0

 		#Einzeichnen
 		.rechts.c create text [expr ([lindex $liste $i]+0.5)*$size] \
              		      	[expr ([lindex $liste [expr $i+1]]+0.5)*$size] \
                      		-text "[expr ($g*[lindex $liste [expr $i+2]])+($h*[lindex $liste [expr $i+3]])]" -tags l -fill $color
 	}
 }

}

#==============================
#Prozedur um Pfad einzuzeichnen
#==============================
proc linie {liste} {
global ziel start size

 set pos [find [lindex $ziel 0] [lindex $ziel 1] $liste]
 set felder 0

 #Zur�ckbewegen und zeichnen
 while {[lrange $liste $pos [expr $pos+1]] != $start} {

 	#Einzeichnen
 	.rechts.c create line [expr ([lindex $liste $pos]+0.5)*$size] [expr ([lindex $liste [expr $pos+1]]+0.5)*$size] \
 			      [expr ([lindex $liste [expr $pos+2]]+0.5)*$size] [expr ([lindex $liste [expr $pos+3]]+0.5)*$size] \
                      	     	-tags l -fill blue

        #Koordinaten suchen
        set pos [find [lindex $liste $pos] [lindex $liste [expr $pos+1]] $liste]

 	incr felder
 }

 #Letzte Verbindung zeichnen
 .rechts.c create line [expr ([lindex $liste $pos]+0.5)*$size] [expr ([lindex $liste [expr $pos+1]]+0.5)*$size] \
 			[expr ([lindex $liste [expr $pos+2]]+0.5)*$size] [expr ([lindex $liste [expr $pos+3]]+0.5)*$size] \
                      	-tags l -fill blue

 #Start/Ziel
 drawend

 return [expr $felder+1]

}

#============================================
#Prozedur um Zahlenfolgen in Listen zu finden
#============================================
proc find {x y liste} {

 #Ziel-Node in Liste suchen
 for {set i 0} {$i<[llength $liste]} {incr i 4} {
 	if {[lindex $liste [expr $i+2]]==$x && [lindex $liste [expr $i+3]]==$y} {unset liste; return $i}
 }

}

#==============================
#�nerpr�ft Liste nach Eintr�gen
#==============================
proc g {x y liste} {

 #Suchen
 for {set i 0} {$i<[llength $liste]} {incr i 4} {
        if {[lindex $liste $i]==$x && [lindex $liste [expr $i+1]]==$y} {
         	return [lindex $liste [expr $i+2]]
        }
 }

 unset liste
 return -1

}

#================================
#Prozedur zum Zeichnen des Levels
#================================
proc draw {} {
global feld size felder

 #L�schen
 catch [.rechts.c delete wall]
 catch [.rechts.c delete ende]

 #Spielfeld
 for {set i 0} {$i<[expr $felder*$felder]} {incr i} {

	if {[lindex $feld $i]==0} {
		.rechts.c create rectangle  [expr $size*($i%$felder)] [expr $size*($i/$felder)] \
 				 	   [expr $size*($i%$felder+1)] [expr $size*($i/$felder+1)] \
                                 	   -fill beige -tags wall

        } elseif {[lindex $feld $i]==1} {

                .rechts.c create rectangle  [expr $size*($i%$felder)] [expr $size*($i/$felder)] \
 				 	   [expr $size*($i%$felder+1)] [expr $size*($i/$felder+1)] \
                                 	   -fill white -tags wall

        }
 }

 #Start/Ziel
 drawend

}

#======================================
#Prozedur um Start und Ziel zu zeichnen
#======================================
proc drawend {} {
global ziel start size

 #Start/Ziel
 .rechts.c create text [expr [lindex $ziel 0]*$size+$size/2] [expr [lindex $ziel 1]*$size+$size/2] -text "Z" -fill red -tags ende
 .rechts.c create text [expr [lindex $start 0]*$size+$size/2] [expr [lindex $start 1]*$size+$size/2] -text "S" -fill darkgreen -tags ende

}

#====================================
#Prozedur um die Feldgr��e anzupassen
#====================================
proc feld {} {
global felder size felderanzahl

 #Neue Feldgr��e speichern
 set felder $felderanzahl

 #Ma�e berechnen
 set size [expr 450/$felder]

 #Ma�e �ndern
 .rechts.c configure -height [expr $felder*$size] -width [expr $felder*$size]

}

#===============================
#Prozedur zum �ffnen einer Datei
#===============================
proc openFile {} {
global feld start ziel

 #Pfad ermitteln
 set pfad [tk_getOpenFile]

 #Fehlerkontrolle
 if {$pfad == ""} { return }

 #Datei einlesen
 set stream [open $pfad r]

 #Datei auslesen
 set data [read $stream]

 #Zur�cksetzen
 new

 #Inhalt ausgeben
 set data [split $data "\n"]
 set feld [lindex $data 0]
 set start [lindex $data 1]
 set ziel [lindex $data 2]
 draw

 #Kanal schlie�en
 close $stream

 #Variabeln l�schen
 unset stream
 unset data

}

#==================================
#Prozedur zum Speichern einer Datei
#==================================
proc saveFile {} {
global feld start ziel

 #Pfad einlesen
 set pfad [tk_getSaveFile]

 #Fehlerkontrolle
 if {$pfad == ""} { return }

 #Datenstrom erstellen
 set stream [open $pfad w 0755]

 #Daten schreiben
 set data "[join $feld]\n[join $start]\n[join $ziel]\n"

 #String in Datei schreiben
 puts -nonewline $stream $data

 #Datenstrom schlie�en
 flush $stream
 close $stream

 #Variabeln l�schen
 unset stream
 unset pfad

}

#======
#Frames
#======
 frame .oben -borderwidth 1 -relief raised
 frame .mitte
 frame .links -borderwidth 1 -relief raised
 frame .rechts -borderwidth 1 -relief raised
 frame .menuleiste

#=====
#Label
#=====
 label .links.aktion -text "Aktion:"
 label .links.leer -text ""
 label .links.ausgabe -text "Ausgabe:"
 label .menuleiste.aktuell -text "Level durch Hindernisse gestalten und Figur von Start zum Ziel schicken" -relief sunken

#=======
#Buttons
#=======
 button .links.b -text "Weg suchen!" -command "a"
 button .links.ok -text "Neuzeichnen!" -command {new}

#=====
#Scale
#=====
 scale .links.sc -bigincrement 1 -orient horizontal -from 10 -to 25 -variable felderanzahl
 set felderanzahl 17


#======
#Canvas
#======
 canvas .rechts.c -bg black

#============
#Radiobuttons
#============
 radiobutton .links.s -text "Start setzen" -variable aktion -value "S"
 radiobutton .links.z -text "Ziel setzen" -variable aktion -value "Z"
 radiobutton .links.e -text "Hindernis setzen" -variable aktion -value "hinderniss"

 radiobutton .links.k -text "Keine Zahlen" -variable ausgabe -value "k"
 radiobutton .links.g -text "G anzeigen"   -variable ausgabe -value "g"
 radiobutton .links.h -text "H anzeigen"   -variable ausgabe -value "h"
 radiobutton .links.f -text "F anzeigen"   -variable ausgabe -value "f"

#============
#Checkbuttons
#============
 checkbutton .links.sl -text "Verlangsamen" -variable langsam

#====
#Menu
#====
 menubutton .oben.datei -text "Datei" -menu .oben.datei.m
 menu .oben.datei.m -tearoff 0
 menu .oben.datei.m.def -tearoff 0

 .oben.datei.m add command -label "Neu" -command "new"
 .oben.datei.m add command -label "Laden" -command "openFile"
 .oben.datei.m add command -label "Speichern" -command "saveFile"
 .oben.datei.m add command -label "Beenden" -command exit

#========
#Bindings
#========
 bindings 1

#======
#Packen
#======
 pack .oben -fill x
 pack .oben.datei -side left
 pack .mitte
 pack .links .rechts -side left -fill both -in .mitte
 pack .rechts.c
 pack .menuleiste -fill x
 pack .menuleiste.aktuell -pady 2 -fill x -expand true

 grid .links.aktion -sticky we -pady 5
 grid .links.s -sticky w
 grid .links.z -sticky w
 grid .links.e -sticky w
 grid .links.leer
 grid .links.ausgabe -sticky we -pady 5
 grid .links.k -sticky w
 grid .links.g -sticky w
 grid .links.h -sticky w
 grid .links.f -sticky w
 grid .links.sl -sticky w -pady 14
 grid .links.b -sticky ew -pady 10 -padx 5

 wm title . "Wegsuche mit A*"
 wm resizable . no no

 new

# � � Stephan Behnke �
