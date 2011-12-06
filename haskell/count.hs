-- Grundlegende Listenanwendungen
-- © ® Stephan Behnke ™
-- Homepage: www.stephan.behnke.de.vu
-- E-Mail: stephan.behnke@gmx.net


-- elemNenn - Gibt die Anzahl der Vorkommen eines Elementes zurück
elemNenn :: Int -> [Int] -> Int
elemNenn _ [] = 0
elemNenn z (x:xs)
	| x == z    = 1 + elemNenn z xs
	| otherwise = elemNenn z xs


-- elemEntf - Entfernt ein Element komplett aus einer Liste
elemEntf :: Int -> [Int] -> [Int]
elemEntf _ [] = []
elemEntf z (x:xs)
	| x == z    = elemEntf z xs
	| otherwise = x : elemEntf z xs


-- Erstellt aus einer Liste eine neue, in der nur die einzigartigen Elemente vorkommen
unique :: [Int] -> [Int]
unique [] = []
unique (x:xs)
	| elemNenn x xs > 0 = unique (elemEntf x xs)
	| otherwise         = x : unique xs
