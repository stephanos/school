  package require http

proc openFile {} {

   #Pfad ermitteln
   set pfad "./data.txt"

   #Datei einlesen
   set stream [open $pfad r]

   #Datei auslesen
   set text [read $stream]

   #Kanal schließen
   close $stream

   #Variabeln löschen
   unset stream

   return $text
}

proc saveFile {data} {

   #Pfad einlesen
   set pfad "./data.txt"

   #Datenstrom erstellen
   set stream [open $pfad w 0755]

   #String in Datei schreiben
   puts -nonewline $stream $data

   #Datenstrom schließen
   flush $stream
   close $stream

   #Variabeln löschen
   unset pfad
   unset data
   unset stream
}

proc adjust {preis vorzeichen}  {

  	if {$preis == "0.00"} {
  		return "\t-"
  	}

  	set preis "$preis"

  	set l [string length $preis]

  	while {$l < 6} {
  		set preis "  $preis"
  		incr l
	}

  	if {$vorzeichen} {
  		if {$preis > 0} {
  			set vorzeichen "-"
  		} else {
  			set vorzeichen "+"
  		}
  	} else {
  		set vorzeichen ""
  	}

  	return "$vorzeichen $preis €"
}


#Artikel abchecken
proc GetArticle {url} {

 	#Webseite laden
  	set x [::http::geturl $url]
  	set liste [split [::http::data $x] "<"]

  	#Name extrahieren
  	set pos 0
  	set name ""
  	set klammer 0
          foreach e $liste {
                  if {[regexp "b class=\"sans\">" $e]} {
         			for {set i [string length $e]} {[string index $e $i]!=">"} {incr i -1} {

         				set z [string index $e $i]

         				if {$z == "\)"} {
         					set klammer 1
         				} elseif {$z == "\("} {
         					set klammer 0
        				} else {
         					if {!$klammer} { set name "$z$name" }
         				}
          		}
          		break
          	}
          	incr pos
          }

          set Text ""
          append Text "$name"

  	#Gespeicherte Daten checken
  	set data ""
          if {[file exists "./data.txt"]} {
          	set data [openFile]
          	set data [split $data "__"]
          }

  	set preis 	"0.00"
  	set maxprice 	"0.00"
  	set ausg_preis 	"0.00"
  	set ausg_diff  	"0.00"
  	set beschr 	""

  	#Preis suchen
          for {set ppos 0} {$ppos < [llength $liste]} {incr ppos} {

  		set e "[lindex $liste $ppos]"

  		#Preis gefunden
          	if {[regexp "EUR" $e] && ![regexp "strike" $e]} {

  			#Nicht mehr vorhanden
          		if {[regexp "Anbieter versendet in" [lrange $liste $pos [llength $liste]]]} {

  				set beschr " (Nicht mehr im Angebot)"

  			#Artikel noch im Angebot
          		} else {

          			#Aktuellen Preis parsen
          			set preis ""
         				for {set i [string length $e]} {[string index $e $i]!=" "} {incr i -1} {
          				set preis "[string index $e $i]$preis"
          			}
                          	regsub -all "," $preis "." preis

  				#Ggf. Tiefpreis/Höchstpreis suchen
                                 	set pos [lsearch $data $name]
  				if {$pos != -1} {

                                          set maxprice [lindex $data [expr $pos+2]]

                                          #Ausgabe anpassen
         					if {$preis > $maxprice} {
          					set maxprice $preis
          				}

          			} else {
          				set maxprice $preis
          			}

          			#Ausgabe beabeiten
          			set ausg_preis $preis
          			set ausg_diff  [expr $maxprice - $preis]
          		}

          		#Ausgabe
          		.t config -state normal
                          .t insert end "[adjust $ausg_preis 0] \t [adjust $ausg_diff 1] \t "
                          set start [.t index insert]
                          .t insert end "$name $beschr\n"
                          set ende [.t index insert]
                          .t tag add $name $start $ende
                          .t config -state disable

          		break
          	}
          }

          if {$ppos >= [llength $liste]} {
          	.t config -state normal
          	set leer ""
  		.t insert end "\t - \t\t - \t "
  		set start [.t index insert]
  		.t insert end "$name $beschr\n"
  		set ende [.t index insert]
 		.t tag add $name $start $ende
  		.t config -state disable
          }

        	append Text "__"
        	append Text "$maxprice"
        	append Text "__"

        	return $Text
  }

  #Artikel-Liste
  set articles {
      "www.amazon.de/exec/obidos/ASIN/B0004MFRJI/qid%3D1096670148/sr%3D2-1/ref%3Dsr_2_11_1/302-6026851-5502444/"
  	"www.amazon.de/exec/obidos/ASIN/B00004RYU5/ref%3Dlm_lb_6/028-9477531-1550951/"
      "www.amazon.de/exec/obidos/ASIN/B0001FXAH4/qid=1101243171/sr=1-1/ref=sr_1_10_1/302-6026851-5502444/"
      "www.amazon.de/exec/obidos/ASIN/B0001M0LMO/qid=1101243417/sr=2-2/ref=sr_2_11_2/302-6026851-5502444/"
      "www.amazon.de/exec/obidos/ASIN/B00004RYW0/qid%3D1062917882/sr%3D1-5/ref%3Dsr_1_27_5/302-6026851-5502444/"
  	"www.amazon.de/exec/obidos/ASIN/B00004RYLU/qid%3D1062917882/sr%3D2-2/ref%3Dsr_2_27_2/302-6026851-5502444/"
  	"www.amazon.de/exec/obidos/ASIN/B00004RYBY/qid=1101242484/sr=2-1/ref=sr_2_11_1/302-6026851-5502444/"
  	"www.amazon.de/exec/obidos/ASIN/B00005AXLR/ref%3Dpd_sr_ec_ir_d/302-6026851-5502444/"
  	"www.amazon.de/exec/obidos/ASIN/B00067GJGG/qid=1104449708/sr=1-1/ref=sr_1_10_1/302-9588051-5342406/"
  	"www.amazon.de/exec/obidos/ASIN/B0002EHDXG/qid=1101243617/sr=2-1/ref=sr_2_11_1/302-6026851-5502444/"
      "www.amazon.de/exec/obidos/ASIN/B00098FL2A/028-9910571-4745352/"
      "www.amazon.de/exec/obidos/ASIN/B0001N5G4G/qid=1110632947/sr=8-1/ref=pd_ka_0/028-9564831-0624511/"
	"www.amazon.de/exec/obidos/ASIN/B00008IXLL/qid=1129229700/sr=1-9/ref=sr_1_11_9/302-4429322-2724062/"
	"www.amazon.de/exec/obidos/ASIN/B0000C6JTF/qid=1129229188/sr=1-3/ref=sr_1_11_3/302-4429322-2724062/"
	"www.amazon.de/exec/obidos/ASIN/B00006JIIY/qid=1129229322/sr=1-21/ref=sr_1_2_21/302-4429322-2724062/"
	"www.amazon.de/exec/obidos/ASIN/B0006553UG/qid=1129229110/sr=2-2/ref=sr_2_11_2/302-4429322-2724062/"
	"www.amazon.de/exec/obidos/ASIN/B00008UAQ8/qid=1139087592/sr=8-1/ref=sr_8_xs_ap_i1_xgl/302-8976567-0305660/"
	"www.amazon.de/exec/obidos/ASIN/B000B8QF14/qid=1132851838/sr=8-1/ref=sr_8_xs_ap_i1_xgl/028-6520835-4034169/"
	"www.amazon.de/exec/obidos/ASIN/B000A6M9Q2/qid=1132854652/sr=8-1/ref=pd_ka_1/028-6520835-4034169/"
	"www.amazon.de/exec/obidos/ASIN/B00066VMC8/ref=br_lf_d_18/028-5264662-7040534/"
	"www.amazon.de/exec/obidos/ASIN/B00009RBJX/ref=br_lf_d_13/028-0509694-1481352/"
	"www.amazon.de/exec/obidos/ASIN/B0001E3I72/ref=br_lf_d_16/028-0509694-1481352/"
	"www.amazon.de/exec/obidos/ASIN/B000062V8I/ref=br_lf_d_1/028-0509694-1481352/"
	"www.amazon.de/exec/obidos/ASIN/B00007KSS0/qid=1137766876/sr=8-2/ref=pd_ka_2/303-1842502-5623423/"
  }

  #Widgets
  text .t -height [expr [llength $articles]+2] -width 100 -wrap none
  pack .t -expand true -fill both

  #Checken
  catch {
  set Text ""
  for {set i 0} {$i<[llength $articles]} {incr i} {

  	set url [lindex $articles $i]

  	if {[regexp "www." $url]} {
  		append Text [GetArticle $url]
  	} else {
  		.t insert end "\n$url\n"
  	}
  }

  #Daten speichern
  saveFile $Text

  #Hyperlinks
  .t config -state normal
  set Text [split $Text "__"]

  for {set i 0} {$i<[llength $Text]} {incr i 4} {

  	set name [lindex $Text $i]
  	.t tag configure $name -underline 1 -foreground blue

  	.t tag bind $name <Button1-ButtonRelease> {
  	      set j [.t index insert]
          	set j [split $j "."]
        	set j [lindex $j 0]
          	set url [lindex $articles [expr $j-1]]
  		catch {exec explorer.exe "http://$url"}
  	}
  }

  #Ende
  .t insert end "\n-- Check abgeschlossen --"
}
