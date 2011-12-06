-- Funktion zur Berechnung des GgT sowie des kgV von zwei Zahlen
-- © ® Stephan Behnke ™
-- Homepage: www.stephan.behnke.de.vu
-- E-Mail: stephan.behnke@gmx.net


---------
-- GGT --
---------

-- Definitionsbereich
ggt :: Int -> Int -> Int


-- Defintion
ggt a b
	| a < b   = ggt (b-a) a
	| a > b   = ggt (a-b) b
	| a == b  = a



---------
-- KGV --
---------

-- Definitionsbereich
kgv  :: Int -> Int -> Int
kgv2 :: Int -> Int -> Int -> Int -> Int


-- Definition
kgv a b = kgv2 a b a b

kgv2 a b c d
	| a < b   = kgv2 (a+c) b c d
	| a > b   = kgv2 a (b+d) c d
	| a == b  = a
