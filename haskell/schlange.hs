-- Abstrakte Datenstruktur Schlange
-- © ® Stephan Behnke ™
-- Homepage: www.stephan.behnke.de.vu
-- E-Mail: stephan.behnke@gmx.net


import GraphicsUtils
--import "/usr/lib/hugs/graphics-2.0.4/lib/x11/GraphicsUtils"


-- Datentypdefinition
data Queue a = E | Q a (Queue a)

instance Show a => Show(Queue a) where
	show (E)	   = error "Leere Schlange"
	show (Q a (E))     = show a
	show (Q a (queue)) = show a ++ " <- " ++ show (queue)

-- Element an Schlange hinten anfügen
add :: Queue a -> a -> Queue a
add E arg = (Q arg (E))
add (Q a (queue)) arg = (Q a (add queue arg))

-- Element von Schlange vorne wegnehmen
drop :: Queue a -> Queue a
drop E = error "Schlange ist leer!"
drop (Q a (queue)) = queue

-- Leere Schlange
empty :: Queue a -> Queue a
empty queue = E

-- Elemente löschen
delete :: Eq a => Queue a -> a -> Queue a
delete E arg = E
delete (Q a (queue)) arg
	| arg == a  = delete queue arg
	| otherwise = Q a (delete queue arg)

-- Überprüfen ob Schlange leer ist
isEmpty :: Queue a -> Bool
isEmpty (Q a (queue)) = False
isEmpty E = True

-- Vorderstes Element der Schlange zurückgeben
first :: Queue a -> a
first E = error "Schlange ist leer!"
first (Q a (queue)) = a

-- Größe der Schlange ermitteln
size :: Queue a -> Int
size (Q a (queue)) = 1 + size queue
size E = 0

-- Zeichenfunktion der Schlange
zeichne :: Show a => Queue a -> IO ()
zeichne q = runGraphics $
	do
		w <- openWindow "Schlange" (x, y)
		drawInWindow w (withColor White $ polygon [(0,0),(x,0),(x,y),(0,y)])
		zeichneQueue q (abst, y) abst w
		getKey w
		closeWindow w
			where
				y = 150
				x = h * abst + abst
				h = size q
				abst = 50

zeichneQueue :: Show a => Queue a -> Point -> Int -> Window -> IO ()
zeichneQueue E p abst w = return ()
zeichneQueue (Q a (queue)) (x, y) abst w =
	do
		drawInWindow w (withColor Black $ ellipse p1 p2)
                drawInWindow w (withColor White $ withTextAlignment (Center, Baseline) $ text (x, hy) (show a))
                zeichneQueue queue (x+abst, y) abst w
                	where
                		hy = div y 2
                		qy = div y 4
                		ha = div abst 2
                		p1 = (x - ha, hy - ha)
				p2 = (x + ha, hy + ha)
