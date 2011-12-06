#Das Spiel Tetris
# © ® Stephan Behnke ™
# Homepage: www.tcltk.de.vu
# E-Mail: stephan.behnke@gmx.net

#*****************#
#*****************#
#*** Variabeln ***#
#*****************#
#*****************#

 set breite 150
 set hohe 359
 set blocksize [expr $breite/10]
 set start 1
 set speed 1
 set pause 0
 set end 0

 #Verschiedene Farben in Liste schreiben
 set colors { black blue brown cyan gray green magenta pink
 	      purple red tomato turquoise violet wheat white yellow
 	      azure beige gold ivory lavender maroon navy orange tan }
 set colors [ lsort $colors ]


#*************#
#*************#
#*** Spiel ***#
#*************#
#*************#
#============================
#Prozedur für ein neues Spiel
#============================
proc neuesSpiel {} {
global end neu feld felder start blocksize

 #Spielvariabeln reseten
 levelup "reset"
 statistik 0 0
 pausieren 0
 set neu 1
 set end 0

 catch [destroy .name]

 #Spielfeld-Liste leeren
 set feld [recreate]

 #Neue Länge des Spielfeldes bestimmen
 set felder [llength $feld]

 #Spielfeld generieren
 stapeln $blocksize

 set neu 0

 #Spiel starten
 if {$start} {
 	set start 0
 	after 500 tetris
 }

}

#===============================
#Eigentliche Prozedur fürs Spiel
#===============================
proc tetris {} {
global pause speed blocksize

 if {!$pause} {

	#Block nach unten bewegen
	movedown $blocksize

	#Prozedur wiederholen
 	after [expr int(500/(([levelup 0].0+1.0)/3.0)/$speed.0)] tetris
 }

}

#=============================================
#Prozedur für die Anzeige des nächsten Blockes
#=============================================
proc anzeige {neu blocksize} {
global next

 #Aktuellen Block bestimmen
 if {$neu} {
 	set form [expr round(rand()*7)]
 	while {$form < 1} {
 		set form [expr round(rand()*7)+0]
 	}
 } else {

 	set form $next
 }

 #Nächsten Block bestimmen
 set next [expr round(rand()*7)]
 while {$next < 1} {
 	set next [expr round(rand()*7)]
 }

 #Aktuellen Block löschen
 catch [.unten.rechts.next.c delete block]

 #Block zeichnen
 drawnext $next $blocksize

 #Variabeln löschen
 unset blocksize
 unset neu

 return $form
 unset form

}

#================================
#Prozedur fürs Stapeln der Blöcke
#================================
proc stapeln {blocksize} {
global pause gedreht

 set neu 0

 #Aktuellen (beweglichen) Block löschen
 catch [.unten.links.c delete block]

 #Feste Blöcke setzen
 fest

 #Ggf. komplette Zeilen entfernen
 if {![line]} {

 	#Inhalt der Canvas' löschen
 	foreach tag [.unten.links.c find all] { .unten.links.c delete $tag }
 	foreach tag [.unten.rechts.next.c find all] { .unten.rechts.next.c delete $tag }

        #Neuzeichnen
	set neu [draw $blocksize]

	#Blockform bestimmen
	set form [anzeige $neu $blocksize]

	#Spiel verloren?
	if {[check 3 [block $form 0]]} {
 		gameover
        }

        #Neuen Stein erzeugen
	create 3 $form [block $form 0] $blocksize

	#In Ursprungsform zurücksetzen
 	set gedreht 0
 }

 #Variabeln löschen
 catch [unset form]
 unset blocksize
 unset neu

 return 1

}


#**************#
#**************#
#*** Listen ***#
#**************#
#**************#
#===================
#Liste neu erstellen
#===================
proc recreate {} {
global hohe breite blocksize

 #Anzahl der Felder ermitteln
 set felder [expr (12*(round($hohe/($blocksize))))]

 #Erste Reihe mit "/" Füllen
 for {set i 0} {$i < 12} {incr i} {
       lappend feld "/"
 }

 #Eigentliches Feld mit Nullen füllen
 for {set i 0} {$i < [expr $felder+12]} {incr i} {
 	if { [expr $i % 12] == 0 || [expr $i % 12] == 11 } {
 		lappend feld "/"
 	} else {
 	        lappend feld "0"
 	}
 }

 #Letzte Reihe mit "/" Füllen
 for {set i 0} {$i < 12} {incr i} {
       lappend feld "/"
 }

 #Variablen löschen
 unset felder
 unset i

 return $feld
 unset feld

}

#==================================
#Prozedur um feste Blöcke zu setzen
#==================================
proc fest {} {
global feld felder

 for {set i 0} {$i < $felder} {incr i} {

        if {[lindex $feld $i] < 0 && [lindex $feld $i] != "/" } {
        	set feld [lreplace $feld $i $i [expr abs([lindex $feld $i])]]
        	statistik 0 1
        }
 }

 unset i

}

