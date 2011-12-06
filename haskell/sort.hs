-- Sortieralgorithmen in Haskell
-- © ® Stephan Behnke ™
-- Homepage: www.stephan.behnke.de.vu
-- E-Mail: stephan.behnke@gmx.net


{--
 *************
 * Quicksort *
 *************
 Verfahren:
 	- eine Liste wird in zwei Teillisten aufgeteilt
 	- die einzelnen Elemente werden dabei den Teillisten so zugeordnet, dass
 	  alle Elemente des linken Teils kleiner als die des rechten Teils sind
 	- auf die neu erhaltenen Teillisten wird wieder Quicksort angewandt
--}

-- Funktion qsort
qsort :: Ord a => [a] -> [a]			-- Argument: 1 Liste, Ergebnis: 1 Liste
qsort [] = []					-- Sonderfall: leere Liste wird einer leeren Liste zugeordnet
qsort (x:xs) = qsort [y | y <- xs, y < x]	-- linke Teilliste durch qsort sortieren (Elemente kleiner als x)
		++ [x]				-- Pivot-Element
		++ qsort [y | y <- xs, y >= x]	-- rechte Teilliste durch qsort sortieren (Elemente größer als x)


{--
 **************
 * Bubblesort *
 **************
 Verfahren:
 	- die Liste wird einmal ganz durchlaufen, wobei das aktuelle
 	  Element mit dem nächsten verglichen (und ggf. vertauscht) wird,
 	  so dass das größere auf der rechten Seite steht
 	- dadurch rutscht das größte Element auf die letzte Position der Liste
 	- anschließend wird der Algorithmus wieder auf die Liste ohne das
 	  letzte Element angewendet
--}

-- Funktion bubble
-- (Sortiert das größte Element der Liste an ihr Ende)
bubble :: Ord a => [a] -> [a]		-- Argument: 1 Liste, Ergebnis: 1 Liste
bubble []  = []				-- Sonderfall: leere Liste wird einer leeren Liste zugeordnet
bubble [x] = [x]			-- Sonderfall: Liste mit einem Element x wird Liste mit einem Element x zugeordnet
bubble (x:y:xs) 			-- Liste in ersten 2 Elemente x & y sowie den Rest (xs) teilen, Unterscheidung durch Wächter:
	| x < y     = x : bubble (y:xs)		-- wenn x < y, x an Listenanfang schreiben, mit y:xs rekursiv weiter aufrufen
	| otherwise = y : bubble (x:xs) 	-- wenn x > y, y an Listenanfang schreiben, mit x:xs rekursiv weiter aufrufen

-- Funktion bsort
bsort :: Ord a => [a] -> [a]		-- Argument: 1 Liste, Ergebnis: 1 Liste
bsort [] = []				-- Sonderfall: leere Liste wird einer leeren Liste zugeordnet
bsort xs = bsort (init ys) ++ [last ys]	-- letztes Element von ys ans Ende und neuer Aufruf der Teilliste ohne letztes Element
		where ys = bubble xs	-- lokale Variable ys als Ergebnis der Funktion bubble definieren


{--
 *************
 * Mergesort *
 *************
 Verfahren:
 	- eine Liste wird solange rekursiv in Teillisten eingeteilt bis
 	  diese jeweils weniger als 2 Elemente besitzen
 	- dann werden diese Teillisten in richtiger Reihenfolge durchmischt,
 	  wobei man sich zu Nutze macht, dass jede Teilliste selbst
 	  bereits sortiert ist
--}

-- Funktion merge
-- (Mischt 2 sortierte Listen zu einer zusammen)
merge :: Ord a => [a] -> [a] -> [a]		-- Argumente: 2 Listen, Ergebnis: 1 Liste
merge [] [] = []				-- Sonderfall: 2 leeren Listen wird einer leeren Liste zugeordnet
merge xs [] = xs				-- Sonderfall: ist rechtes Argument eine leere Liste wird das linke Argument zugeordnet
merge [] ys = ys				-- Sonderfall: ist linkes Argument eine leere Liste wird das rechte Argument zugeordnet
merge (x:xs) (y:ys)				-- Listen in Kopf (x bzw. y) und Schwanz (xs bzw. ys) unterteilen, Unterscheidung durch Wächter:
	| x < y		= x:merge xs (y:ys)		-- wenn x < y, dann x an Listenanfang und Funktionsaufruf mit xs und rechter Liste
	| otherwise	= y:merge (x:xs) ys		-- wenn x > y, dann y an Listenanfang und Funktionsaufruf mit ys und linker Liste

