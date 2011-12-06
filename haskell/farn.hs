-- Zeichnet einen Barnsley-Farn
-- © ® Stephan Behnke ™
-- Homepage: www.stephan.behnke.de.vu
-- E-Mail: stephan.behnke@gmx.net


import GraphicsUtils
-- import "/usr/lib/hugs/graphics-2.0.4/lib/x11/GraphicsUtils"


-- Tupeldefinition
type MyVector = (Float, Float)
type MyPoint  = (Float, Float)

-- Barnsley-Farn rekursiv zeichnen
zeichneFarn :: Window -> Int -> MyPoint -> MyPoint -> IO ()
zeichneFarn w n p1@(x1,y1) p2@(x2,y2)
	| lenVector (getVector p1 p2) < 1 = return ()
	| n == 0    = return ()
	| otherwise = do
		drawInWindow w (line (round x1,round y1) (round x2,round y2))
                zeichneFarn w (n-1) p2 s
                zeichneFarn w (n-1) p2 l
                zeichneFarn w (n-1) p2 r
                	where	s = drehePunkt p2 p1 181
                		l = add p2 (mult (getVector p2 (drehePunkt s p1 (-a))) f)
                		r = add p2 (mult (getVector p2 (drehePunkt s p1 a)) f)
                		f = 0.15
                		a = 110

-- Barnsley-Farn zeichnen
farn :: Int -> IO ()
farn n =
	runGraphics $ do
	w <- openWindow "Barnsley-Farn" (round b, round h)
	zeichneFarn w n (b/2,h-10) (b/2,h-10-s)
	getKey w
	closeWindow w
		where 	b = 300.0
			h = (fromInteger (toInteger n))*s + s
			s = 45.0

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