#============================================================
#Prozedur zum Ermitteln der aktuellen Blockform oder Position
#============================================================
proc analyse {art} {
global feld felder

 for {set i 0} {$i < $felder} {incr i} {
        if {[lindex $feld $i] < 0 && [lindex $feld $i] != "/" } {
        	if {$art == "form"} {
        		set erg [expr abs([lindex $feld $i])]
        	} elseif {$art == "pos"} {
                        set erg $i
        	}
        	break
        }
 }

 #Variabeln löschen
 unset art
 unset i

 return $erg
 unset erg

}

#========================================
#Prozedur zum Überprüfen der Verschiebung
#========================================
proc control {vector} {
global feld felder

 for {set i 0} {$i < $felder} {incr i} {

 	if {[lindex $feld $i] < 0 && [lindex $feld $i] != "/" } {
 		set next [lindex $feld [expr $i+$vector]]

		if {$next > 0 || $next == "/"} {
			return 0
		}
	}
 }

 #Variabeln löschen
 catch [unset next]
 unset vector
 unset i

 return 1

}

#===========================================
#Prozedur zum Entfernen kompletierter Reihen
#===========================================
proc line {} {
global neu feld felder

 set blocks 0
 set reihen 0
 set gewonnen 0

 #Ausgefüllte Zeilen entfernen
 for {set i 0} {$i < $felder} {incr i} {
      	if {[lindex $feld $i] > 0} {
      		  incr blocks
      	} else {
        	  set blocks 0
      	}

      	#Bei gefundener Reihe, diese entfernen und darüberliegende Zeilen nachrücken lassen
      	if {$blocks == 10} {

          for {set z 9} {$z >= 0} {incr z -1} {
        	.unten.links.c delete [expr $i-$z]
        	 set feld [lreplace $feld [expr $i-$z] [expr $i-$z] 0]
          }

          set maximal [max]

          for {set z 0} {[expr $i+$z] >= $maximal} {incr z -1} {
          	catch [set feld [lreplace $feld [expr $i+$z] [expr $i+$z] [lindex $feld [expr $i+$z-12]]]]
          }

          incr reihen
      }
 }

 #Gewonnen?!
 if {!$neu} { set gewonnen [won] }

 #Punkte updaten
 if {$reihen} {statistik $reihen 0}

 #Variabeln löschen
 unset reihen
 unset blocks
 unset i

 return $gewonnen

}

#===================================================
#Prozedur zum Erstellen einer Matrix für einen Block
#===================================================
proc block {form drehung} {

 #Waagerechte
 if {$form == 1} {
 	if {![expr $drehung%2]} {
 		set matrix { 1 1 1 1 }
 	} else {
                set matrix { 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 0 }
	}

 #Würfel
 } elseif {$form == 2} {
 	set matrix { 0 1 1 0 0 1 1 0 }

 #L-Förmig
 } elseif {$form == 3} {
        if {![expr $drehung%4]} {
 		set matrix { 1 1 1 0 1 0 0 0 }

 	} elseif {[expr $drehung%4] == 1} {
                set matrix { 0 1 1 0 0 0 1 0 0 0 1 0 }

	} elseif {[expr $drehung%4] == 2} {
                set matrix { 0 0 0 0 0 0 1 0 1 1 1 0 }

	} elseif {[expr $drehung%4] == 3} {
                set matrix { 1 0 0 0 1 0 0 0 1 1 0 0 }
	}

 #T-Förmig
 } elseif {$form == 4} {
        if {![expr $drehung%4]} {
 		set matrix { 0 1 1 1 0 0 1 0 }

 	} elseif {[expr $drehung%4] == 1} {
                set matrix { 0 0 0 1 0 0 1 1 0 0 0 1 }

	} elseif {[expr $drehung%4] == 2} {
                set matrix { 0 0 0 0 0 0 1 0 0 1 1 1 }

	} elseif {[expr $drehung%4] == 3} {
                set matrix { 0 1 0 0 0 1 1 0 0 1 0 0 }
	}

 #Gespiegeltes L
 } elseif {$form == 5} {
        if {![expr $drehung%4]} {
 		set matrix { 1 1 1 0 0 0 1 0 }

 	} elseif {[expr $drehung%4] == 1} {
                set matrix { 0 0 1 0 0 0 1 0 0 1 1 0 }

	} elseif {[expr $drehung%4] == 2} {
                set matrix { 0 0 0 0 1 0 0 0 1 1 1 0 }

	} elseif {[expr $drehung%4] == 3} {
                set matrix { 1 1 0 0 1 0 0 0 1 0 0 0 }
	}

 #Z-Förmig
 } elseif {$form == 6} {
        if {![expr $drehung%2]} {
 		set matrix { 0 1 1 0 0 0 1 1 }

 	} elseif {[expr $drehung%2] == 1} {
                set matrix { 0 0 1 0 0 1 1 0 0 1 0 0 }
	}

 #Gespiegeltes Z
 } elseif {$form == 7} {
        if {![expr $drehung%2]} {
 		set matrix { 0 0 1 1 0 1 1 0 }

 	} elseif {[expr $drehung%2] == 1} {
                set matrix { 0 0 1 0 0 0 1 1 0 0 0 1 }
	}
 }

 return $matrix
 unset matrix

}

