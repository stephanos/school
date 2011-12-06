#Programm zur Anwendung von genetischen Algorithmen
# © ® Stephan Behnke ™
# Homepage: www.tcltk.de.vu
# E-Mail: stephan.behnke@gmx.net


####################################
## PROBLEM DES HANDLUNGSREISENDEN ##
####################################

#================
#Prozedur für TSP
#================
proc TSP {} {
global punkte opt

 #Überschrift
 wm title . "Das Problem des Handlungsreisenden"

 #Alle Widgets löschen
 set widgets [winfo children .unten]
 foreach element $widgets {destroy $element}

 #Widgets deklarierern
 pack [frame .unten.1 -borderwidth 1 -relief raised] -expand true -fill both
 pack [frame .unten.2 -borderwidth 1 -relief raised] -expand true -fill both
 pack [frame .unten.3 -borderwidth 1 -relief raised] -expand true -fill both
 pack [frame .unten.4 -borderwidth 1 -relief raised] -expand true -fill both
 pack [frame .unten.5 -borderwidth 1 -relief raised] -expand true -fill both

 catch {[destroy .oben.opt]}
 menubutton .oben.opt -text "Optimierung" -menu .oben.opt.m
 menu .oben.opt.m -tearoff 0
 .oben.opt.m add radiobutton -label "Aus" 	   -value 0 -variable opt
 .oben.opt.m add radiobutton -label "Zufällig" 	   -value 1 -variable opt
 .oben.opt.m add radiobutton -label "Systematisch" -value 2 -variable opt
 set opt 2
 pack .oben.opt -side left

 pack [canvas .unten.1.c -width 430 -height 300 -bg white]
 for {set i 0} {$i<4} {incr i} {grid [canvas .unten.2.c$i -width 100 -height 100 -border 2 -bg white] -column $i -row 1}

 grid [button .unten.3.start   -text "Start" -command {input "start"}]	-row 1 -column 1 -padx 5 -pady 8
 grid [button .unten.3.stop    -text "Stop"  -command {input "stop"}] 	-row 1 -column 2 -padx 5
 grid [button .unten.3.del     -text "Löschen" -command {input "del"}] 	-row 1 -column 3 -padx 5
 grid [label .unten.3.label    -text "Generation: "] 			-row 1 -column 4 -padx 5
 grid [label .unten.3.gen      -text "0" -relief sunken -width 4] 	-row 1 -column 5
 grid [checkbutton .unten.3.ch -text "Grafiken" -variable zeichne]      -row 1 -column 6 -padx 10

 grid [scale .unten.4.skala   -label "Speed:" -from 0 -to 100 -orient horizontal] 	 -row 1 -column 1 -padx 8
 grid [scale .unten.4.skala2  -label "Nachkommen:" -from 6 -to 20 -orient horizontal] 	 -row 1 -column 2 -padx 15
 grid [scale .unten.4.skala3  -label "Mutation (%):" -from 0 -to 100 -orient horizontal] -row 1 -column 3 -padx 15

 pack [label .unten.5.aktuell -text "Punkte setzen und dann kürzesten Weg berechnen lassen." -relief sunken -width 50] -fill both

 #Tasten deklarieren
 binding 1

 set punkte {}
 .unten.4.skala set 100
 .unten.4.skala2 set 6
 .unten.4.skala3 set 2
 .unten.3.ch select

}

#===========================
#Prozedur für Tastenbindings
#===========================
proc binding {bool} {
global punkte

 if {$bool} {
 	bind .unten.1.c <Button-1> {set punkte [setzen %x %y $punkte]}
 	bind .unten.1.c <Button-3> {set punkte [delete %x %y $punkte]; anzeige $punkte 0 1}
 	menubuttons 1
 } else {
 	bind .unten.1.c <Button-1> {}
 	bind .unten.1.c <Button-3> {}
 	menubuttons 0
 }

}

#=====================
#Prozedur für Eingaben
#=====================
proc input {aktion} {
global punkte

 if {$aktion=="start"} {
 	.unten.3.start config -state disable
 	.unten.3.del config -state disable
 	input "reset"
 	binding 0
 	genetic
 } elseif {$aktion=="stop"} {
 	if {[.unten.3.del cget -state]=="disable"} {
 		.unten.3.stop config -relief sunken
 	}
 } elseif {$aktion=="del"} {
 	binding 1
        set punkte {}
        .unten.3.gen config -text "0"
        anzeige $punkte 0 1
 } else {
        binding 1
        .unten.3.gen config -text "0"
        anzeige $punkte 0 1
 }

}

