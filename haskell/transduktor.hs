-- Definiert einen Transduktor für Fahrkarten
-- © ® Stephan Behnke ™
-- Homepage: www.stephan.behnke.de.vu
-- E-Mail: stephan.behnke@gmx.net



-- Datentypdefinitionen
data X = H | G
	deriving(Eq)

data Y = F | KF

data Z = Z_N | Z_H | Z_G | Z_GH | Z_GG

type Fahrkartenautomat = ([X], [Y], [Z], Z, (X->Z->Z), (X->Z->Y))



-- Ausgabefunktionen
instance Show X where
	show(H) = "0.5 Euro"
	show(G) = "1.0 Euro"

instance Show Y where
	show(F)  = "Fahrkarte"
	show(KF) = "Keine Fahrkarte"

instance Show Z where
	show(Z_N)  = "0.0 Euro eingeworfen"
	show(Z_H)  = "0.5 Euro eingeworfen"
	show(Z_G)  = "1.0 Euro eingeworfen"
	show(Z_GH) = "1.5 Euro eingeworfen"
	show(Z_GG) = "2.0 Euro eingeworfen"



-- Überführungsfunktion Delta
delta :: X -> Z -> Z
delta H Z_N  = Z_H
delta G Z_N  = Z_G
delta H Z_H  = Z_G
delta G Z_H  = Z_GH
delta H Z_G  = Z_GH
delta G Z_G  = Z_GG
delta H Z_GH = Z_N
delta G Z_GH = Z_N
delta H Z_GG = Z_N
delta G Z_GG = Z_N

-- Ausgabefunktion Lamda
lambda :: X -> Z -> Y
lambda H Z_N  = KF
lambda G Z_N  = KF
lambda H Z_H  = KF
lambda G Z_H  = KF
lambda H Z_G  = KF
lambda G Z_G  = KF
lambda H Z_GH = KF
lambda G Z_GH = F
lambda H Z_GG = F
lambda G Z_GG = F

-- Testfunktion
test :: Fahrkartenautomat -> [X] -> IO ()
test f l = putStr (testen f l)

testen :: Fahrkartenautomat -> [X] -> String
testen (eing, aus, zust, z, d, l) []     = ""
testen (eing, aus, zust, z, d, l) (x:xs)
	| elem x eing = erg ++ "\n" ++ testen (eing, aus, zust, d x z, d, l) xs
	| otherwise   = testen (eing, aus, zust, z, d, l) xs
		where	erg = show (d x z) ++ ": " ++ show(l x z)

-- Definition eines Fahrkartenautomats
f = ([H, G], [F, KF], [Z_N, Z_H, Z_G, Z_GH, Z_GG], Z_N, delta, lambda)
