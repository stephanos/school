-- Zeichnet ein regelmäßiges Polygon


import GraphicsUtils
-- import "/usr/lib/hugs/graphics-2.0.4/lib/x11/GraphicsUtils"


-- Position auf kreis berechnen
calcPos :: Float -> Float -> Float -> (Int, Int)
calcPos grad r v = (round(cos(grad*conv)*r+v), round(sin(grad*conv)*r+v))
	where	conv = pi/180

-- Polygon darstellen
drawPoly :: Float -> Float -> Float -> Float -> Window -> IO ()
drawPoly ecke grad radius versch w
	| ecke == 0  = 	drawInWindow w (text (round(versch)-125, 0) "Beliebige Taste zum Beenden drücken")
	| otherwise  =
		do
			getKey w
			drawInWindow w (line (calcPos grad1 radius versch) (calcPos grad2 radius versch))
			drawPoly (ecke-1) grad radius versch w
               			where	grad1 = grad * ecke
               				grad2 = grad * (ecke-1)

-- Zeichenfunktion für regelmäßiges n-Eck
zeichne :: Float -> IO ()
zeichne ecken = runGraphics $ do
		w <- openWindow "Polygon" (groesse, groesse)
		drawPoly ecken grad radius versch w
		getKey w
		closeWindow w

	where 	groesse = 400
		radius  = 150
		versch  = 200
		grad	= 360 / ecken