#===============================
#Prozedur fürs Updaten der Liste
#===============================
proc liste {x y} {
global feld felder

 #Bei Verschiebung nach links, Liste vorwärts durchgehen
 if {$x == -1} {

 	for {set i 0} {$i < [expr $felder-12]} {incr i 1} {

 		if {[lindex $feld $i] < 0 && [lindex $feld $i] != "/"} {
 			set feld [lreplace $feld [expr $i + $x] [expr $i + $x] [lindex $feld $i]]
 			set feld [lreplace $feld $i $i 0]
     		}
 	}

 #Bei Verschiebung nach rechts oder unten, Liste rückwärts durchgehen
 } elseif {$x == 1 || $y} {

        for {set i [expr $felder-12]} {$i > 0} {incr i -1} {

 		if {[lindex $feld $i] < 0 && [lindex $feld $i] != "/"} {
 			set feld [lreplace $feld [expr $i + $y*12 + $x] [expr $i + $y*12 + $x] [lindex $feld $i]]
 			set feld [lreplace $feld $i $i 0]
     		}
 	}
 }

 #Variabeln löschen
 catch [unset i]
 unset x
 unset y

}

#=======================================================
#Prozedur zum Überprüfen vor dem Erstellen eines Blockes
#=======================================================
proc check { pos matrix } {
global feld felder

 set fehler 0

 #Möglichkeit überprüfen
 for {set i 0} {$i < [llength $matrix]} {incr i} {
 	if {[lindex $matrix $i]} {
 		set position [lindex $feld [expr 13+$pos+(($i/4)*12)+($i%4)]]
       		if {$position > 0 || $position == "/"} {
       			set fehler 1
       			break
       		}
       	}
 }

 #Variabeln löschen
 unset position
 unset matrix
 unset pos
 unset i

 #Zurückgeben und löschen
 return $fehler
 unset fehler

}

#====================================================
#Prozedur für die Bestimmung der Breite eines Blockes
#====================================================
proc breite {String} {

 set breite 0

 for {set i 0} {$i < 4} {incr i} {
 	for {set j 0} {$j < [expr [llength $String]/4]} {incr j} {

        	if {[lindex $String [expr $i+$j*4]]} {
        	     incr breite
        	     break
       		}
        }
 }

 #Variable löschen
 unset String

 return $breite
 unset breite

}

#==================================================
#Prozedur für die Bestimmung der Höhe eines Blockes
#==================================================
proc hoehe {String} {

 set hohe 0

 for {set i 0} {$i < [expr [llength $String]/4]} {incr i} {
 	for {set j 0} {$j < 4} {incr j} {

        	if {[lindex $String [expr $j+$i*4]]} {
        	     incr hohe
        	     break
       		}
        }
 }

 #Variable löschen
 unset String

 return $hohe
 unset hohe

}

#===========================================
#Prozedur zum Ermitteln des höchsten Steines
#===========================================
proc max {}  {
global feld felder

 for {set i 0} {$i < [expr $felder-12]} {incr i} {
     if {[lindex $feld $i] > 0} {
           return $i
     }
 }

 return $felder

}


#***************#
#***************#
#*** Bewegen ***#
#***************#
#***************#
#===========================================
#Prozedur zum Bewegen des Blockes (vertikal)
#===========================================
proc movedown {blocksize} {

 set neu 0

 #Verschiebung kontrollieren
 if {![control 12]} { set neu [stapeln $blocksize] }

 #Block verschieben & Liste updaten
 if {!$neu} {
 	.unten.links.c move block 0 $blocksize
        liste 0 1
 }

 #Variabeln löschen
 unset blocksize
 unset neu

}

#=========================================
#Prozedur zum "Fallenlassen" eines Blockes
#=========================================
proc drop {} {
global blocksize

 set neu 0

 while {!$neu} {

	#Verschiebung kontrollieren
	if {![control 12]} { set neu [stapeln $blocksize] }

 	#Block verschieben & Liste updaten
 	if {!$neu} {
 		.unten.links.c move block 0 $blocksize
       		liste 0 1
	}
 }

 #Variabeln löschen
 unset neu

}

#=============================================
#Prozedur zum Bewegen des Blockes (horizontal)
#=============================================
proc moveside {vector} {
global blocksize

 #Verschiebung kontrollieren
 if {![control $vector]} { return }

 #Liste updaten
 liste $vector 0

 #Block verschieben
 .unten.links.c move block [expr $vector*$blocksize] 0

 #Variable löschen
 unset vector

}

#==================================
#Prozedur fürs Drehen eines Blockes
#==================================
proc drehen { richtung } {
global gedreht blocksize

 #Aktuelle Form ermitteln
 set form [analyse form]

 #Aktuelle Position ermitteln
 set pos [analyse pos]

 #Aktuelle Matrix speichern
 set matrix [block $form $gedreht]

 #Körperdrehung registrieren
 incr gedreht $richtung

 #Drehung präzisieren
 set position [lsearch $matrix "1"]
 incr pos -$position
 incr pos -13
 if {[expr $gedreht%4]==3 && ($form==3 || $form==4 || $form==5)} { incr pos -8 }

 #Drehung überprüfen und ggf. zeichnen
 if {![check $pos [block $form $gedreht]] && $form != 2} {
        create $pos $form [block $form $gedreht] $blocksize
 } else {
        incr gedreht -$richtung
 }

 #Variabeln löschen
 unset position
 unset richtung
 unset matrix
 unset form
 unset pos

}


