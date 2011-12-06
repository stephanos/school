-- Fehleranzeige

div :: Float -> Float -> Float
div a b
	| b == 0    = error "Fehler! Division durch Null!"
	| otherwise = a / b




-- Type

type MyPoint = (Int, Int)

koords :: MyPoint -> String
koords (x,y) = "Punkt liegt bei x:" ++ (show x) ++ " und y:" ++ (show y)




-- Variablen

abst :: MyPoint -> Float
abst (x,y) = sqrt(fx^2 + fy^2)
	where 	fx = fromInteger (toInteger x)
		fy = fromInteger (toInteger y)

