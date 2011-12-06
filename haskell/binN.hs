-- Binäre, natürliche Zahl
-- © ® Stephan Behnke ™
-- Homepage: www.stephan.behnke.de.vu
-- E-Mail: stephan.behnke@gmx.net


module BinN where


-------------------
-- Spezifikation --
-------------------

(/\) 	    :: BinNr  -> BinNr -> BinNr				-- Und-Verknüpfung
(\/) 	    :: BinNr  -> BinNr -> BinNr				-- Oder-Verknüpfung
ha 	    :: BinNr  -> BinNr -> (BinNr, BinNr)		-- Halbaddierer
va 	    :: BinNr  -> BinNr -> BinNr -> (BinNr, BinNr)	-- Volladdierer

convertN    :: BinN   -> Int			-- Wandelt eine Binärzahl in Int um
convertN'   :: BinN   -> Int   -> Int		-- Wandelt eine Binärzahl stellenweise in Int um
makeBinN    :: [Char] -> BinN			-- Binärzahl aus String erstellen
laengeN     :: BinN   -> BinN			-- Länge der Binärzahl ermitteln
lastN 	    :: BinN   -> BinNr                  -- Ziffer an höchster Stelle zurückgeben
tailN 	    :: BinN   -> BinN			-- Schwanz, Binärzahl ohne höchste Stelle, zurückgeben
verkuerzenN :: BinN   -> BinN			-- Führende Nullen aus Zahl entfernen
angleichenN :: BinN   -> BinN  -> (BinN, BinN)	-- 2 Zahlen auf gleiche Länge bringen
angleichenN':: BinN   -> BinN  -> BinN		-- 1 Zahl auf Länge einer anderen bringen
groesserN   :: BinN   -> BinN  -> BinNr		-- Ermittelt größere von 2 ungleichlangen Zahlen
groesserN'  :: BinN   -> BinN  -> BinNr		-- Ermittelt größere von 2 gleichlangen Zahlen
einK 	    :: BinN   -> BinN			-- 1-Komplement bilden
addN 	    :: BinN   -> BinN  -> BinN		-- 2 natürliche Binärzahlen addieren
multN 	    :: BinN   -> BinN  -> BinN		-- 2 natürliche Binärzahlen multiplizieren
verdoppelnN :: BinN   -> BinN			-- Binärzahl verdoppeln
halbierenN  :: BinN   -> BinN			-- Binärzahl halbieren


---------
-- ADT --
---------

-- Binärnummer
data BinNr = O | L
	deriving(Show, Eq)

-- Binärzahl
data BinN = EN | N (BinN) BinNr
	deriving(Eq)


--------
-- IO --
--------

-- Ausgabefunktion
instance Show BinN where
	show (EN) = ""
	show (N (z) nr) = (show z) ++ (show nr)

-- Einlesefunktion
makeBinN [] = EN
makeBinN l
	| [x] == "L" = (N (makeBinN xs) (L))
	| [x] == "O" = (N (makeBinN xs) (O))
	| otherwise  = makeBinN xs
		where 	x  = last l
			xs = init l


-----------------
-- SCHALTUNGEN --
-----------------

-- Und-Schaltung
(/\) (L) (L) = L
(/\) _ _ = O

-- Oder - Schaltung
(\/) (O) (O) = O
(\/) _ _ = L

-- Verneinung
(-|) :: BinNr -> BinNr
(-|) O = L
(-|) L = O

-- Halbaddierer
ha a b = ((a /\ ((-|) b)) \/ (((-|) a) /\ b), a /\ b)

-- Volladdierer
va a b u = (fst su, snd ab \/ snd su)
	where 	ab = ha a b
		su = ha u (fst ab)


------------------
-- BERECHNUNGEN --
------------------

-- Addition binärer, natürlicher Zahlen
addN (EN) (EN) 			= EN
addN (N (z) nr) (EN) 		= (N (addN z EN) nr)
addN (EN) (N (z) nr) 		= (N (addN z EN) nr)
addN (N (z1) nr1) (N (z2) nr2)	= (N (addN z' z2) (fst s))
					where	s  = ha nr1 nr2
						z'
							| snd s == L = addN (N (EN) (snd s)) z1
							| otherwise  = z1

-- Längenberechnung
laengeN (EN) 	   = (N (EN) O)
laengeN (N (z) nr) = addN (N (EN) L) (laengeN z)

-- Zahl umwandeln
convertN (EN) = error "Zahl nicht definiert!"
convertN z    = convertN' z 0

convertN' (EN) _       = 0
convertN' (N (z) L)  p = 2^p + convertN' z (p+1)
convertN' (N (z) nr) p = convertN' z (p+1)

-- Größere Zahl ermitteln
groesserN n1 n2 = groesserN' (fst a) (snd a)
	where a = angleichenN n1 n2

groesserN' (EN) (EN) = O
groesserN' n1 n2
	| lastN n1 == L && lastN n2 == O  = L
	| lastN n1 == O && lastN n2 == L  = O
	| otherwise 			  = groesserN' (tailN n1) (tailN n2)

-- Einerkomplement bilden
einK (EN)	= EN
einK (N (n) L) = (N (einK n) O)
einK (N (n) O) = (N (einK n) L)

-- Stellenanzahl anpassen
angleichenN n1 n2 = (angleichenN' n1 n2, angleichenN' n2 n1)

angleichenN' (EN) (EN)    		= EN
angleichenN' (EN) (N (z) nr) 		= (N (angleichenN' (EN) z) O)
angleichenN' b@(N (z) nr) (EN)		= b
angleichenN' (N (z1) nr1) (N (z2) nr2)	= (N (angleichenN' (z1) z2) nr1)

-- Vorderstes Element ermitteln
lastN (EN) = error "Keine Ziffern vorhanden"
lastN (N (EN) nr) = nr
lastN (N (z) nr)  = lastN z

-- Hinterstes Element ermitteln
firstN (EN) = error "Keine Ziffern vorhanden"
firstN (N (z) nr)  = nr

-- Zahl ohne vorderste Ziffer zurückgeben
tailN (EN) = error "Keine Ziffern vorhanden"
tailN (N (EN) nr) = EN
tailN (N (z) nr)  = (N (tailN z) nr)

-- Führende Nullen eleminieren
verkuerzenN (EN) = error "Keine Ziffern vorhanden"
verkuerzenN n@(N (EN) nr) = n
verkuerzenN n@(N (z) nr)
	| lastN z == O = verkuerzenN (tailN n)
	| otherwise    = n

-- Halbierung
halbierenN EN = error "Zahl kann nicht halbiert werden"
halbierenN (N (EN) nr) 	= (N (EN) O)
halbierenN (N (z) nr) 	= z

-- Verdopplung
verdoppelnN b = (N (b) O)

-- Multiplikation binärer, natürlicher Zahlen
multN (N (z) nr) (N (EN) O) = EN
multN a@(N (z1) nr1) b@(N (z2) nr2)
	| nr2 == L  = addN a m
	| otherwise = m
		where m = multN (verdoppelnN a) (halbierenN b)