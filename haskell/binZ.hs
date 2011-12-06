-- Binäre, ganze Zahl
-- © ® Stephan Behnke ™
-- Homepage: www.stephan.behnke.de.vu
-- E-Mail: stephan.behnke@gmx.net


module BinZ where


-- Binäre, natürliche Zahl importieren
import "binN.hs"


-------------------
-- Spezifikation --
-------------------

convertZ    :: BinZ	  -> Int	    -- Wandelt eine Binärzahl in Int um
wechsel     :: Vorzeichen -> Vorzeichen	    -- Vorzeichen wechseln
makeBinZ    :: [Char] 	  -> BinZ	    -- Binärzahl aus String erstellen
zahlN       :: BinZ 	  -> BinN	    -- Natürliche Zahl aus ganzer Binärzahl entnehmen
zweiK       :: BinZ 	  -> BinZ	    -- 2-Komplement bilden
verkuerzenZ :: BinZ 	  -> BinZ	    -- Führende Nullen aus Zahl entfernen
gegenzahlZ  :: BinZ 	  -> BinZ	    -- Gegenzahl bilden (inverse Element)
incrZ	    :: BinZ	  -> BinZ	    -- Zahl um 1 erhöhen
decrZ	    :: BinZ	  -> BinZ	    -- Zahl um 1 verringern
multZ       :: BinZ 	  -> BinZ -> BinZ   -- 2 ganze Binärzahlen multiplizieren
subZ        :: BinZ 	  -> BinZ -> BinZ   -- 2 ganze Binärzahlen subtrahieren
addZ        :: BinZ 	  -> BinZ -> BinZ   -- 2 ganze Binärzahlen addieren
groesserZ   :: BinZ       -> BinZ -> BinNr  -- Ermittelt größere von 2 Zahlen
betragZ     :: BinZ	  -> BinZ	    -- Betrag einer ganzen Binärzahl bilden


---------
-- ADT --
---------

-- Vorzeichen der Binärzahl
data Vorzeichen = P | M
	deriving(Eq)

-- Binäre, ganze Zahl
data BinZ = EZ | Z Vorzeichen BinN
	deriving(Eq)


--------
-- IO --
--------

-- Ausgabefunktion
instance Show BinZ where
	show (EZ) = ""
	show (Z P n) = (show n)
	show (Z M n) = "-" ++ (show n)

-- Einlesefunktion
makeBinZ [] = EZ
makeBinZ (x:xs)
	| x == '+'  = (Z (P) (makeBinN xs))
	| x == '-'  = (Z (M) (makeBinN xs))
	| otherwise = (Z (P) (makeBinN (x:xs)))


------------------
-- BERECHNUNGEN --
------------------

-- Vorzeichen wechseln
wechsel (P) = M
wechsel (M) = P

-- Betrag bilden
betragZ (Z v n) = (Z P n)

-- Zahl umwandeln
convertZ (EZ)    = error "Zahl nicht definiert!"
convertZ (Z P n) = convertN n
convertZ (Z M n) = (-1) * convertN n

-- Größere Zahl ermitteln
groesserZ (Z M n1) (Z M n2) = (-|) (groesserN n1 n2)
groesserZ (Z P n1) (Z P n2) = groesserN n1 n2
groesserZ (Z P n1) (Z M n2) = L
groesserZ (Z M n1) (Z P n2) = O

-- Halbierung
halbierenZ (Z v n) = (Z v (halbierenN n))

-- Verdopplung
verdoppelnZ (Z v n) = (Z v (verdoppelnN n))

-- Zahl erhöhen
incrZ z = addZ z (Z P (N (EN) L))

-- Zahl verringern
decrZ z = subZ z (Z P (N (EN) L))

-- ggT ermitteln
ggtZ n1@(Z _ (N (z1) O)) n2@(Z _ (N (z2) O))  = ggtZ' (betragZ n1) (betragZ n2) (Z P (N (EN) L))
ggtZ n1 n2
	| firstN (zahlN n2) == O = ggtZ'' (betragZ n2) (betragZ n1)
	| otherwise	 	 = ggtZ'' (betragZ n1) (betragZ n2)

ggtZ' n1@(Z _ (N _ O))   n2@(Z _ (N _ O)) g = ggtZ' (halbierenZ n1) (halbierenZ n2) (verdoppelnZ g)
ggtZ' n1 n2 g				    = multZ (ggtZ'' n1 n2) g

ggtZ'' (Z _ (N (EN) O)) n2 = n2
ggtZ'' n1@(Z _ (N _ O)) n2 = ggtZ'' (halbierenZ n1) n2
ggtZ'' n1 n2
	| groesserZ n2 n1 == L	= ggtZ'' n2 n1
	| otherwise		= ggtZ'' (halbierenZ (subZ n1 n2)) n2

-- Gegenzahl bilden
gegenzahlZ (EZ)    = error "Keine Ziffern vorhanden"
gegenzahlZ (Z v n) = (Z (wechsel v) n)

-- Führende Nullen eleminieren
verkuerzenZ (EZ) = error "Keine Ziffern vorhanden"
verkuerzenZ (Z v n) = (Z v (verkuerzenN n))

-- Zweierkomplement bilden
zweiK (EZ)    = EZ
zweiK (Z v n) = (Z (wechsel v) (addN (einK n) (N (EN) L)))

-- Natürlichen Teil der ganzen Binärzahl zurückgeben
zahlN (EZ)    = error "Keine Zahl erstellbar"
zahlN (Z v n) = n

-- Addition binärer, ganzer Zahlen
addZ (Z P n1) (Z P n2)	     = (Z P (addN n1 n2))
addZ (Z M n1) (Z M n2)	     = (Z M (addN n1 n2))
addZ z1@(Z M n1) z2@(Z P n2) = subZ z2 (gegenzahlZ z1)
addZ z1@(Z P n1) z2@(Z M n2) = subZ z1 (gegenzahlZ z2)
addZ _ _ 		     = error "Operanten nicht definiert"

-- Subtraktion binärer, ganzer Zahlen
subZ z1@(Z M n1) z2@(Z P n2) = gegenzahlZ (addZ (gegenzahlZ z1) z2)
subZ z1@(Z P n1) z2@(Z M n2) = addZ z1 (gegenzahlZ z2)
subZ z1@(Z M n1) z2@(Z M n2) = subZ (gegenzahlZ z2) (gegenzahlZ z1)
subZ z1@(Z P n1) z2@(Z P n2) = e
	where
		e
			| laengeN (zahlN k) == laengeN s = verkuerzenZ (zweiK (Z P s))
			| otherwise			 = verkuerzenZ (Z P (tailN s))
		s = addN (zahlN k) (snd t)
	  	k = zweiK (Z P (fst t))
                t = angleichenN n2 n1
subZ _ _ = error "Operanten nicht definiert"

-- Multiplikation binärer, ganzer Zahlen
multZ z1@(Z v1 n1) z2@(Z v2 n2)
	| v1 == v2  = (Z P (multN n1 n2))
	| otherwise = (Z M (multN n1 n2))
multZ _ _  = error "Operanten nicht definiert"