#****************#
#****************#
#*** Zeichnen ***#
#****************#
#****************#
#=====================================
#Prozedur zum Zeichnen im Hauptfenster
#=====================================
proc draw {blocksize} {
global feld felder

 set neu 1

 for {set i 0} {$i < $felder} {incr i} {
  	if { [lindex $feld $i] > 0 } {
 		kaestchen $blocksize [expr $i/12] [expr $i%12-1] [farbe [lindex $feld $i]] $i
 		set neu 0
 	}
 }

 #Variabeln löschen
 unset blocksize
 unset i

 return $neu
 unset neu

}

#=====================================
#Prozedur zum Zeichnen im Next-Fenster
#=====================================
proc drawnext {next blocksize} {

 #Block-Matrix bestimmen
 set matrix [block $next 0]

 #Verschiebung für Zentrierung ermitteln
 set b [expr double([breite $matrix])]
 set b [expr (5.0-$b)/2]
 set h [expr double([hoehe $matrix])]
 set h [expr (3.0-$h)/2]

 if {[lindex $matrix 0] == 0} {
 	set v -1
 } else {
 	set v 0
 }

 #Zeichnen
 for {set i 0} {$i < [llength $matrix]} {incr i} {
 	if {[lindex $matrix $i]} {
 		.unten.rechts.next.c create rectangle [expr $blocksize*($i%4+$b+$v)] \
 						      [expr $blocksize*($i/4+$h)] \
 					  	      [expr $blocksize*($i%4+$b+$v)+$blocksize] \
 					  	      [expr $blocksize*($i/4+$h)+$blocksize] \
                	               	              -fill [farbe $next] -tags block
        }
 }

 #Variabeln löschen
 unset blocksize
 unset matrix
 unset next
 unset i
 unset v
 unset b
 unset h

}

#===========================================
#Prozedur zum Erstellen eines ganzen Blockes
#===========================================
proc create {pos form matrix blocksize} {
global feld felder

 #Aktuellen (beweglichen) Block löschen
 catch [.unten.links.c delete block]

 #Alten Block aus Liste löschen
 for {set i 0} {$i < $felder} {incr i 1} {
	if {[lindex $feld $i] < 0 && [lindex $feld $i] != "/"} {
 		set feld [lreplace $feld $i $i 0]
     	}
 }

 #Block setzen
 for {set i 0} {$i < [llength $matrix]} {incr i} {
 	if {[lindex $matrix $i]} {
 		set feld [lreplace $feld [expr 12+$pos+1+(($i/4)*12)+($i%4)] \
 					 [expr 12+$pos+1+(($i/4)*12)+($i%4)] -$form]
 	}
 }

 #Block zeichnen
 for {set i 0} {$i < $felder} {incr i} {
 	if {[lindex $feld $i] < 0 && [lindex $feld $i] != "/" } {
		 kaestchen $blocksize [expr $i/12] [expr $i%12-1] \
 			   [farbe $form] block
 	}
 }

 #Variabeln löschen
 unset blocksize
 unset matrix
 unset form
 unset pos
 unset i

}

#================================================
#Prozedur zum Erstellen eines einzelnen Kästchens
#================================================
proc kaestchen { blocksize zeile spalte color tag} {
global hohe breite

 #Ein Kästchen erzeugen
 .unten.links.c create rectangle [expr $blocksize*$spalte] [expr $blocksize*($zeile-1)] \
 				 [expr $blocksize*($spalte+1)] [expr $blocksize*$zeile ] \
                                 -fill $color -tags $tag

 #Variabeln löschen
 unset spalte
 unset color
 unset zeile
 unset tag

}

#===========================
#Prozedur für die Farbgebung
#===========================
proc farbe {form} {

 set farben {null lightblue purple green white cyan yellow magenta}
    return [lindex $farben $form]

 unset farben
 unset form

}


#****************************#
#****************************#
#*** Optionen / Sonstiges ***#
#****************************#
#****************************#

#========================
#Prozedur für Pauseoption
#========================
proc pausieren {state} {
global pause

 if {$state=="a"} {
 	if {$pause} {
		set pause 0
                catch [tetris]
	 } else {
  		set pause 1
	 }
 } elseif {$state==0} {
 	set pause 0
 } elseif {$state==1} {
        set pause 1
 }

}