#===============================
#Prozedur zum Setzen von Punkten
#===============================
proc setzen {x y punkte} {

 if {[llength $punkte]>=198} {.unten.5.aktuell config -text "Maximale Anzahl von Punkten erreicht"; return $punkte}
 .unten.5.aktuell config -text "Punkte setzen und dann kürzesten Weg berechnen lassen."

 #An Raster anpassen
 set x [expr int($x/20)*20]
 set y [expr int($y/20)*20]

 #Kontrollieren
 for {set i 0} {$i<[llength $punkte]} {incr i 2} {
 	if {[lindex $punkte $i]==$x && [lindex $punkte [expr $i+1]]==$y} {
 		return $punkte
 	}
 }

 lappend punkte $x $y
 anzeige [list $x $y] [expr [llength $punkte]/2-1] 0
 return $punkte

}

#================================
#Prozedur zum Löschen von Punkten
#================================
proc delete {x y punkte} {

 .unten.5.aktuell config -text "Zuerst die gewünschten Punkte setzen und dann den kürzesten Weg berechnen lassen."

 #An Raster anpassen
 set x [expr int($x/20)*20]
 set y [expr int($y/20)*20]

 #Kontrollieren
 for {set i 0} {$i<[llength $punkte]} {incr i 2} {
 	if {[lindex $punkte $i]==$x && [lindex $punkte [expr $i+1]]==$y} {
                set punkte [concat [lrange $punkte 0 [expr $i-1]] [lrange $punkte [expr $i+2] [expr [llength $punkte]-1]]]
 		return $punkte
 	}
 }


 return $punkte

}

#===============================
#Prozedur für die Grafik-Anzeige
#===============================
proc anzeige {punkte start del} {

 #Feld löschen
 catch [.unten.1.c delete line]
 for {set i 0} {$i<4} {incr i} {catch [.unten.2.c$i delete line]}
 if {$del} {catch [.unten.1.c delete all]; for {set i 0} {$i<4} {incr i} {catch [.unten.2.c$i delete all]}}

 #Punkt mit Nummer einzeichnen
 for {set i 0} {$i<[llength $punkte]} {incr i 2} {

        #Punkt
        .unten.1.c create oval [expr [lindex $punkte $i]-2] [expr [lindex $punkte [expr $i+1]]-2] \
        			[expr [lindex $punkte $i]+2] [expr [lindex $punkte [expr $i+1]]+2] -fill green

        #Kleine Punkte
        for {set j 0} {$j<4} {incr j} {
                .unten.2.c$j create oval [expr [lindex $punkte $i]/4-2] [expr [lindex $punkte [expr $i+1]]/3-2] \
        			[expr [lindex $punkte $i]/4+2] [expr [lindex $punkte [expr $i+1]]/3+2] -fill green
        }

        #Nummer
        .unten.1.c create text [expr [lindex $punkte $i]+9] [expr [lindex $punkte [expr $i+1]]-5] -text "[expr $start+$i/2+1]"
 }

}

#==================================
#Prozedur für die Verbindungslinien
#==================================
proc linien {gene feld} {
global punkte

 lappend gene [lindex $gene 0]

 #Von Punkt-zu-Punkt zeichnen
 for {set i 0} {$i<[expr [llength $gene]-1]} {incr i} {

 	if {!$feld} {
 		.unten.1.c create line  [expr [lindex $punkte [expr [lindex $gene $i]*2]]] \
 					[expr [lindex $punkte [expr [lindex $gene $i]*2+1]]] \
        				[expr [lindex $punkte [expr [lindex $gene [expr $i+1]]*2]]] \
        				[expr [lindex $punkte [expr [lindex $gene [expr $i+1]]*2+1]]] -fill red -tags line
 	} else {
        	.unten.2.c[expr $feld-1] create line  	[expr [lindex $punkte [expr [lindex $gene $i]*2]]/4] \
 						[expr [lindex $punkte [expr [lindex $gene $i]*2+1]]/3] \
        					[expr [lindex $punkte [expr [lindex $gene [expr $i+1]]*2]]/4] \
        					[expr [lindex $punkte [expr [lindex $gene [expr $i+1]]*2+1]]/3] -fill red -tags line
 	}
 }

}

