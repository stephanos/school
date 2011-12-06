-- Zeichnet eine Koch-Kurve


import GraphicsUtils
-- import "/usr/lib/hugs/graphics-2.0.4/lib/x11/GraphicsUtils"


-- Tupeldefinition
type MyVector = (Float, Float)
type MyPoint  = (Float, Float)

-- Spitze des Dreiecks berechnen
berechneSpitze :: MyPoint -> MyPoint -> MyPoint
berechneSpitze p1@(x,y) p2 = s
	where	p2' = add p2 (-x,-y)
		s'  = drehen p2' (pi/3)
		s   = add s' p1

-- Koch-Kurve rekursiv zeichnen
zeichneKoch :: Window -> Int -> MyPoint -> MyPoint -> IO ()
zeichneKoch w n p1@(x1,y1) p2@(x2,y2)
	| n == 0 = drawInWindow w (line (round x1, round y1) (round x2, round y2))
	| otherwise =
		do
			zeichneKoch w (n-1) p1 li
        		zeichneKoch w (n-1) re p2

        		zeichneKoch w (n-1) li s
        		zeichneKoch w (n-1) s re

				where   v  = getVector p1 p2
					li = add p1 (mult v (1/3))
					re = add p2 (mult v (-1/3))
					s  = berechneSpitze li re

-- Koch-Kurve zeichnen
koch :: Int -> IO ()
koch n =
	runGraphics $ do
	w <- openWindow "Koch-Kurve" (round b, round h)
	zeichneKoch w n (0,kh) (b,kh)
	getKey w
	closeWindow w
		where 	b  = 600.0
			h  = 300.0
			kh = h*2/3

-- Vektor zwischen 2 Punkten errechnen
getVector :: MyPoint -> MyPoint -> MyVector
getVector (x1,y1) (x2,y2) = (x2-x1, y2-y1)

-- Vektor mit einer reelen Zahl multiplizieren
mult :: MyVector -> Float -> MyVector
mult (x,y) f = (x*f, y*f)

-- Punkt um einen Vektor verschieben
add :: MyPoint -> MyVector -> MyPoint
add (x,y) (vx, vy) = (x+vx, y+vy)

-- Punkt drehen
drehen :: MyPoint -> Float -> MyPoint
drehen (x,y) a = ((cos a)*x + (sin a)*y, (-sin a)*x + (cos a)*y)