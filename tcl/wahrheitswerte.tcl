001  # Programm zum Erstellen von Wertetabellen f�r Schaltungen
002
003
004
005
006  set letters {a b c d e f g h i j k l m n o p q r s t u v w x y z}
007  set zeichen { ( ) ! & | < = > " "}
008
009  #================================
010  #Prozedur um Schaltung anzupassen
011  #================================
012  proc config {schaltung} {
013  global letters
014
015   regsub -all "&" $schaltung "&&" schaltung
016   regsub -all "\\|" $schaltung "||" schaltung
017   regsub -all "<=>" $schaltung "==" schaltung
018   regsub -all "=>" $schaltung "<=" schaltung
019
020   return $schaltung
021
022  }
023
024  #==================================
025  #Prozedur zum �berpr�fen der Formel
026  #==================================
027  proc check {schaltung} {
028  global letters zeichen
029
030   #Leerzeichen
031   regsub -all " " $schaltung "" schaltung
032   if {$schaltung == ""} {tk_dialog .error "Fehler!" "Keine Eingabe!" "error" 0 "Ok"; return 0}
033
034   #Kontrolle
035   for {set i 0} {$i<[string length $schaltung]} {incr i} {
036
037          #Buchstaben hintereinander
038          if {[lsearch $letters [string index $schaltung $i]]>=0 && [lsearch $letters [string index $schaltung [expr $i+1]]]>=0} {
039                  tk_dialog .error "Fehler!" "2 Buchstaben direkt hintereinander ([string index $schaltung $i] und [string index $schaltung [expr $i+1]])!" "error" 0 "Ok"; return 0
040          }
041
042          #Falsche Zeichen
043          if {[lsearch $letters [string index $schaltung $i]]<0 && [lsearch $zeichen [string index $schaltung $i]]<0} {
044                  tk_dialog .error "Fehler!" "Ung�ltiges Zeichen \" [string index $schaltung $i] \" wurde verwendet!" "error" 0 "Ok"; return 0
045          }
046
047          #Klammer und Buchstabe
048          if {[string index $schaltung [expr $i+1]]=="\(" && [lsearch $letters [string index $schaltung $i]]>=0} {
049                  tk_dialog .error "Fehler!" "Klammer und Buchstabe direkt hintereinander!" "error" 0 "Ok"; return 0
050          }
051
052          #Buchstabe und Klammer
053          if {[string index $schaltung $i]=="\)" && [lsearch $letters [string index $schaltung [expr $i+1]]]>=0} {
054                  tk_dialog .error "Fehler!" "Buchstabe und Klammer direkt hintereinander!" "error" 0 "Ok"; return 0
055          }
056   }
057
058   #Klammern
059   if {[expr ([regsub -all "\\(" $schaltung "" schaltung]+[regsub -all "\\)" $schaltung "" schaltung])%2]} {
060   	tk_dialog .error "Fehler!" "Klammern wurden falsch gesetzt!" "error" 0 "Ok"; return 0
061   }
062
063   #Schaltung vorbereiten
064   set schaltung [config $schaltung]
065
066   #Buchstaben untersuchen
067   set eing {}
068   foreach buchstabe $letters {
069          if {[regsub "$buchstabe" $schaltung "" temp]} {
070                  lappend eing $buchstabe
071          }
072   }
073
074   #Belegung einsetzen
075   set temp $schaltung
076   set laenge [llength $eing]
077   for {set j 0} {$j<$laenge} {incr j} {
078   	regsub -all "[lindex $eing $j]" $temp "1" temp
079   }
080
081   #Algemeiner Fehler?
082   if [catch {expr $temp}] {
083   	tk_dialog .error "Fehler!" "Allgemeiner Fehler!" "error" 0 "Ok"; return 0
084   }
085
086   return 1
087
088  }
089
090  #==================================
091  #Prozedur zum Erstellen der Tabelle
092  #==================================
093  proc tabelle {schaltung} {
094  global letters
095
096   #Schaltung vorbereiten
097   set schaltung [config $schaltung]
098
099   #Buchstaben untersuchen
100   set eing {}
101   foreach buchstabe $letters {
102          if {[regsub "$buchstabe" $schaltung "" temp]} {
103                  lappend eing $buchstabe
104          }
105   }
106
107   set laenge [llength $eing]
108
109   #M�glichkeiten berechnen
110   set moeglichkeiten [expr int(pow(2,$laenge))]
111
112   #Anfangsbelegung festlegen
113   set belegung {}
114   for {set i 0} {$i<$laenge} {incr i} {
115          lappend belegung "0"
116   }
117
118   #Textinhalt l�schen
119   .unten.text delete 1.0 end
120
121   #Tabelle einrichten
122   for {set i 0} {$i<$laenge} {incr i} {
123          .unten.text insert end "   [lindex $eing $i]\t"
124   }
125
126   set pos [expr $laenge-1]
127   .unten.text insert end "Ergebnis"
128
129   #Alle M�glichkeiten durchgehen
130   for {set i 0} {$i<$moeglichkeiten} {incr i} {
131
132  	.unten.text insert end "\n"
133
134  	#Belegung ausgeben
135          for {set j 0} {$j<$laenge} {incr j} {
136          	.unten.text insert end "   [lindex $belegung $j]\t"
137   	}
138
139  	#Belegung einsetzen
140  	set temp $schaltung
141  	for {set j 0} {$j<$laenge} {incr j} {
142                  regsub -all "[lindex $eing $j]" $temp "[lindex $belegung $j]" temp
143   	}
144
145  	#Ergebnis ausgeben
146   	.unten.text insert end "     [expr $temp]\t"
147
148   	#Belegung �ndern
149  	set belegung [lreplace $belegung $pos $pos [expr [lindex $belegung $pos]+1]]
150  	for {set j 0} {$j<$laenge} {incr j} {
151                  if {[lindex $belegung $j]>1} {
152          		set belegung [lreplace $belegung [expr $j-1] [expr $j-1] [expr [lindex $belegung [expr $j-1]]+1]]
153          		for {set z $j} {$z<$laenge} {incr z} {
154                  		set belegung [lreplace $belegung $z $z 0]
155                  	}
156                  	set j 0
157                  }
158          }
159
160   }
161
162  }
163
164  #======
165  #Frames
166  #======
167   frame .oben
168   frame .mitte
169   frame .unten
170
171  #=====
172  #Label
173  #=====
174   label .oben.schalten -text "Schaltung: "
175
176  #====
177  #Text
178  #====
179   text .unten.text -bg white -relief sunken \
180  		  -yscrollcommand {.unten.scrolly set } \
181  		  -width 10 -height 18 -wrap none \
182  		  -font {helvetica 10}
183
184  #=========
185  #Scrollbar
186  #=========
187   scrollbar .unten.scrolly -orient vertical -command ".unten.text yview"
188
189  #=============
190  #Eingabefelder
191  #=============
192   entry .oben.schaltung -width 32 -textvariable schalt -font {helvetica 10}
193
194  #======
195  #Button
196  #======
197   button .mitte.tab -text "Tabelle errechnen!" -command { if {[check $schalt]} {tabelle $schalt}}
198   button .mitte.not -text "NOT" -command {.oben.schaltung insert insert "!"}
199   button .mitte.und -text "AND" -command {.oben.schaltung insert insert "&"}
200   button .mitte.oder -text "OR" -command {.oben.schaltung insert insert "|"}
201   button .mitte.aqui -text "<=>" -command {.oben.schaltung insert insert "<=>"}
202   button .mitte.impl -text "=>"  -command {.oben.schaltung insert insert "=>"}
203
204  #======
205  #Events
206  #======
207   bind .oben.schaltung <Return> {if {[check $schalt]} {tabelle $schalt}}
208   bind .oben.schaltung <Control-n> {.oben.schaltung insert insert "!"}
209   bind .oben.schaltung <Control-u> {.oben.schaltung insert insert "&"}
210   bind .oben.schaltung <Control-o> {.oben.schaltung insert insert "|"}
211   bind .oben.schaltung <Control-i> {.oben.schaltung insert insert "=>"}
212   bind .oben.schaltung <Control-a> {.oben.schaltung insert insert "<=>"}
213
214  #======
215  #Packen
216  #======
217   pack .oben
218   pack .mitte
219   pack .unten -expand true -fill both
220   pack .oben.schalten .oben.schaltung -side left -padx 5 -pady 5
221   pack .mitte.und .mitte.oder .mitte.not .mitte.aqui .mitte.impl .mitte.tab -side left -padx 5 -pady 5
222
223   pack .unten.text -side left -fill both -expand true -pady 1
224   pack .unten.scrolly  -fill y -expand true -pady 1
225
  wm title . "Wahrheitswertetabellen"

# � � Stephan Behnke �