#==========================================
#Prozedur für den "Genetischen Algorithmus"
#==========================================
proc genetic {} {
global punkte zeichne opt

 set individuen [.unten.4.skala2 get]

 #Ausreichend Punkte?
 if {[llength $punkte]<3} {
 	.unten.5.aktuell config -text "Nicht genügend Punkte vorhanden..."
 	.unten.3.stop config -relief sunken
 } else {
 	.unten.5.aktuell config -text "Die erste Generation wird erzeugt..."
 }

 update

 #Punkte zählen
 set anzahl [expr [llength $punkte]/2]

 set population {}

 #Erste Generation schaffen
 for {set i 0} {$i<$individuen} {incr i} {

	set gene {}

        #Liste aller Nummern
        for {set j 0; set nummern {}} {$j<[expr [llength $punkte]/2]} {incr j} {lappend nummern $j}

        #Nummern zufällig in Gene eintragen
        while {[llength $nummern]} {
                set pos [expr round(rand()*([llength $nummern]-1))]
                lappend gene [lindex $nummern $pos]
                set nummern [concat [lrange $nummern 0 [expr $pos-1]] [lrange $nummern [expr $pos+1] [expr [llength $nummern]-1]]]
        }

        lappend population [join $gene]
 }

 set gleich 0
 set last 0
 set durchgang 0

 #Weiterentwickeln
 while {[.unten.3.stop cget -relief]!="sunken"} {

	incr durchgang
	.unten.3.gen config -text "$durchgang"

	#Ergebnisse bewerten
        set entfernungen {}
        for {set i 0} {$i<$individuen} {incr i} {
        	set gene [split [lindex $population $i] " "]
		lappend gene [lindex $gene 0]
        	lappend entfernungen [strecke $gene]
        }

        #Selektion
        set best {}
        set sort [lsort -integer $entfernungen]
        if {$individuen>=10} {set bis [expr int($individuen/2)]} else {set bis 5}
        for {set i 0} {$i<$bis} {incr i} {lappend best [lsearch $entfernungen [lindex $sort $i]]}

	#Linien zeichnen
  	if {$zeichne} {
  		catch [.unten.1.c delete line]
   		for {set i 0} {$i<4} {incr i} {catch [.unten.2.c$i delete line]}
  		linien [split [lindex $population [lindex $best 0]] " "] 0
          	for {set i 1} {$i<5} {incr i} {linien [split [lindex $population [lindex $best $i]] " "] $i}
  	}

	#Ausgabe
	.unten.5.aktuell config -text "Weiterentwicklung läuft...aktuelle Weglänge: [lindex $entfernungen [lindex $best 0]]"
 	update

	set laenge [llength [lindex $population [lindex $best 0]]]

 	#Beste Strecke übernehmen und modifizieren
        set new [lindex $population [lindex $best 0]]
        if {$opt && $gleich>=2 && $last==$new} {
                if {$opt==2} {
                	set pos [expr int($durchgang/2)%$laenge]
                } else {
                	set pos [expr int(rand()*($laenge-1))]
                }
        	set temporary [lindex $new $pos]
        	set new [lreplace $new $pos $pos [lindex $new 0]]
        	set new [lreplace $new 0 0 "x"]
        	for {set i 1} {$i<$laenge} {incr i} {

          		#Strecken suchen
          		for {set j 1; set kuerzest {}} {$j<$laenge} {incr j} {
                                if {[lindex $new $j]!="x"} {
                                        lappend kuerzest [lindex $new $j]
                                }
          		}

                        #Besten wählen
                        set besten 0
                        set startpunkt [lindex $temporary [expr $i-1]]
                        set besteStrecke [concat $startpunkt [lindex $kuerzest 0]]
                        for {set j 0} {$j<[llength $kuerzest]} {incr j} {
                        	set tour [concat $startpunkt [lindex $kuerzest $j]]
                                if {[strecke $besteStrecke]>[strecke $tour]} {
                                	set besten $j
                                	set besteStrecke $tour
                                }
                        }
                        set besten [lsearch $new [lindex $kuerzest $besten]]
			lappend temporary [lindex $new $besten]
                        set new [lreplace $new $besten $besten "x"]
          	}
        	set gleich 0
        	set new $temporary
        }
        if {$last==$new} {incr gleich} else {set gleich 0; set last $new}
        set new [list $new]
        if {$opt} {lappend new [lindex $population [lindex $best 0]]}

        #Anzahl der Individuen festlegen
	set individuen [.unten.4.skala2 get]

	#Erstes Parent
        set parent1 [split [lindex $population [lindex $best 0]] " "]

 	#Neue Generation erzeugen
        for {set i 0} {[llength $new]!=$individuen} {incr i} {

		if {[expr $i+1]==[llength $best]} {set i 0}

        	#Zweites Parent
        	set parent2 [split [lindex $population [lindex $best [expr round(rand()*([llength $best]-1))]]] " "]

		#Offspring
		set offspring [lrange $parent1 [expr round(rand()*($laenge-1))] [expr round(rand()*($laenge-1))]]

		#Kreuzen
                for {set j 0} {$j<$laenge} {incr j} {
                        if {[lsearch $offspring [lindex $parent2 $j]]==-1} {
                                lappend offspring [lindex $parent2 $j]
                        }
		}

		#Mutation
                set modifiziert 0
		set modifizieren [expr $laenge*([.unten.4.skala3 get]/100.0)]
                for {set j 0} {$modifiziert<$modifizieren} {incr j} {

			if {$j==$laenge} {set j 0}

                        #Position setzen
			set pos1 [expr round(rand()*($laenge-1))]
                        set pos2 [expr round(rand()*($laenge-1))]

			#Ersetzen
                       	set temporary [lindex $offspring $pos1]
                        set offspring [lreplace $offspring $pos1 $pos1 [lindex $offspring $pos2]]
                        set offspring [lreplace $offspring $pos2 $pos2 $temporary]
                        incr modifiziert
                }
                lappend new [join $offspring]
        }

        set population $new

 	update
 	while {![.unten.4.skala get]} {update}
 	after [expr (1000-[.unten.4.skala get]*10)*$zeichne]
 }

 .unten.3.start config -state normal
 .unten.3.stop config -relief raised
 .unten.3.del config -state normal
 binding 1

}

