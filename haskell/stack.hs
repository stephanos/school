-- Abstrakte Datenstruktur Stack
-- © ® Stephan Behnke ™
-- Homepage: www.stephan.behnke.de.vu
-- E-Mail: stephan.behnke@gmx.net


import GraphicsUtils
-- import "/usr/lib/hugs/graphics-2.0.4/lib/x11/GraphicsUtils"


-- Datentypdefinition
data Stack a = E | S a (Stack a)
	deriving(Show)


-- Element auf Stapel oben drauflegen
push :: Stack a -> a -> Stack a
push stack arg = S arg (stack)

-- Element von Stapel oben wegnehmen
pop :: Stack a -> Stack a
pop E = error "Stack ist leer!"
pop (S a (stack)) = stack

-- Leerer Stapel
empty :: Stack a -> Stack a
empty stack = E

-- Überprüfen ob Stapel leer ist
isEmpty :: Stack a -> Bool
isEmpty (S a (stack)) = False
isEmpty E = True

-- Oberstes Element vom Stapel zurückgeben
top :: Stack a -> a
top E = error "Stack ist leer!"
top (S a (stack)) = a

-- Höhe von Stapel besetimmen
height :: Stack a -> Int
height (S a (stack)) = 1 + height stack
height E = 0

-- zeichenfunktion vom Stapel
zeichne :: Show a => Stack a -> IO ()
zeichne s = runGraphics $
	do
		w <- openWindow "Stack" (x, y)
		drawInWindow w (withColor White $ polygon [(0,0),(x,0),(x,y),(0,y)])
		zeichneStack s (x, abst) abst w
		getKey w
		closeWindow w
			where
				x = 200
				y = h * abst + abst
				h = height s
				abst = 30

zeichneStack :: Show a => Stack a -> Point -> Int -> Window -> IO ()
zeichneStack E p abst w = return ()
zeichneStack (S a (stack)) (x, y) abst w =
	do
		drawInWindow w (withColor Black $ polyline [lo,ro,ru,lu,lo])
                drawInWindow w (withColor Black $ withTextAlignment (Center, Baseline) $ text (hx, y) (show a))
                zeichneStack stack (x, y+abst) abst w
                	where
                		hx = div x 2
                		qx = div x 4
                		ha = div abst 2
                		lo = (hx - qx, 	y + ha)
				ro = (hx + qx, 	y + ha)
                		ru = (hx + qx,  y - ha)
				lu = (hx - qx, 	y - ha)
