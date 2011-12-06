-- Definiert einen Akzeptor zur Überprüfung der Teilbarkeit durch 4



-- Datentypdefinitionen
data X = W | F
	deriving(Eq)

data Z = A | Z1 | Z0 | Z00 | Z01 | Z10 | Z11
	deriving(Eq)

type Teilbarkeit = ([X], [Z], Z, Z, (X->Z->Z))



-- Ausgabefunktionen
instance Show X where
	show(W) = "1"
	show(F) = "0"

instance Show Z where
	show(A)   = "0"
	show(Z0)  = "0"
	show(Z1)  = "1"
	show(Z00) = "00"
	show(Z01) = "01"
        show(Z10) = "10"
        show(Z11) = "11"


-- Überführungsfunktion Delta
delta :: X -> Z -> Z
delta W A   = Z1
delta W Z0  = Z01
delta W Z1  = Z11
delta W Z00 = Z01
delta W Z01 = Z11
delta W Z10 = Z01
delta W Z11 = Z11
delta F A   = Z0
delta F Z0  = Z00
delta F Z1  = Z10
delta F Z00 = Z00
delta F Z01 = Z10
delta F Z10 = Z00
delta F Z11 = Z10

-- Testfunktion
test :: Teilbarkeit -> [X] -> IO ()
test f@(eing, zust, z, vgl, d) list
	| testen f list == vgl 	= putStr "Zahl ist durch 4 teilbar."
	| otherwise		= putStr "Zahl ist nicht durch 4 teilbar."

testen :: Teilbarkeit -> [X] -> Z
testen (eing, zust, z, vgl, d) [] = z
testen (eing, zust, z, vgl, d) (x:xs)
	| elem x eing = testen (eing, zust, d x z, vgl, d) xs
	| otherwise   = testen (eing, zust, z, vgl, d) xs

-- Definition eines Akzeptors
t = ([W,F], [A,Z0,Z00,Z01,Z10,Z11], A, Z00, delta)