#===========================================
#Prozedur zum Ermitteln der Länge einer Tour
#===========================================
proc strecke {tour} {
global punkte

 set distance 0

 for {set i 0} {$i<[expr [llength $tour]-1]} {incr i} {
        set xx [expr [lindex $punkte [expr [lindex $tour $i]*2]]-[lindex $punkte [expr [lindex $tour [expr $i+1]]*2]]]
 	set yy [expr [lindex $punkte [expr [lindex $tour $i]*2+1]]-[lindex $punkte [expr [lindex $tour [expr $i+1]]*2+1]]]
 	incr distance [expr int(sqrt(pow($xx,2)+pow($yy,2)))]
 }

 return $distance

}

###############
## EVOLUTION ##
###############

#================
#Prozedur für EVO
#================
proc EVO {} {

 #Alle Widgets löschen
 set widgets [winfo children .unten]
 foreach element $widgets {destroy $element}

 #Überschrift
 wm title . "Evolution"

 #Widgets deklarierern
 pack [frame .unten.1 -borderwidth 1 -relief raised] -expand true -fill both
 pack [frame .unten.2 -borderwidth 1 -relief raised] -expand true -fill both
 pack [frame .unten.3 -borderwidth 1 -relief raised] -expand true -fill both
 pack [frame .unten.4 -borderwidth 1 -relief raised] -expand true -fill both
 pack [frame .unten.5 -borderwidth 1 -relief raised] -expand true -fill both

 pack [canvas .unten.1.c -width 674 -height 482 -bg white]

 catch {[destroy .oben.opt]}

 grid [button .unten.2.start   -text "  Start  " -command {eingabe "start"}] -row 1 -column 1 -padx 10 -pady 8
 grid [button .unten.2.stop    -text "  Stop  "  -command {eingabe "stop"}]  -row 1 -column 2 -padx 10
 grid [label .unten.2.l1 -width 2] 					-row 1 -column 3
 grid [label .unten.2.day1     -text "Tag: "]	 			-row 1 -column 4
 grid [label .unten.2.day2     -text "0" -relief sunken -width 4] 	-row 1 -column 5
 grid [label .unten.2.l2 -width 2] 					-row 1 -column 6
 grid [label .unten.2.gen1     -text "Generation: "]	 		-row 1 -column 7
 grid [label .unten.2.gen2     -text "0" -relief sunken -width 4] 	-row 1 -column 8
 grid [label .unten.2.l3 -width 2] 					-row 1 -column 9
 grid [checkbutton .unten.2.ch -text "Grafiken" -variable zeichne -command {catch [.unten.1.c delete all]}]      -row 1 -column 14 -padx 10

 grid [scale .unten.3.skala1  -label "Pausen (ms)" -from 0 -to 200 -orient horizontal] 	 -row 1 -column 3 -padx 8  -pady 5
 grid [scale .unten.3.skala2  -label "Nachkommen:" -from 4 -to 20 -orient horizontal] 	 -row 1 -column 4 -padx 15
 grid [scale .unten.3.skala3  -label "Pflanzen:" -from 200 -to 400 -orient horizontal] 	 -row 1 -column 7 -padx 15
 grid [scale .unten.3.skala4  -label "Kreuzung (%):" -from 0 -to 100 -orient horizontal] -row 1 -column 5 -padx 15
 grid [scale .unten.3.skala5  -label "Mutation (%):" -from 0 -to 10 -orient horizontal]  -row 1 -column 6 -padx 15

 pack [text .unten.4.t -height 4 -yscrollcommand {.unten.4.scrolly set}] -fill both -side left -expand true
 pack [scrollbar .unten.4.scrolly -orient vertical -command ".unten.4.t yview"] -side right -fill y

 pack [label .unten.5.aktuell -text "Simulation mit gewünschten Einstellungen starten und Evolution von fiktiven Lebewesen betrachten." -relief sunken -width 20] -fill both

 .unten.3.skala1 set 0
 .unten.3.skala2 set 10
 .unten.3.skala3 set 300
 .unten.3.skala4 set 75
 .unten.3.skala5 set 1
 .unten.2.ch select

}

