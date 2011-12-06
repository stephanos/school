-- Abstrakter Datentyp Josephus-Kreis
-- © ® Stephan Behnke ™
-- Homepage: www.stephan.behnke.de.vu
-- E-Mail: stephan.behnke@gmx.net


-- Datentyp definieren
data Josephus = E | M Int (Josephus)


-- Ausgabefunktion
instance Show Josephus where
	show E = ""
	show (M n (k)) = show(n) ++ " " ++ show(k)

-- Kreis erstellen
kreis :: Int -> Josephus
kreis n = kreis' 1 (n+1)

kreis' :: Int -> Int -> Josephus
kreis' a n
	| a == n    = E
	| otherwise = M a (kreis' (a+1) n)

-- Person aus einem Kreis entfernen
entfernen :: Josephus -> Int -> Josephus
entfernen E x = E
entfernen (M n (k)) x
	| n == x    = k
	| otherwise = (M n (entfernen k x))

-- Reduzieren der Personen im Kreis
abzaehlen :: Josephus -> Josephus -> Int -> Int -> String
abzaehlen (M n (E)) _ _ _ = " -> Es ueberlebt die " ++ show(n)
abzaehlen j E a x = abzaehlen j j a x
abzaehlen j (M n (k)) a x
	| a == x    = show(j) ++ "\n" ++ abzaehlen (entfernen j n) k 0 x
	| otherwise = abzaehlen j k (a+1) x

-- Josephus-Kreis ausprobieren
josephus :: Int -> Int -> IO ()
josephus n x = putStr (abzaehlen k k 0 x)
	where	k = (kreis n)
