-- © ® Stephan Behnke ™
-- Homepage: www.stephan.behnke.de.vu
-- E-Mail: stephan.behnke@gmx.net


import GraphicsUtils
--import "/usr/lib/hugs/graphics-2.0.4/lib/x11/GraphicsUtils"

type MyTripel 	= (Float, Float, Float)
type Ray	= (MyTripel, MyTripel)
type Sphere   	= (MyTripel, Float, MyTripel, Bool, Float)

calcRay :: MyTripel -> Ray
calcRay p = (k, getVector k p)
	where	k = (0,0,-5)

calcLight :: Window -> (Int,Int) -> MyTripel -> Sphere -> [Sphere] -> IO ()
calcLight w (x,y) p s l = drawInWindow w (withRGB (getColor s) $ polygon [(x,y),(x+1,y),(x+1,y+1),(x,y+1)])

ray :: Window -> (Int,Int) -> Ray -> [Sphere] -> IO ()
ray w p r l
	| d == 0	= return ()
	| otherwise 	=
		do
			putStr (show d)
			calcLight w p (point r d) s l
		where
			t = nearest (intersection r l) (0,((0,0,0),0,(0,0,0),False,0))
			d = fst t
			s = snd t

intersection :: Ray -> [Sphere] -> [(Float,Sphere)]
intersection r []     = []
intersection r (x:xs) = (intersectSphere r x, x) : intersection r xs

intersectSphere :: Ray -> Sphere -> Float
intersectSphere (r_s,r_d) s
	| d > 0		= erg
	| otherwise 	= 0
		where
			dst = sub (r_s) (getPos s)
			b   = dot dst r_d
			c   = (dot dst dst) - (getRadius s)
			d   = b*b - c
			erg = - b - (sqrt d)

nearest :: [(Float,Sphere)] -> (Float,Sphere) -> (Float,Sphere)
nearest [] (gd,gs) = (gd,gs)
nearest ((d,s):xs) (gd,gs)
	| (gd == 0 || gd > d) && d > 0 = nearest xs (d,s)
	| otherwise = nearest xs (gd,gs)

raytrace :: Window -> (Int,Int) -> (Int,Int) -> (Int,Int) -> [Sphere] -> IO ()
raytrace w s@(sx,sy) a@(ax,ay) e@(ex,ey) l
	| ay > ey   = return ()
	| ax > ex   =
		do
			putStr (show (round(100 * (fromInteger(toInteger(sy - ay)) / fromInteger(toInteger(sy*2))))) ++ " Prozent berechnet!\n")
			raytrace w s (sx,ay+2) e l
	| otherwise =
		do
			ray w a (calcRay (fromInteger (toInteger ax), fromInteger (toInteger ay),0)) l
			raytrace w s (ax+2,ay) e l

raytracing :: IO ()
raytracing =
	runGraphics $ do
	w <- openWindow "Raytracing" (b,h)
	raytrace w (-div b 2, -div h 2) (-div b 2, -div h 2) (div b 2, div h 2) l
	getKey w
	closeWindow w
		where	h = 150
			b = 150
			l = [((50,50,-50),5,(255,255,0),False,0.5)]

getVector :: MyTripel -> MyTripel -> MyTripel
getVector (x1,y1,z1) (x2,y2,z2) = (x2-x1, y2-y1, z2-z1)

mult :: MyTripel -> Float -> MyTripel
mult (x,y,z) f = (x*f, y*f, z*f)

add :: MyTripel -> MyTripel -> MyTripel
add (x,y,z) (vx,vy,vz) = (x+vx, y+vy, z+vz)

sub :: MyTripel -> MyTripel -> MyTripel
sub (x,y,z) (vx,vy,vz) = (x-vx, y-vy, z-vz)

point :: Ray -> Float -> MyTripel
point (s,v) d = add s (mult v d)

dot :: MyTripel -> MyTripel -> Float
dot (x1,y1,z1) (x2,y2,z2) = x1*x2 + y1*y2 + z1*z2

isLight :: Sphere -> Bool
isLight (p,r,f,l,d) = l

getColor :: Sphere -> RGB
getColor (_,_,(r,g,b),_,_) = RGB (round r) (round g) (round b)

getPos :: Sphere -> MyTripel
getPos (t,_,_,_,_) = t

getRadius :: Sphere -> Float
getRadius (_,r,_,_,_) = r