#========================
#Prozedur für die Eingabe
#========================
proc eingabe {aktion} {

 if {$aktion=="start"} {
 	.unten.2.start config -state disable
 	menubuttons 0
 	evolutionieren
 } else {
 	if {[.unten.2.start cget -state]=="disable"} {
 		.unten.2.stop config -relief sunken
 	}
 }

}

#==========================
#Prozedur für das Spielfeld
#==========================
proc feld {} {
global punkte population

 #Leeres Feld initalisieren
 set punkte {}

 #Oben
 for {set i 0} {$i<44} {incr i} {lappend punkte "/"}

 #Mitte
 for {set i 0} {$i<1320} {incr i} {
        if {![expr $i%44] || [expr $i%44]==43} {
 		lappend punkte "/"
 	} else {
 		lappend punkte "0"
 	}
 }

 #Unten
 for {set i 0} {$i<44} {incr i} {lappend punkte "/"}

 #Eaters eintragen
 for {set i 0} {$i<[llength $population]} {incr i} {

	set eater [split [lindex $population $i] ","]
	set pos [expr (([lindex $eater 1]-2)/16)+((([lindex $eater 2]-2)/16)*44)+45]
        eintragen "E" $pos [lindex $eater 0]
 }

 #Pflanzen eintragen
 for {set i 0; set plants 0} {$plants<[.unten.3.skala3 get]} {incr i} {


        if {$i>=[expr [llength $punkte]-44]} {set i 0}

        if {![expr round(rand()*12)]} {

		#Länge
 		set row [expr round(rand()*8)+5]
		set z $row

		#Erste Reihe
        	while {$z && [lindex $punkte $i]!="/"} {
        		if {[lindex $punkte $i]=="0"} {
        			set punkte [lreplace $punkte $i $i "P"]
        			incr plants
        		}
        		incr z -1
        		incr i
        	}

        	incr i [expr 44-$row]

        	#Zweite Reihe
        	while {$row && [lindex $punkte $i]!="/"} {
        		if {[lindex $punkte $i]=="0"} {
        			set punkte [lreplace $punkte $i $i "P"]
        			incr plants
        		}
        		incr row -1
        		incr i
        	}
        }
 }

}

#=======================
#Prozedur um zu zeichnen
#=======================
proc display {} {
global punkte population

 #Feld löschen
 catch [.unten.1.c delete all]

 #Pflanzen zeichnen
 for {set i 0} {$i<[llength $punkte]} {incr i} {

 	#Pflanzen
        if {[lindex $punkte $i]=="P"} {
                set x [expr (($i%44)-1)*16+2]
                set y [expr int(($i/44)-1)*16+2]
        	.unten.1.c create oval $x $y [expr $x+16] [expr $y+16] -outline darkgreen
        }
 }

 #Eaters zeichnen
 for {set i 0} {$i<[llength $population]} {incr i} {

	set eater [split [lindex $population $i] ","]

 	#Größe ermitteln
        set durchmesser [expr (16*[lindex $eater 0])+16]

 	#Koordinaten ermitteln
        set x [lindex $eater 1]
        set y [lindex $eater 2]

        #Winkel bestimmen
        set vy 0; set vx 0
        switch "[lindex $eater 3]" {
          "0" {set s 135; if {[lindex $eater 0]} {set vy -10; set vx 10} else {set vy -8; set vx 4}}
          "1" {set s 225; if {[lindex $eater 0]} {set vy -22} else {set vy -14}}
          "2" {set s 315; if {[lindex $eater 0]} {set vy -11; set vx -10} else {set vy -8; set vx -4}}
          "3" {set s 45 }
        }

 	#Zeichnen
        .unten.1.c create arc [expr $x+$vx] [expr $y+4+$durchmesser*1.5+$vy] \
        			[expr $x+$durchmesser+$vx] [expr $y+4+$vy] -outline red -start $s -extent 90
 }

}

