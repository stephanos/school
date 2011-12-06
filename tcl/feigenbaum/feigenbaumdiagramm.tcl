#Programm zum Bestimmen von Primzahlen (in bestimmten Zahlenabständen) mit c++
# © ® Stephan Behnke ™
# Homepage: www.tcltk.de.vu
# E-Mail: stephan.behnke@gmx.net


#====================
#Aufruf des Programms
#====================
proc errechnen {} {

 #Variabeln
 set start [.oben.start get]
 set ende [.oben.ende get]
 set schritte [.oben.schritte get]
 set iterationen [.oben.iterationen get]
 set stellen [.oben.stellen get]

 #Kurzer Check
 if {$start>=$ende || $stellen<=0 || $schritte<=0} {return 0}

 #Konfigurieren
 .oben.b config -state disable -text "Berechne..."
 .unten.t delete 1.0 end
 update

 #Errechnen
 if [catch {.unten.t insert end [exec ./feigenbaumdiagramm.exe -$start -$ende -$schritte -$iterationen -$stellen]}] {return 0}
 return 1

}


#======
#Frames
#======
 frame .oben
 frame .unten

#====
#Text
#====
 text .unten.t -height 20 -yscrollcommand {.unten.scroll set}

#=========
#Scrollbar
#=========
 scrollbar .unten.scroll -orient vertical -command ".unten.t yview"

#===========
#Label+Entry
#===========
 label .oben.lstart -text "Startwert: "
 entry .oben.start -width 4
 label .oben.lende  -text "Endwert: "
 entry .oben.ende -width 4
 label .oben.lschritte -text "Schritte:"
 entry .oben.schritte -width 4
 label .oben.literationen -text "Iterationen:"
 entry .oben.iterationen -width 4
 label .oben.lstellen -text "Stellen:"
 entry .oben.stellen -width 4

#======
#Button
#======
 button .oben.b -text "Berechnen!" -command {
    if {![errechnen]} {tk_dialog .error "Fehler!" "Die Werte sind nicht korrekt!" "error" 0 "Ok"}
    .oben.b config -state normal -text "Berechnen!"
 }

#======
#Packen
#======
 pack .oben
 pack .unten -expand true -fill both
 pack .oben.lstart .oben.start .oben.lende .oben.ende .oben.lschritte .oben.schritte \
	.oben.literationen .oben.iterationen .oben.lstellen .oben.stellen .oben.b -padx 5 -pady 5 -side left
 pack .unten.t -side left -fill both -expand true
 pack .unten.scroll -side right -fill y

 #Werte vortragen
 .oben.start insert end 3
 .oben.ende insert end 4
 .oben.schritte insert end 0.01
 .oben.iterationen insert end 1000
 .oben.stellen insert end 2

wm title . "Feigenbaumdiagramm 2 Derive"