#==========================
#Prozedur für die Statistik
#==========================
proc statistik {rows addpoints} {
global score lines

 if {$rows==0 && $addpoints==0} {
 	set score 0
 	set lines 0
 }

 if {$rows} {
 	incr score [expr int($rows+1*[levelup 0])]
 }

 #Möglichen Level updaten
 levelup 1

 #Neue Punktzahl
 incr score $addpoints
 .unten.rechts.stats.punktew configure -text "$score"

 #Neue Reihenzahl
 incr lines $rows
 .unten.rechts.stats.zeilenw configure -text "$lines"

 #Variabeln löschen
 unset addpoints
 unset rows

}

#===========================
#Prozedur für nächstes Level
#===========================
proc levelup {aktion} {
global lines level score

 #Aktuelles Level zurückgeben
 if {$aktion==0} {
       return $level

 #Level auf 1 zurücksetzen
 } elseif {$aktion == "reset"} {

       set level 1
       .unten.rechts.stats.levelw configure -text "$level"

 #Level ggf. erhöhen
 } else {

      if {[expr $lines / (10*$level)] > 0} {
           incr level
           .unten.rechts.stats.levelw configure -text "$level"
           return $level

      } else {
       	   return $level
      }
 }

 #Variable löschen
 unset aktion

}

#=======================
#Prozedur fürs Verlieren
#=======================
proc gameover {} {
global end

 pausieren 1
 msg "GAME OVER!"
 set end 1

 #Highscores ggf. speichern
 high

}

#======================
#Prozedur fürs Gewinnen
#======================
proc won {} {
global end feld felder score

 #Kontrollieren ob gewonnen wurde
 for {set i 0} {$i < $felder} {incr i} {
 	if {[lindex $feld $i] > 0} {
  		return 0
 	}
 }

 #Alle Blöcke löschen
 foreach tag [.unten.links.c find all] { .unten.links.c delete $tag }

 pausieren 1
 msg "YOU WON!"

 #Bonus geben
 catch [incr score [expr [levelup 0]*100]]

 #Highscores ggf. speichern
 high

 set end 1
 return 1
}

#========================================
#Prozedur zum Ausgeben von Text im Canvas
#========================================
proc msg {inhalt} {
global breite hohe

 #Kasten erstellen
 .unten.links.c create rectangle [expr $breite/2-50] [expr $hohe/2+20] \
 				 [expr $breite/2+50] [expr $hohe/2-20] \
 				 -tag feld -fill gray

 #Text hineinschreiben
 .unten.links.c create text [expr $breite/2] [expr $hohe/2] -text $inhalt -tag text

 #Variabeln löschen
 unset inhalt

}

#========================================
#Prozedur für das Anzeigen der Highscores
#========================================
proc highscores {} {

 set breite 10
 pausieren 1

 #Altes Fenster ggf. löschen
 catch [destroy .highscores]

 #Toplevel erstellen
 toplevel .highscores

 #Frames
 frame .highscores.oben
 frame .highscores.unten

 #Widgets deklarieren
 button .highscores.unten.beenden -text Beenden -command {destroy .highscores}

 #Fenster konfigurieren
 wm resizable .highscores no no
 wm title .highscores "Highscores"

 #Highscores einlesen
 set text [openH]

 #Highscores anzeigen
 for {set i 0} {$i<10} {incr i} {

     #Ggf. leicht einrücken
     if {$i!=9} {
          label .highscores.oben.platz$i -relief flat -text " [expr $i+1]. "
     } else {
          label .highscores.oben.platz$i -relief flat -text "[expr $i+1]. "
     }

     label .highscores.oben.name$i -relief flat -text "[lindex $text [expr $i*2+1]]"
     label .highscores.oben.wert$i -text "[lindex $text [expr $i*2+2]]"
     label .highscores.oben.frei$i -text "" -width [expr $breite-[winfo width .highscores.oben.name$i] \
     							-[winfo width .highscores.oben.wert$i]]

     grid .highscores.oben.platz$i -row $i -column 0 -pady 2
     grid .highscores.oben.name$i  -row $i -column 1 -sticky w
     grid .highscores.oben.frei$i  -row $i -column 2
     grid .highscores.oben.wert$i  -row $i -column 3 -padx 4

 }

 pack .highscores.oben .highscores.unten -in .highscores
 pack .highscores.unten.beenden -pady 8

 #Variable löschen
 unset breite
 unset text
 unset i

}

#====================================================
#Prozedur zur Erstellung einer neuen Highscores Datei
#====================================================
proc neuH {} {

 #Vordefinierte Highscore Datei schreiben
 set text {black}
 foreach punkte {2500 2000 1500 1000 750 500 250 100 50 25} {
 	lappend text "Mr Lover"
 	lappend text "$punkte"
 }

 saveH $text
 unset text

}

#========================================
#Prozedur für das Auslesen der Highscores
#========================================
proc openH {} {

 #Datei versuchen einlesen
 if [catch {set stream [open ./Tetris r]}] {
        neuH
 }

 #Datei einlesen
 set stream [open ./Tetris r]

 #Datei auslesen
 set text [read $stream]

 #Kanal schließen
 close $stream

 #Decodieren
 #set text [codieren 1 $text "geheimespasswort"]

 #In Liste umwandeln
 set text [split $text " "]

 #Variabeln löschen
 unset stream

 return $text
 unset text

}