#===============================
#Prozedur zum Handeln der Eaters
#===============================
proc handeln {} {
global punkte population

  set points 0

  #Schritte der Eaters planen
  for {set i 0} {$i<[llength $population]} {incr i} {

	#Splitten
	set eater [split [lindex $population $i] ","]
	set gene [split [lindex $eater 6] ";"]

	#Aktueller Status
	set state [lindex $eater 5]

	#Sichtfeldposition
        set pos [expr (([lindex $eater 1]-2)/16)+((([lindex $eater 2]-2)/16)*44)+45]
        switch [lindex $eater 3] {
           "0"  {if {![lindex $eater 0]} {incr pos 1}   else {incr pos 2;   set pos2 [expr $pos+44]}}
           "1"  {if {![lindex $eater 0]} {incr pos -44} else {incr pos -44; set pos2 [expr $pos+1]}}
           "2"  {if {![lindex $eater 0]} {incr pos -1}  else {incr pos -1;  set pos2 [expr $pos+44]}}
           "3"  {if {![lindex $eater 0]} {incr pos 44}  else {incr pos 88;  set pos2 [expr $pos+1]}}
        }
        if {![lindex $eater 0]} {set pos2 $pos}

        #Im Sichtfeld
        if {[lindex $punkte $pos]=="0"} {
        	set item 0
        	if {[lindex $punkte $pos2]=="E" || [lindex $punkte $pos2]=="/"} {set item 2}
        } elseif {[lindex $punkte $pos]=="P"} {
        	set item 1
        	if {[lindex $punkte $pos2]=="E" || [lindex $punkte $pos2]=="/"} {set item 2}
        } else {
        	set item 2
        }

  	#Schritt planen
  	set new_state [lindex $gene [expr $state+(9*$item)]]
        set aktion    [lindex $gene [expr 27+$new_state+(9*$item)]]
        set eater     [lreplace $eater 5 5 $new_state]

        #Plan umschreiben
        switch $aktion {
           "0"  {set plan 1}
           "1"  {set plan 90}
           "2"  {set plan -90}
        }

  	#Gehen
  	if {$plan=="1"} {

		#Alte Position löschen
		set old_pos [expr (([lindex $eater 1]-2)/16)+((([lindex $eater 2]-2)/16)*44)+45]
		eintragen "0" $old_pos [lindex $eater 0]

		#Verrücken
		set x 0; set y 0
        	switch "[lindex $eater 3]" {
        	  "0"   {set new_pos [expr $old_pos+  1];  incr x  16 }
        	  "1"   {set new_pos [expr $old_pos+-44];  incr y -16 }
        	  "2"   {set new_pos [expr $old_pos+ -1];  incr x -16 }
        	  "3"   {set new_pos [expr $old_pos+ 44];  incr y  16 }
        	}

        	#Gültig?
        	set p [eintragen "E" $new_pos [lindex $eater 0]]
        	if {$p!="-1"} {
                        set eater [lreplace $eater 1 1 [expr [lindex $eater 1]+$x]]
                        set eater [lreplace $eater 2 2 [expr [lindex $eater 2]+$y]]
                        set eater [lreplace $eater 4 4 [expr [lindex $eater 4]+$p]]
                        incr points $p
        	} else {
                	eintragen "E" $old_pos [lindex $eater 0]
        	}

	#Drehen
        } elseif {$plan=="90" || $plan=="-90"} {

                #Richtung verändern
                set eater [lreplace $eater 3 3 [expr abs(([lindex $eater 3]+($plan/90))%4)]]
        }

        #Speichern
        regsub -all " " $gene ";" gene
        set eater "[lrange $eater 0 5],$gene"
        regsub -all " " $eater "," eater
        set population [lreplace $population $i $i $eater]
  }

  return $points

}

#===========================================
#Prozedur um Eaters in die Liste einzutragen
#===========================================
proc eintragen {inhalt pos breiter} {
global punkte

 set points 0
 set addition [list 0]
 if {$breiter} {lappend addition 1 44 45}

 #Kontrollieren
 foreach add $addition {
 	set eintrag [lindex $punkte [expr $pos+$add]]
 	if {$eintrag=="/"} {
                if {$inhalt!="0"} {return -1}
 	} elseif {$eintrag=="P"} {
                incr points
 	} elseif {$eintrag=="E"} {
 		if {$inhalt!="0"} {return -1}
 	}
 }

 #Einschreiben
 foreach add $addition {
       	set punkte [lreplace $punkte [expr $pos+$add] [expr $pos+$add] $inhalt]
 }

 return $points

}

