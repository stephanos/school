-- Bin�re, rationale Zahl
-- � � Stephan Behnke �
-- Homepage: www.stephan.behnke.de.vu
-- E-Mail: stephan.behnke@gmx.net


module BinQ where


-- Bin�re, ganze Zahl importieren
import "binZ.hs"
import "binN.hs"


-------------------
-- Spezifikation --
-------------------

convertQ  :: BinQ   -> Float			-- Wandelt eine Bin�rzahl in Float
makeBinQ  :: [Char] -> BinQ			-- Bin�rzahl aus String erstellen
anpassenQ :: BinQ   -> BinQ			-- Vorzeichen des Bruchs bearbeiten
addQ      :: BinQ   -> BinQ  -> BinQ		-- 2 rationale Bin�rzahlen addieren
subQ      :: BinQ   -> BinQ  -> BinQ		-- 2 rationale Bin�rzahlen subtrahieren
multQ     :: BinQ   -> BinQ  -> BinQ		-- 2 rationale Bin�rzahlen multiplizieren
divQ      :: BinQ   -> BinQ  -> BinQ		-- 2 rationale Bin�rzahlen dividieren
divQ'     :: BinZ   -> BinZ  -> BinZ  -> BinZ	-- 2 ganze Bin�rzahlen dividieren
zaehlerQ  :: BinQ   -> BinZ			-- Z�hler von Bruch zur�ckgeben
nennerQ   :: BinQ   -> BinZ			-- Nenner von Bruch zur�ckgeben
betragQ   :: BinQ   -> BinQ			-- Bildet Betrag einer rationalen Bin�rzahl
kuerzenQ  :: BinQ   -> BinQ			-- Bruch k�rzen


---------
-- ADT --
---------

-- Bin�re, rationale Zahl
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

-- Z�hler zur�ckgeben
zaehlerQ (Q (z, n)) = z
zaehlerQ _ = error "Zahl nicht definiert!"

-- Nenner zur�ckgeben
nennerQ (Q (z, n)) = n
nennerQ _ = error "Zahl nicht definiert!"

-- Betrag bilden
betragQ (Q (z, n)) = Q (betragZ z, betragZ n)

-- Bruch k�rzen
kuerzenQ (Q (z, n)) = anpassenQ (Q (fst k, snd k))
	where	t  = ggtZ z n
		e  = (Z P (N (EN) L))
		k
			| t == e    = (z, n)
			| otherwise = (divQ' z t e, divQ' n t e)

-- Ganzzahlige Division bin�rer, ganzer Zahlen
divQ' z@(Z v _) t f
	| z == multZ t f  =  f
	| otherwise       =  r
		where r
			| v == P    = divQ' z t (incrZ f)
			| otherwise = divQ' z t (decrZ f)

-- Addition bin�rer, rationaler Zahlen
addQ (Q (z1, n1)) (Q (z2, n2)) = kuerzenQ (Q (addZ (multZ z1 n2) (multZ z2 n1), multZ n1 n2))
addQ _ _  = error "Operant(en) nicht definiert!"

-- Subtraktion bin�rer, rationaler Zahlen
subQ (Q (z1, n1)) (Q (z2, n2)) = kuerzenQ (Q (subZ (multZ z1 n2) (multZ z2 n1), multZ n1 n2))
subQ _ _  = error "Operant(en) nicht definiert!"

-- Multiplikation bin�rer, rationaler Zahlen
multQ (Q (z1, n1)) (Q (z2, n2)) = kuerzenQ (Q (multZ z1 z2, multZ n1 n2))
multQ _ _  = error "Operant(en) nicht definiert!"

-- Division bin�rer, rationaler Zahlen
divQ (Q (z1, n1)) (Q (z2, n2)) = kuerzenQ (Q (multZ z1 n2, multZ n1 z2))
divQ _ _  = error "Operant(en) nicht definiert!"