#=========================================
#Prozedur für das Speichern der Highscores
#=========================================
proc saveH {liste} {

 #Liste in String umwandeln
 set text [join $liste]

 #Codieren
 #set text [codieren 0 $text "geheimespasswort"]

 #Datenstrom erstellen
 set stream [open ./Tetris w 0755]

 #String in Datei schreiben
 puts -nonewline $stream $text

 #Datenstrom schließen
 flush $stream
 close $stream

 #Variabeln löschen
 unset stream
 unset liste
 unset text

}

#=====================================
#Prozedur zum Kontrollieren des Namens
#=====================================
proc checkname {name} {

 set zeichen { a ä b c d e f g h i j k l m n o ö p q r s t u ü v w x y z 1 2 3 4 5 6 7 8 9 0 - _}
 set name [ string tolower $name 0 end ]

 #Fehler bei leerem String
 if {$name == " " || $name == ""} { return 0 }

 #Länge überprüfen
 if {[string length $name] > 25} { return 0}

 #Leerzeichen vorhanden?
 for { set i 0 } { $i < [string length $name] } { incr i } {
 	if {[string index $name $i] == " "} {
 		return 0
 	}
 }

 #Kontrollieren
 for { set i 0 } { $i < [string length $name] } { incr i } {
	for { set j 0 } { $j < [llength $zeichen] } { incr j } {
		if { [string index $name $i] == [lindex $zeichen $j]} {
			break
		}
	}
	if { $j == [llength $zeichen] } { return 0 }
 }

 #Variabeln löschen
 unset zeichen
 unset name
 unset i

 return 1

}

#==================================================
#Prozedur zum Testen auf erreichten Highscore-Platz
#==================================================
proc high {} {
global score

 #Aktuelle Highscores einlesen
 set text [openH]

 #Highscores vergleichen
 for {set i 2} {$i < [llength $text]} {incr i 2} {
        if {[lindex $text $i] <= $score } {
		getname
        }
 }

 #Variabeln löschen
 unset text
 unset i

}

#==========================================================
#Prozedur zum Einlesen des Namens und Setzen der Highscores
#==========================================================
proc getname {} {
global score

 #Altes Fenster ggf. löschen
 catch [destroy .name]

 #Toplevel erstellen
 toplevel .name

 #Widgets deklarieren
 entry  .name.namen -textvariable Name
 label  .name.hinweis -text "Hinweis: Max. 25 Zeichen, keine Leerzeichen und Sonderzeichen"
 button .name.best -text "Bestätigen" \
 	-command {
 		if {[checkname $Name]} {
 			destroy .name

 			set text [openH]
 			set text [split $text " "]

			for {set i 2} {$i < [llength $text]} {incr i 2} {
				if {[lindex $text $i] <= $score } {

 					#Highscore eintragen
 					if {$i!=20} { set text [lrange $text 0 18] }
					set text [linsert $text [expr $i-1] $Name $score]

                                        #Speichern
                                        saveH $text

                                        break
                                }
                        }
                 }
        }

 #Packen
 pack .name.namen .name.hinweis .name.best -padx 5 -pady 5

 #Fenster konfigurieren
 wm resizable .name no no
 wm title .name "Bitte Namen eingeben:"

}

#===================================================
#Prozedur für das Laden der Datei beim Programmstart
#===================================================
proc datei {} {

 #Datei öffnen
 set text [openH]

 #Farbe anpassen
 .unten.links.c configure -bg [lindex $text 0]
 .unten.rechts.next.c configure -bg [lindex $text 0]

 #Variable löschen
 unset text

}

#======================
#Prozedur für die Infos
#======================
proc infos {} {

 pausieren 1

 #Altes Fenster ggf. löschen
 catch [destroy .infos]

 #Toplevel erstellen
 toplevel .infos

 #Widgets deklarieren
 label .infos.ueber -text "==> TETRIS <=="
 label .infos.von   -text "Stephan Behnke, PK 11"
 label .infos.date  -text "© 2002"
 label .infos.url   -text "www.tcltk.de.vu"
 label .infos.email -text "Kontakt: stephan.behnke@gmx.net"

 #Packen
 pack .infos.ueber -pady 8
 pack .infos.von
 pack .infos.date
 pack .infos.url
 pack .infos.email

 #Fenster konfigurieren
 wm resizable .infos no no
 wm title .infos "About me"

}

