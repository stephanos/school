-- Zeichnet einen Phytagoras-Baum
-- © ® Stephan Behnke ™
-- Homepage: www.stephan.behnke.de.vu
-- E-Mail: stephan.behnke@gmx.net


import GraphicsUtils
-- import "/usr/lib/hugs/graphics-2.0.4/lib/x11/GraphicsUtils"


-- Tupeldefinition
type MyVector = (Float, Float)
type MyPoint  = (Float, Float)

-- Pythagoras-Baum rekursiv zeichnen
zeichneBaum :: Window -> Int -> MyPoint -> MyPoint -> IO ()
zeichneBaum w n p1@(x1,y1) p2@(x2,y2)
	| lenVector s < 1 = return ()
	| n == 0    = return ()
	| otherwise = do
		drawInWindow w (polyline [(round x1,round y1),(round x2,round y2),
					  (round (fst p3),round (snd p3)),(round (fst p4),round (snd p4)),(round x1,round y1)])
		zeichneBaum w (n-1) p4 ds
		zeichneBaum w (n-1) ds p3
			where	p3 = add p4 s
				p4 = drehePunkt p1 p2 90
				ds = add p4 (mult (getVector p4 (drehePunkt p4 p3 a)) (cos (a*pi/180)))
				s  = getVector p1 p2
				a  = 30

-- Pythagoras-Baum zeichnen
baum :: Int -> IO ()
baum n =
	runGraphics $ do
	w <- openWindow "Pythagoras-Baum" (round b, round h)
	zeichneBaum w n (p,h-h/10) (p+l,h-h/10)
	getKey w
	closeWindow w
		where 	b = 400.0
			h = 300.0
			p = b/2
			l = 50

-- Vektor zwischen 2 Punkten errechnen
getVector :: MyPoint -> MyPoint -> MyVector
getVector (x1,y1) (x2,y2) = (x2-x1, y2-y1)

-- Vektor mit einer reelen Zahl multiplizieren
mult :: MyVector -> Float -> MyVector
mult (x,y) f = (x*f, y*f)

-- Punkt um einen Vektor verschieben
add :: MyPoint -> MyVector -> MyPoint
add (x,y) (vx, vy) = (x+vx, y+vy)

-- Länge eines Vektors errechnen
lenVector :: MyVector -> Float
lenVector (x,y) = sqrt (x^2 + y^2)

-- Punkt drehen
drehen :: MyPoint -> Float -> MyPoint
drehen (x,y) a = ((cos a)*x + (sin a)*y, (-sin a)*x + (cos a)*y)

-- Punkt um einen anderen drehen
drehePunkt :: MyPoint -> MyPoint -> Float -> MyPoint
drehePunkt p1@(x,y) p2 w = s
	where	p2' = add p2 (-x,-y)
		s'  = drehen p2' (w*pi/180)
		s   = add s' p1