#===========================================
#Prozedur zum Setzen der Position der Eaters
#===========================================
proc setxy {} {
global population

 #Eater konfigurieren
 set temp {}
 set koords {}
 for {set i 0} {$i<[llength $population]} {incr i} {

	set eater [split [lindex $population $i] ","]

	#Koordinaten suchen
        while {1} {

        	#Koordinaten setzen
       		set x [expr int(round(rand()*640)/32*32)+2]
        	set y [expr int(round(rand()*460)/32*32)+2]

		#Überprüfen
                for {set j 0} {$j<[llength $koords]} {incr j 2} {
                        if {[lindex $koords $j]==$x && [lindex $koords [expr $j+1]]==$y} {
                        	break
                        }
                }

                if {$j==[llength $koords]} {break}
        }

        #Abspeichern
        lappend temp "[lindex $eater 0],$x,$y,[expr round(rand()*3)],0,[expr round(rand()*15)],[lindex $eater 6]"
        lappend koords $x $y
 }

 set population $temp

}

#======================================
#Prozedur um Pflanzen wachsen zu lassen
#======================================
proc grow {anzahl} {
global punkte

 for {set plants 0; set j 0; set o 0} {$plants<$anzahl} {incr j} {

	set i [expr 45+round(rand()*1320)]
        if {$j>200} {set o 1}

	#Leeres Feld ?
	if {[lindex $punkte $i]=="0"} {

               	if {!$o} {
               		if {[lindex $punkte [expr $i+1]]=="P" || [lindex $punkte [expr $i-1]]=="P"} {
                       		set punkte [lreplace $punkte $i $i "P"]
                       		incr plants
                       	}
               	} else {
                	if {[lindex $punkte [expr $i+44]]=="P" || [lindex $punkte [expr $i-44]]=="P"} {
                       		set punkte [lreplace $punkte $i $i "P"]
                       		incr plants
                       	}
               	}
	}
 }

}

