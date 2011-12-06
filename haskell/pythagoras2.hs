-- Zeichnet einen Pythagoras-Baums


import GraphicsUtils
-- import "/usr/lib/hugs/graphics-2.0.4/lib/x11/GraphicsUtils"

type MyPoint  = (Float, Float)
type MyVector = (Float, Float)

zeichneBaum :: Window -> Int -> MyPoint -> MyPoint -> IO ()
zeichneBaum _ 0 _ _ = return ()
zeichneBaum w n p1@(x1,y1) p2@(x2,y2) =
	do
                drawInWindow w (line (round x1, round y1) (round x2, round y2))
                drawInWindow w (line (round x2, round y2) (round (fst p3), round (snd p3)))
                drawInWindow w (line (round (fst p3), round (snd p3)) (round (fst p4), round (snd p4)))
                drawInWindow w (line (round (fst p4), round (snd p4)) (round x1, round y1))

                zeichneBaum w (n-1) p4 s
                zeichneBaum w (n-1) s p3

                	where	p3 = rotPoint p1 p2 (-pi/2)
                		p4 = add p3 (getVector p2 p1)
                		s  = add p4 (mult (getVector p4 (rotPoint p3 p4 a)) (cos a))
                		a  = pi/4

baum :: Int -> IO ()
baum n = runGraphics $ do
                w <- openWindow "Pythagoras-Baum" (round b, round h)
                zeichneBaum w n (b/2 - b/15, h-10) (b/2 + b/15, h-10)
                getKey w
                closeWindow w
                	where	b = 400.0
                		h = 300.0

getVector :: MyPoint -> MyPoint -> MyVector
getVector (x1,y1) (x2,y2) = (x2-x1, y2-y1)

len :: MyVector -> Float
len (x,y) = sqrt(x^2+y^2)

mult :: MyVector -> Float -> MyVector
mult (x,y) f = (f*x, f*y)

add :: MyPoint -> MyVector -> MyPoint
add (x,y) (vx,vy) = (x+vx, y+vy)

rot :: MyPoint -> Float -> MyPoint
rot (x,y) w = ((cos w)*x + (sin w)*y, (-sin w)*x + (cos w)*y)

rotPoint :: MyPoint -> MyPoint -> Float -> MyPoint
rotPoint p@(x,y) r@(rx,ry) w = nP
	where	p'  = add p (mult r (-1))
		p'' = rot p' w
		nP  = add p'' r



