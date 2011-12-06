-- Abstrakte Datenstruktur Schlange

import GraphicsUtils
--import "/usr/lib/hugs/graphics-2.0.4/lib/x11/GraphicsUtils"


-- Datentypdefinition
data UQueue a = E | QU a (UQueue a)

instance Show a => Show(UQueue a) where
	show (E)	    = error "Leere Schlange"
	show (QU a (E))     = show a
	show (QU a (queue)) = show a ++ " <- " ++ show (queue)

-- Element an Schlange hinten anfügen
add :: Eq a => UQueue a -> a -> UQueue a
add E arg = (QU arg (E))
add (QU a (queue)) arg
	| a == arg  = (QU a (queue))
	| otherwise = QU a (add queue arg)

-- Element von Schlange vorne wegnehmen
drop :: UQueue a -> UQueue a
drop E = error "Schlange ist leer!"
drop (QU a (queue)) = queue

-- Leere Schlange
empty :: UQueue a -> UQueue a
empty queue = E

-- Elemente löschen
delete :: Eq a => UQueue a -> a -> UQueue a
delete E arg = E
delete (QU a (queue)) arg
	| arg == a  = queue
	| otherwise = QU a (delete queue arg)

-- Überprüfen ob Schlange leer ist
isEmpty :: UQueue a -> Bool
isEmpty (QU a (queue)) = False
isEmpty E = True

-- Vorderstes Element der Schlange zurückgeben
first :: UQueue a -> a
first E = error "Schlange ist leer!"
first (QU a (queue)) = a

-- Größe der Schlange ermitteln
size :: UQueue a -> Int
size (QU a (queue)) = 1 + size queue
size E = 0

-- Zeichenfunktion der Schlange
zeichne :: Show a => UQueue a -> IO ()
zeichne q = runGraphics $
	do
		w <- openWindow "Schlange" (x, y)
		drawInWindow w (withColor White $ polygon [(0,0),(x,0),(x,y),(0,y)])
		zeichneUQueue q (abst, y) abst w
		getKey w
		closeWindow w
			where
				y = 150
				x = h * abst + abst
				h = size q
				abst = 50

zeichneUQueue :: Show a => UQueue a -> Point -> Int -> Window -> IO ()
zeichneUQueue E p abst w = return ()
zeichneUQueue (QU a (queue)) (x, y) abst w =
	do
		drawInWindow w (withColor Black $ ellipse p1 p2)
                drawInWindow w (withColor White $ withTextAlignment (Center, Baseline) $ text (x, hy) (show a))
                zeichneUQueue queue (x+abst, y) abst w
                	where
                		hy = div y 2
                		qy = div y 4
                		ha = div abst 2
                		p1 = (x - ha, hy - ha)
				p2 = (x + ha, hy + ha)
