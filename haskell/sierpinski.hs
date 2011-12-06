-- Zeichnet ein Sierpinski-Dreieck
-- © ® Stephan Behnke ™
-- Homepage: www.stephan.behnke.de.vu
-- E-Mail: stephan.behnke@gmx.net


import GraphicsUtils
-- import "/usr/lib/hugs/graphics-2.0.4/lib/x11/GraphicsUtils"


-- Tupeldefinition
type MyVector = (Float, Float)
type MyPoint  = (Float, Float)

-- Sierpinski-Dreieck rekursiv zeichnen
zeichneDreieck :: Window -> Int -> MyPoint -> MyPoint -> MyPoint -> IO ()
zeichneDreieck w 0 (x1,y1) (x2,y2) (x3,y3) = return()
zeichneDreieck w n l@(x1,y1) r@(x2,y2) s@(x3,y3) = do
	drawInWindow w (polyline [(round x1, round y1),(round x2, round y2),(round x3, round y3),(round x1, round y1)])
	zeichneDreieck w (n-1) l  l' s'
	zeichneDreieck w (n-1) s' r' r
	zeichneDreieck w (n-1) l' r' s
		where
			l' = add l (mult (getVector l s) 0.5)
			r' = add r (mult (getVector r s) 0.5)
			s' = add l (mult (getVector l r) 0.5)

-- Sierpinski-Dreieck zeichnen
dreieck :: Int -> IO ()
dreieck n =
	runGraphics $ do
	w <- openWindow "Sierpinski-Dreieck" (round b, round h)
	zeichneDreieck w n (0,h) (b,h) (b / 2,0)
	getKey w
	closeWindow w
		where 	b  = 300.0
			h  = 300.0

-- Vektor zwischen 2 Punkten errechnen
getVector :: MyPoint -> MyPoint -> MyVector
getVector (x1,y1) (x2,y2) = (x2-x1, y2-y1)

-- Vektor mit einer reelen Zahl multiplizieren
mult :: MyVector -> Float -> MyVector
mult (x,y) f = (x*f, y*f)

-- Punkt um einen Vektor verschieben
add :: MyPoint -> MyVector -> MyPoint
add (x,y) (vx, vy) = (x+vx, y+vy)
