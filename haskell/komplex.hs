-- Abstrakter Datentyp "Komplexe Zahl"


import GraphicsUtils


-- Datentyp definieren, aus 2 Fließkommazahlen
data Complex = C Float Float
	deriving(Show)


-- Realen Teil der kompl. Zahl zurückgeben
real :: Complex -> Float
real (C a b) = a

-- Imaginären Teil zurückgeben
imag :: Complex -> Float
imag (C a b) = b

-- Addition komplexer Zahlen
add :: Complex -> Complex -> Complex
add (C a b) (C c d) = C (a+c) (b+d)

-- Subtraktion komplexer Zahlen
sub :: Complex -> Complex -> Complex
sub (C a b) (C c d) = C (a-c) (b-d)

-- Multiplikatiom komplexer Zahlen
mult :: Complex -> Complex -> Complex
mult (C a b) (C c d) = (C (a*c - b*d) (a*d + b*c))

-- Betrag in der Gauß'schen Ebene
betrag :: Complex -> Float
betrag (C a b) = sqrt(a^2 + b^2)

-- Winkel in der Gauß'schen Ebene
winkel :: Complex -> Float
winkel (C a b) = atan (b / a) / pi * 180

-- Polarform ausgeben
polar :: Complex -> IO ()
polar c = putStr (show(betrag c) ++ " * (cos " ++ show(w) ++ ", i * sin " ++ show(w) ++ ")")
	where w = winkel c

-- Komplexe Zahl ausgeben
ausgabe :: Complex -> IO ()
ausgabe c = putStr (string c)

-- Komplexe Zahl in String schreiben
string :: Complex -> String
string (C a b) = show(a) ++ " + " ++ show(b) ++ "i"

-- Komplexe Zahl in Gauß'scher Ebene darstellen
zeichne :: Complex -> IO ()
zeichne c = runGraphics $
	do
		w <- openWindow "Komplexe Zahlen - Gauß'sche Ebene" (g,g)
		drawInWindow w (withColor White $ polygon [(0,0),(g,0),(g,g),(0,g)])
		drawInWindow w (withColor Blue $
	                   	withTextAlignment (Center, Bottom) $
   			 	text (div g 2, g) (string c))
		zeichneKoords c (fromInt g, fromInt g) w
		getKey w
		closeWindow w
			where	g = 400

-- Achsen des Koordinatensystems darstellen
zeichneAchsen :: Complex -> Point -> Window -> IO ()
zeichneAchsen (C a b) (x,y) w =
	do
		drawInWindow w (withColor Black $ line (div x 2, 0) (div x 2, y))
		drawInWindow w (withColor Black $ line (0, div y 2) (x, div y 2))
		drawInWindow w (withColor Black $ polygon [(x,h), (x-5,h+5), (x-5,h-5)])
		drawInWindow w (withColor Black $ polygon [(b,0), (b+5,5), (b-5,5)])
			where
				b = div x 2
				h = div y 2

-- Achsenabschnitte des Koordinatensystems darstellen
zeichneAbschnitte :: (Float, Float) -> (Float, Float) -> (Float, Float) -> Window -> IO ()
zeichneAbschnitte u@(ux,uy) p@(px,py) v@(vx,vy) w
	| px > ux || py > uy = return ()
	| otherwise =
		do
			drawInWindow w (withColor Black $ line (round (ux+px),   round (uy+py-2)) (round (ux+px),   round (uy+py+2)))
			drawInWindow w (withColor Black $ line (round (ux-px),   round (uy+py-2)) (round (ux-px),   round (uy+py+2)))
			drawInWindow w (withColor Black $ line (round (ux+px+2), round (uy+py))   (round (ux+px-2), round (uy+py)))
			drawInWindow w (withColor Black $ line (round (ux-px+2), round (uy-py))   (round (ux-px-2), round (uy-py)))
			zeichneAbschnitte u (px+vx, py+vy) v w

-- Koordinaten der komplexen Zahl in der Ebene einzeichnen
zeichneKoords :: Complex -> (Float, Float) -> Window -> IO ()
zeichneKoords c@(C a b) p@(x, y) w =
	do
		zeichneAchsen c (round x, round y) w
		zeichneAbschnitte u (0,0) (l,0) w
		zeichneAbschnitte u (0,0) (0,l) w
		drawInWindow w (withColor Blue $ line (round (x/2), round (y/2)) k)
		drawInWindow w (withColor Black $ line (round (fst u), snd k) k)
		drawInWindow w (withColor Black $ line k (fst k, round (snd u)))
			where
				m = max a b
				l = ((fst u)) / (m+1)
				k = (floor ((fst u) + l * a), floor ((snd u) - l * b))
				u = (x / 2, y / 2)
