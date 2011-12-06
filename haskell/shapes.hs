-- Abstrakter Datentyp Shape


import GraphicsUtils
-- import "/usr/lib/hugs/graphics-2.0.4/lib/x11/GraphicsUtils"


-- Tupeldefinition
type MyVector = (Float, Float)
type MyPoint  = (Float, Float)

-- Datentypdefinition
data Shape = Circle MyPoint Float
		| Rectangle MyPoint MyPoint
		| Triangle MyPoint MyPoint MyPoint
			deriving(Show)


-- Funktionen für Shapes:

-- Feststellen ob Objekt rund ist
isRound :: Shape -> Bool
isRound (Circle _ _) = True
isRound _	     = False

-- Flächeninhalt
areaOfShape :: Shape -> Float
areaOfShape (Circle _ r) = r^2 * pi
areaOfShape (Rectangle (x1,y1) (x2,y2)) = (abs(x1-x2) * abs(y1-y2))
areaOfShape t@(Triangle p1 p2 p3) = lenVector(getVector p1 p3) * (triHeight t) / 2

-- Verdopple Flächeninhalt
doubleArea :: Shape -> Shape
doubleArea s@(Circle p r) = scale s 2
doubleArea s = scale s (sqrt 2)

-- Shape skalieren
scale :: Shape -> Float -> Shape
scale (Circle p r) f = (Circle p (f*r))
scale (Rectangle p1 p2) f = (Rectangle p1 (add p1 (mult (getVector p1 p2) f)))
scale (Triangle p1 p2 p3) f = (Triangle p1 (add p1 (mult (getVector p1 p2) f)) (add p1 (mult (getVector p1 p3) f)))

-- Mittelpunkt angeben
getMiddle :: Shape -> MyPoint
getMiddle (Circle p r) = p
getMiddle (Rectangle p1 p2) = add p1 (mult (getVector p1 p2) 0.5)
getMiddle (Triangle (x1,y1) (x2,y2) (x3,y3)) = ((x1+x2+x3)/3,(y1+y2+y3)/3)

-- Shapes zeichnen
zeichne :: [Shape] -> IO ()
zeichne s = runGraphics $
	do
		w <- openWindow "Shapes" p
		drawInWindow w (withColor White $ polygon [(0,0),(g,0),(g,g),(0,g)])
		zeichneShapes s w
		getKey w
		closeWindow w
			where	p = (g, g)
				g = 400

zeichneShapes :: [Shape] -> Window -> IO ()
zeichneShapes [] w = return ()
zeichneShapes (x:xs) w =
	do
		zeichneShape  x  w
		drawInWindow w (withColor Red $ ellipse (roundPoint (add m (1,1))) (roundPoint (add m (-1,-1))))
		zeichneShapes xs w
			where	m = getMiddle x

zeichneShape :: Shape -> Window -> IO ()
zeichneShape (Circle p@(x,y) r) w =
	do
		drawInWindow w (withColor Black $ ellipse (roundPoint (add p (-r-1,-r-1))) (roundPoint (add p (r+1,r+1))))
		drawInWindow w (withColor Blue $ ellipse (roundPoint (add p (-r,-r))) (roundPoint (add p (r,r))))
zeichneShape (Triangle p1 p2 p3) w =
	do
		drawInWindow w (withColor Blue $ polygon (roundPoints [p1,p2,p3]))
		drawInWindow w (withColor Black $ polyline (roundPoints [p1,p2,p3,p1]))
zeichneShape (Rectangle p1@(x1,y1) p2@(x2,y2)) w =
	do
		drawInWindow w (withColor Blue $ polygon (roundPoints [p1,(x2,y1),p2,(x1,y2)]))
		drawInWindow w (withColor Black $ polyline (roundPoints [p1,(x2,y1),p2,(x1,y2),p1]))


-- Hilfsfunktionen:

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

-- Punktprodukt zweier Vektoren berechnen
dotProduct :: MyVector -> MyVector -> Float
dotProduct (x1,y1) (x2,y2) = x1*x2 + y1*y2

-- Winkel zwischen 2 Vektoren errechnen
angleVectors :: MyVector -> MyVector -> Float
angleVectors v1 v2 = 180 / pi * acos((dotProduct v1 v2) / (lenVector v1 * lenVector v2))

-- Höhe eines Dreiecks berechnen
triHeight :: Shape -> Float
triHeight (Triangle p1 p2 p3) = sin ((angleVectors v1 v2)/180*pi) * lenVector v1
	where 	v1 = getVector p1 p2
		v2 = getVector p1 p3

-- Einzelnen Punkt in Tupel aus ganzen Zahlen umwandeln
roundPoint :: MyPoint -> (Int, Int)
roundPoint (x,y) = (round x, round y)

-- Liste aus Punkten in Liste aus Tupeln mit ganzen Zahlen umwandeln
roundPoints :: [MyPoint] -> [(Int, Int)]
roundPoints [] = []
roundPoints (x:xs) = roundPoint x : roundPoints xs