-- Funktion msort
msort :: Ord a => [a] -> [a]			-- Argument: 1 Liste, Ergebnis: 1 Liste
msort [] = []					-- Sonderfall: leere Listen wird einer leeren Liste zugeordnet
msort xs
	| length xs < 2	= xs                                           	-- wenn Länge d. Liste < 2, dann ist Liste das Ergebnis;
	| otherwise	= merge (msort (take h xs)) (msort (drop h xs)) -- andernfalls werden 2 Teillisten, welche durch
				where h = div (length xs) 2		-- msort sortiert wurden, gemischt


{--
 **************
 * Insertsort *
 **************
  Verfahren:
 	- es wird vom letzten Element der Liste als neue Liste ausgegangen
 	- Stück für Stück wird jedes Element der ursprünglichen
 	  Liste in die neue Liste hinzugefügt, so dass die kleineren vor die
 	  größeren Elemente gestellt werden
--}

-- Funktion insert
-- (Fügt ein Element in einer Liste ein)
insert :: Ord a => a -> [a] -> [a]		-- Argument: Typ a sowie 1 Liste, Ergebnis: 1 Liste
insert item [] = [item]				-- Sonderfall: einer leeren Liste wird eine Liste mit dem Element item zugeordnet
insert item (x:xs)				-- Liste wird in Kopf und Schwanz eingeteilt, Unterscheidung durch Wächter:
	| item <= x  =	item:x:xs			-- wenn item <= x, dann ist Ergebnis die Liste mit Argument item am Anfang
	| otherwise  =  x:(insert item xs)		-- andernfalls Funktion für den Schwanz der Liste aufrufen, Kopf am Anfang

-- Funktion isort
isort :: Ord a => [a] -> [a]			-- Argument: 1 Liste, Ergebnis: 1 Liste
isort []     = []				-- Sonderfall: leere Liste wird einer leeren Liste zugeordnet
isort (x:xs) = insert x (isort xs)		-- Kopf der Liste wird in den nach Insertsort sortieren Rest eingefügt


{--
 **************
 * Selectsort *
 **************
 Verfahren:
 	- es wird das kleinste Element der Liste gesucht
 	- dieses wird an den Anfang der Liste gestellt
 	  und aus der ursprünglichen Position entfernt
 	- daraufhin wiederholt sich der Vorgang für die Teilliste
--}

-- Funktion remove
-- (Entfernt ein Element aus einer Liste)
remove :: Ord a => [a] -> a -> [a]		-- Argument: 1 Liste und Typ a, Ergebnis: 1 Liste
remove [] x = []				-- Sonderfall: im Falle einer leeren Liste wird eine leere Liste zugeteilt
remove (x:xs) item				-- Liste wird in Kopf und Schwanz unterteilt, Unterscheidung durch Wächter:
	| x == item  =  xs				-- wenn Kopf dem gesuchten item entspricht, ist der Rest der Liste das Ergebis
	| otherwise  =  x:(remove xs item)              -- andernfalls Funktion für Rest der Liste aufrufen, ohne den Kopf

-- Funktion ssort
ssort :: Ord a => [a] -> [a]			-- Argument: 1 Liste, Ergebnis: 1 Liste
ssort [] = []					-- Sonderfall: leere Liste wird einer leeren Liste zugeordnet
ssort (x:xs) = min:(ssort (remove (x:xs) min))		-- kleinestes Element der Liste an den Anfang der neuen und
		where min = minimum (x:xs)		-- Funktion mit dem Rest der Liste erneut aufrufen



-- Testliste
l = [9,3,7,5,4,1,8,6,2,0]
