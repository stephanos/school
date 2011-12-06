-- Binäre, rationale Zahl
-- © ® Stephan Behnke ™
-- Homepage: www.stephan.behnke.de.vu
-- E-Mail: stephan.behnke@gmx.net


module BinQ where


-- Binäre, ganze Zahl importieren
import "binZ.hs"
import "binN.hs"


-------------------
-- Spezifikation --
-------------------

convertQ  :: BinQ   -> Float			-- Wandelt eine Binärzahl in Float
makeBinQ  :: [Char] -> BinQ			-- Binärzahl aus String erstellen
anpassenQ :: BinQ   -> BinQ			-- Vorzeichen des Bruchs bearbeiten
addQ      :: BinQ   -> BinQ  -> BinQ		-- 2 rationale Binärzahlen addieren
subQ      :: BinQ   -> BinQ  -> BinQ		-- 2 rationale Binärzahlen subtrahieren
multQ     :: BinQ   -> BinQ  -> BinQ		-- 2 rationale Binärzahlen multiplizieren
divQ      :: BinQ   -> BinQ  -> BinQ		-- 2 rationale Binärzahlen dividieren
divQ'     :: BinZ   -> BinZ  -> BinZ  -> BinZ	-- 2 ganze Binärzahlen dividieren
zaehlerQ  :: BinQ   -> BinZ			-- Zähler von Bruch zurückgeben
nennerQ   :: BinQ   -> BinZ			-- Nenner von Bruch zurückgeben
betragQ   :: BinQ   -> BinQ			-- Bildet Betrag einer rationalen Binärzahl
kuerzenQ  :: BinQ   -> BinQ			-- Bruch kürzen


---------
-- ADT --
---------

-- Binäre, rationale Zahl
data BinQ = EQ | Q (BinZ, BinZ)
	deriving(Eq)


--------
-- IO --
--------

-- Ausgabefunktion
instance Show BinQ where
	show (EQ) = ""
	show (Q (z, n)) = (show z) ++ "/" ++ (show n)

-- Einlesefunktion
makeBinQ [] = EQ
makeBinQ l
	| zahlN n == (N EN O) = error "Nenner ist Null!"
	| otherwise = (Q (z, n))
		where	sz = takeWhile ((/=) '/') l
			sn
				| length sz == length l = "L"
				| otherwise = tail (dropWhile ((/=) '/') l)
			z = verkuerzenZ (makeBinZ sz)
			n = verkuerzenZ (makeBinZ sn)


------------------
-- BERECHNUNGEN --
------------------

-- Zahl umwandeln
convertQ (EQ)      = error "Zahl nicht definiert!"
convertQ (Q (z,n)) = fromInt(convertZ z) / fromInt(convertZ n)

-- Vorzeichen anpassen
anpassenQ (Q ((Z _ (N (EN) O)), (Z _ n))) = Q ((Z P (N (EN) O)), (Z P n))
anpassenQ (Q ((Z P z1), (Z M z2))) = Q ((Z M z1), (Z P z2))
anpassenQ (Q ((Z M z1), (Z M z2))) = Q ((Z P z1), (Z P z2))
anpassenQ q@(Q (z, n)) = q
anpassenQ _ = error "Zahl nicht definiert!"

-- Zähler zurückgeben
zaehlerQ (Q (z, n)) = z
zaehlerQ _ = error "Zahl nicht definiert!"

-- Nenner zurückgeben
nennerQ (Q (z, n)) = n
nennerQ _ = error "Zahl nicht definiert!"

-- Betrag bilden
betragQ (Q (z, n)) = Q (betragZ z, betragZ n)

-- Bruch kürzen
kuerzenQ (Q (z, n)) = anpassenQ (Q (fst k, snd k))
	where	t  = ggtZ z n
		e  = (Z P (N (EN) L))
		k
			| t == e    = (z, n)
			| otherwise = (divQ' z t e, divQ' n t e)

-- Ganzzahlige Division binärer, ganzer Zahlen
divQ' z@(Z v _) t f
	| z == multZ t f  =  f
	| otherwise       =  r
		where r
			| v == P    = divQ' z t (incrZ f)
			| otherwise = divQ' z t (decrZ f)

-- Addition binärer, rationaler Zahlen
addQ (Q (z1, n1)) (Q (z2, n2)) = kuerzenQ (Q (addZ (multZ z1 n2) (multZ z2 n1), multZ n1 n2))
addQ _ _  = error "Operant(en) nicht definiert!"

-- Subtraktion binärer, rationaler Zahlen
subQ (Q (z1, n1)) (Q (z2, n2)) = kuerzenQ (Q (subZ (multZ z1 n2) (multZ z2 n1), multZ n1 n2))
subQ _ _  = error "Operant(en) nicht definiert!"

-- Multiplikation binärer, rationaler Zahlen
multQ (Q (z1, n1)) (Q (z2, n2)) = kuerzenQ (Q (multZ z1 z2, multZ n1 n2))
multQ _ _  = error "Operant(en) nicht definiert!"

-- Division binärer, rationaler Zahlen
divQ (Q (z1, n1)) (Q (z2, n2)) = kuerzenQ (Q (multZ z1 n2, multZ n1 z2))
divQ _ _  = error "Operant(en) nicht definiert!"