#======================
#Prozedur für die Hilfe
#======================
proc help {} {

 pausieren 1

 #Altes Fenster ggf. löschen
 catch [destroy .hilfe]

 #Toplevel erstellen
 toplevel .hilfe

 #Frames
 frame .hilfe.oben
 frame .hilfe.unten

 #Widgets deklarieren
 message .hilfe.oben.regelnU    -text "REGELN:" -aspect 500
 message .hilfe.oben.regeln     -text "Ziel des Spiels ist es, herunterfallende Formen am Boden eines rechteckigen Behälters zu platzieren.\nDie Formen bestehen aus vier Blöcken, die unterschiedlich zusammengesetzt sieben verschiedene Muster ergeben. Wenn die Formen herunterfallen, müssen sie so gedreht und ausgerichtet werden, dass keine Lücken am Boden entstehen.\nIst eine komplette waagerechte Reihe mit Blöcken gefüllt, so wird sie vom Bildschirm gelöscht. Sind die Reihen nicht vollständig ausgefüllt, stapeln sich die Formen immer weiter nach oben. Gelangt der Stapel am oberen Rand an, so ist das Spiel verloren." \
 				-width 350
 message .hilfe.oben.punkteU    -text "PUNKTESYSTEM:" -aspect 500
 message .hilfe.oben.punkte     -text "Man erhält pro Block, den man nach unten befördert, 4 Punkte. Zudem gibt es für kompletierte Reihen ebenfalls Punkte.\nDiese erhöhen sich mit dem Level und der Anzahl der Reihen, die man auf einmal kompletiert. Das heißt umso höher das Level und um so mehr Reihen man schafft, desto höher sind die Punkte." \
 				-width 350
 message .hilfe.oben.steuerungU -text "STEUERUNG:" -aspect 500

 set i 0
 foreach aktion {Drehen Links Rechts Beschleunigung "Sofort Fallenlassen" Pausieren "Neues Spiel"} \
 	 taste {Pfeiltaste-Oben Pfeiltaste-Links Pfeiltaste-Rechts Pfeiltaste-Unten Leertaste P Strg+N} {

      incr i
      grid [label .hilfe.unten.aktion$i -text "$aktion:  "] [label .hilfe.unten.taste$i -text "$taste"] -sticky w
 }

 #Packen
 pack .hilfe.oben .hilfe.unten -in .hilfe
 grid .hilfe.oben.regelnU    -sticky w -pady 4
 grid .hilfe.oben.regeln     -sticky w -padx 9
 grid .hilfe.oben.punkteU    -sticky w -pady 4
 grid .hilfe.oben.punkte     -sticky w -padx 9
 grid .hilfe.oben.steuerungU -sticky w -pady 4

 #Fenster konfigurieren
 wm resizable .hilfe no no
 wm title .hilfe "Hilfe"

}

#===========================
#Prozedur für die Farbgebung
#===========================
proc farbgebung {} {
global colors

 pausieren 1

 #Altes Fenster ggf. löschen
 catch [destroy .farbe]

 #Datei versuchen einlesen
 if [catch {set stream [open ./Tetris r]}] {
        neuH
 }

 #Toplevel erstellen
 toplevel .farbe

 #Frames
 frame .farbe.oben
 frame .farbe.unten

 #Widgets deklarieren
 scrollbar .farbe.oben.scroll -orient vertical -command ".farbe.oben.farben yview"
 listbox   .farbe.oben.farben -height 15 -bg white -listvariable color -yscrollcommand {.farbe.oben.scroll set}
 button    .farbe.unten.best -text "Bestätigen" -command {catch [changecolor [.farbe.oben.farben curselection]]}

 #Farben einfügen
 .farbe.oben.farben delete 0 end
 foreach line $colors { .farbe.oben.farben insert end $line }

 #Packen
 pack .farbe.oben -expand true -fill both
 pack .farbe.unten
 pack .farbe.oben.farben -side left  -fill both -expand true
 pack .farbe.oben.scroll -side right -fill y
 grid .farbe.unten.best

 #Fenster konfigurieren
 wm title .farbe "Welche?"

}

#===========================================
#Prozedur zum Ändern und Speichern der Farbe
#===========================================
proc changecolor {pos} {
global colors

 #Farbe der Canvas' ändern
 .unten.links.c configure -bg [lindex $colors $pos]
 .unten.rechts.next.c configure -bg [lindex $colors $pos]

 #Datei einlesen und verändern
 set text [openH]
 set text [lreplace $text 0 0 [lindex $colors $pos] ]

 #Speichern
 saveH $text

}