#=========================================
#Prozedur zur Weiterentwicklung der Eaters
#=========================================
proc evolutionieren {} {
global punkte zeichne population

 #Anzahl der Eaters festlegen
 set individuen [.unten.3.skala2 get]

 #Textfenster löschen
 .unten.4.t delete 1.0 end

 set beste 0

 #Erste Generation erschaffen
 #{größe,x,y,orientierung,punkte,state,verhalten}
 set population {}
 for {set i 0} {$i<$individuen} {incr i} {

	set gene ""

	#Größe bestimmen
	if {![expr round(rand()*4)]} {
		append gene "1,"
	} else {
		append gene "0,"
	}

	#X,Y
	append gene "x,y,"

	#Orientierung
	append gene "[expr round(-0.49+rand()*3.98)],"

	#Punktezahl
        append gene "0,"

        #Aktueller State
        append gene "[expr round(-0.49+rand()*8.98)],"

        #States (0-15)
        for {set j 0} {$j<27} {incr j} {append gene "[expr round(-0.49+rand()*8.98)];"}

        #Aktionen (0-3)
        for {set j 0} {$j<27} {incr j} {append gene "[expr round(-0.49+rand()*2.98)];"}

	#Speichern
        lappend population [string range $gene 0 [expr [string length $gene]-2]]
 }

 set durchgang 0

 #Weiterentwickeln
 while {[.unten.2.stop cget -relief]!="sunken"} {

	#Position der Eaters setzen
	setxy

	#Neues Feld erschaffen
	feld

	#Generation anzeigen
	incr durchgang
	.unten.2.gen2 config -text "$durchgang"

	#Ein Jahr simulieren
	for {set i 1} {$i<366 && [.unten.2.stop cget -relief]!="sunken"} {incr i 2} {

		#Text-Ausgabe
                .unten.2.day2 config -text "$i"

 		#Grafik-Ausgabe
                if {$zeichne} {display}

        	#Eaters agieren lassen
                set points [handeln]

                #Pflanzen nachwachsen lassen
                grow $points

		#Update + Verzögerung
		update
 		if {$zeichne} {after [.unten.3.skala1 get]}
        }

        #Ergebnisse suchen
        set max 0
        set gesamt 0
        set punktzahl {}
        for {set i 0} {$i<$individuen} {incr i} {

        	#Punktzahl speichern
        	set eater [split [lindex $population $i] ","]
		lappend punktzahl [lindex $eater 4]

		#Größten Wert speichern
		if {[lindex $eater 4]>$max} {set max [lindex $eater 4]}

        	incr gesamt [lindex $eater 4]
        }

        #Ausgabe
        if {[.unten.2.stop cget -relief]!="sunken"} {
        	if {$durchgang>1} {.unten.4.t insert end "\n"}
        	.unten.4.t insert end "Generation: $durchgang\t"
        	.unten.4.t insert end "Gesamtpunkte aller: $gesamt\t"
        	.unten.4.t insert end "Bestleistung: $max\t"
        	set temp [expr $gesamt/$individuen.0]
        	.unten.4.t insert end " Durchschnittspunktzahl: [format {%3.2f} $temp]"
        	if {$beste<$temp} {set beste $temp; .unten.4.t insert end " *"}
        	.unten.4.t see $durchgang.0
        }
	update

	#Bewerten
        set sort [lsort -integer -decreasing $punktzahl]
        for {set i 0; set best {}} {$i<$individuen} {incr i} {
        	if {[lindex $sort $i]!=0} {
        		lappend best [lsearch $punktzahl [lindex $sort $i]]
        	}
        }
        if {[llength $best]<2} {lappend best [lsearch $punktzahl [lindex $sort 0]]}

	#Anzahl der Eaters festlegen
 	set individuen [.unten.3.skala2 get]
 	set 1zu1 [expr int((100-[.unten.3.skala4 get])/100.0*$individuen.0)]

        #Selektion
        for {set i 0; set temp {}} {[llength $temp]<$individuen} {incr i} {

		if {$i==[llength $best]} {set i 0}

        	#Anzahl der Nachkommen
       		set nachkommen [expr round(([lindex $punktzahl [lindex $best $i]].0+1)/($gesamt+1)*$individuen.0)]

       		#Abspeichern
                for {set j 0} {$j<$nachkommen} {incr j} {lappend temp $i}
       	}

       	set modifizieren [expr round(54*([.unten.3.skala5 get]/100.0))]

        #Neue Generation erschaffen
        for {set i 0; set erg {}} {$i<$individuen} {incr i} {

                #Offspring
        	set offspring [split [lindex [split [lindex $population [lindex $best [lindex $temp $i]]] ","] 6] ";"]
        	set part [lrange [split [lindex $population [lindex $best [lindex $temp $i]]] ","] 0 5]

		if {$i>$1zu1} {

			#Parent
        		set parent [split [lindex [split [lindex $population [lindex $best [expr ($i+1)%[llength $best]]]] ","] 6] ";"]

                	#Kreuzen
                	for {set j [expr round(rand()*53)]} {$j<54} {incr j} {
                		set offspring [lreplace $offspring $j $j "[lindex $parent $j]"]
                	}

               		#Mutation
			set modifiziert 0
                	while {$modifiziert<$modifizieren} {
				set pos [expr round(rand()*53)]
				if {$pos<27} {set faktor 8.98} else {set faktor 2.98}
                        	set offspring [lreplace $offspring $pos $pos [expr round(-0.49+rand()*$faktor)]]
                        	incr modifiziert
                	}

                	#Größe ggf. modifizieren
                	if {[expr round(rand()*10)]<=[.unten.3.skala5 get]} {
                		set part [lreplace $part 0 0 [expr ![string index $part 0]]]
                	}
                }

                #Speichern
		regsub -all " " $part "," part
		regsub -all " " $offspring ";" offspring
		set part "[join $part],[join $offspring]"
		lappend erg $part
        }

	set population $erg
 }

 .unten.2.start config -state normal
 .unten.2.stop config -relief raised
 menubuttons 1

}

###############
## SONSTIGES ##
###############
proc menubuttons {bool} {

 if {$bool} {
        .oben.datei config -state normal
 } else {
 	.oben.datei config -state disable
 }

}

#############
## WIDGETS ##
#############

#======
#Frames
#======
 frame .oben -borderwidth 1 -relief raised
 frame .unten

#====
#Menu
#====
 menubutton .oben.datei -text "Anwendung" -menu .oben.datei.m
 menu .oben.datei.m -tearoff 0
 .oben.datei.m add command -label "Evolution" -command "EVO"
 .oben.datei.m add command -label "Handlungsreisender" -command "TSP"
 .oben.datei.m add separator
 .oben.datei.m add command -label "Beenden" -command exit

#======
#Packen
#======
 pack .oben -fill x
 pack .oben.datei -side left
 pack .unten -expand true -fill both
 wm resizable . no no

 TSP

# © ® Stephan Behnke ™