#=====================
#Prozedur zum Codieren
#=====================
proc codieren {art zeichen verschieben} {

 #Liste der Buchstaben
 set letters { A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z}

 #Liste der Zahlen in Wörtern
 set numbers { null eins zwei drei vier fuenf sechs sieben acht neun }

 #Alle Buchstaben auf Kleinbuchstaben setzen
 set verschieben [string tolower $verschieben 0 end]

 #Umlaute ersetzen
 regsub -all "ü" $zeichen "ue" zeichen
 regsub -all "ä" $zeichen "ae" zeichen
 regsub -all "ö" $zeichen "oe" zeichen

 #Das ß durch ss ersetzen
 regsub -all "ß" $zeichen "ss" zeichen

 #Zahlen durch Wörter ersetzen
 if {!$art} {
 	for { set i 0 } { $i < 10 } { incr i } {
		regsub -all "$i" $zeichen  "[lindex $numbers $i]" zeichen
 	}
 }

 #Schlüssel als Liste aus Zahlen schreiben
 for { set i 0 } { $i < [string length $verschieben] } { incr i } {
 	lappend schluessel [lsearch $letters [string index $verschieben $i] ]
 }

 set krypt ""

 #Schleife durch den String
 for { set i 0 } { $i < [string length $zeichen] } { incr i } {

	set z 0

	#Zeichen für aktuelle Stelle im String durchgehen
	foreach buchstabe $letters {

		#Wenn sie übereinstimmen...
		if { [string index $zeichen $i] == $buchstabe } {

			#... Neues Zeichen setzen
			if {!$art} {
				set neu [expr $z - [lindex $schluessel [expr $i % [llength $schluessel] ] ] ]
			} else {
				set neu [expr $z + [lindex $schluessel [expr $i % [llength $schluessel] ] ] ]
			}

			#... Zeichen kontrollieren
			if { $neu >= [llength $letters] || $neu < 0 } {
				set neu [expr $neu % [llength $letters]]
			}

			#... Zeichen schreiben
			append krypt [lindex $letters $neu]

			#Schleife beenden
			break

		} elseif {[string index $zeichen $i] == " "} {

                        #Zeichen schreiben
			append krypt " "

			#Schleife beenden
			break
		}
	incr z
	}

 }

 #Wörter durch Zahlen ersetzen
 if {$art} {
 	for { set i 0 } { $i < 10 } { incr i } {
		regsub -all "[lindex $numbers $i]" $krypt "$i" krypt
 	}
 }

 #Variabeln löschen
 unset verschieben
 unset schluessel
 unset zeichen
 unset numbers
 unset letters
 unset art
 unset neu
 unset i
 unset z

 return $krypt
 unset krypt

}

#***************#
#***************#
#*** Widgets ***#
#***************#
#***************#
#======
#Frames
#======
 frame .oben
 frame .unten
 frame .unten.links -bd 1 -bg black
 frame .unten.rechts
 frame .unten.rechts.next -bd 1 -bg black
 frame .unten.rechts.rahmen -bd 1 -bg black
 frame .unten.rechts.stats

#====
#Menu
#====
 menubutton .oben.spiel -text "Spiel" -menu .oben.spiel.m
 menubutton .oben.infos -text "Info"  -menu .oben.infos.m

 menu .oben.spiel.m -tearoff 0
 .oben.spiel.m add command -label "Neu"		 -command {if {$end}  {set pause 1; pausieren a} elseif {$pause} {pausieren a; pausieren a}; neuesSpiel}
 .oben.spiel.m add command -label "Pause"	 -command "pausieren a"
 .oben.spiel.m add command -label "Hintergrundfarbe ändern" -command "farbgebung"
 .oben.spiel.m add command -label "Beenden"	 -command "exit"

 menu .oben.infos.m -tearoff 0
 .oben.infos.m add command -label "Highscores"   -command "highscores"
 .oben.infos.m add command -label "Hilfe"        -command "help"
 .oben.infos.m add command -label "Über"         -command "infos"

#======
#Canvas
#======
 canvas .unten.links.c -width $breite -height $hohe -bg turquoise
 canvas .unten.rechts.next.c -width [expr $blocksize*5-2.5] -height [expr $blocksize*3] -bg turquoise

#======
#Labels
#======
 label .unten.rechts.stats.level  -text "Level:"
 label .unten.rechts.stats.zeilen -text "Lines:"
 label .unten.rechts.stats.punkte -text "Points:"

 label .unten.rechts.stats.levelw  -text "0"
 label .unten.rechts.stats.zeilenw -text "0"
 label .unten.rechts.stats.punktew -text "0"

 label .unten.rechts.freiraum -width 15 -height 11

#========
#Bindings
#========
 bind . <Control-n>	{if {$end}  {set pause 1; pausieren a} elseif {$pause} {pausieren a; pausieren a}; neuesSpiel}
 bind . <p>		{if {!$end} {pausieren a}}

 bind . <Key-Up>          {if {!$pause} {drehen 1}}
 bind . <KeyPress-Down>	  {if {!$pause} {set speed 8}}
 bind . <KeyRelease-Down> {if {!$pause} {set speed 1}}
 bind . <Key-Left>        {if {!$pause} {moveside -1}}
 bind . <Key-Right>	  {if {!$pause} {moveside 1}}

 bind . <Key-space>	  {if {!$pause} {drop}}

#======
#Packen
#======
 pack .oben -fill x
 pack .unten -padx 5 -pady 5
 pack .unten.links .unten.rechts -in .unten -side left
 pack .unten.rechts.next .unten.rechts.freiraum .unten.rechts.stats -in .unten.rechts -side top

 pack .oben.spiel .oben.infos -side left

 pack .unten.links.c -fill x

 pack .unten.rechts.next.c -in .unten.rechts.next

 pack .unten.rechts.rahmen -fill x -padx 10
 pack .unten.rechts.stats -in .unten.rechts.rahmen -fill x

 pack .unten.rechts.stats.level .unten.rechts.stats.levelw \
      .unten.rechts.stats.zeilen .unten.rechts.stats.zeilenw \
      .unten.rechts.stats.punkte .unten.rechts.stats.punktew -in .unten.rechts.stats

 wm title . "Tetris"
 wm resizable . no no

 datei

# © ® Stephan Behnke ™
