module Turtlegrafik (mitte, Turtle (Drehe,Gehe,Sichtbar,Unsichtbar), kroete)
where

import GraphicsUtils
-- import "/usr/lib/hugs/graphics-2.0.4/lib/x11/GraphicsUtils"

-- ------------------------------------------------------------------
-- Typdefinitionen
-- ------------------------------------------------------------------

-- Definiert Zustand der Kroete: Position (x,y), Drehwinkel sowie Sichtbarkeit
type Zustand = (Float,Float,Float,Bool)

-- Typendefinition von Winkel, Länge und Visible
type Winkel  = Float
type Laenge  = Float
type Visible = Bool

-- Fenstergröße setzen
winSizeX :: Int
winSizeX = 400
winSizeY :: Int
winSizeY = 400

-- Zustand der Kröte bei Programmstart: Position am Mittelpunkt, 90 Grad Winkel und sichtbar
mitte :: Zustand
mitte = (mittex,mittey,90,True)
   where mittex = fromInt (div (winSizeX) 2)
         mittey = fromInt (div (winSizeY) 2)

-- Datentyp Turtle: Befehl für Kröte, entweder Drehung, Bewegung, Position setzen bzw. Sichbarkeit bestimmen
data Turtle = Drehe Winkel | Gehe Laenge | Setze Float Float Winkel |Sichtbar | Unsichtbar
               deriving (Eq,Show)



-- ------------------------------------------------------------------
-- Bewegungen der Kröte
-- ------------------------------------------------------------------

-- Funktion gehe: bewegt Kröte in Blickrichtung um bestimmte Länge
gehe :: Zustand -> Laenge -> Zustand
gehe (x,y,w,s) len = (x1,y1,w,s)
    where
       x1 = x + len * cos (-w * pi/180)
       y1 = y + len * sin (-w * pi/180)

-- Funktion drehe: dreht Blickwinkel der Kröte
drehe :: Zustand -> Winkel -> Zustand
drehe (x,y,w,s) w1 = (x,y, w+w1,s)



-- ------------------------------------------------------------------
-- Umwandlung in Punktliste
-- ------------------------------------------------------------------

-- Funktion istsichtbar: Gibt zurück, ob Kröte im Zustand sichtbar ist
istsichtbar:: Zustand -> Bool
istsichtbar (x,y,w,s) = s

-- Funktion istnichtsichtbar: Gibt zurück, ob Kröte nicht im Zustand sichtbar ist
istnichtsichtbar:: Zustand -> Bool
istnichtsichtbar (x,y,w,s) = not s

-- 1. Funktion zur Umwandlung
-- Funktion ersetze: mach Bewegungen mittels Befehl 'Setze' unsichtbar
ersetze :: [Turtle] -> [Turtle]
ersetze [] = []
ersetze (t@(Setze x y w):ts) 	= Unsichtbar : t : Sichtbar : (ersetze ts)
ersetze (t:ts) 			= t : (ersetze ts)

-- 2. Funktion zur Umwandlung
-- Funktion spur: wandelt Anweisungen in Zustände um
spur :: [Turtle] -> Zustand -> [Zustand]
spur [] z = [z]
spur (t:ts) z = [z] ++ spur ts z'
     where z' = interpret t z

-- 3. Funktion zur Umwandlung
-- Funktion interpret: ändert den Zustand der Kröte abhängig vom Befehl
-- der ausgeführt wird, gibt neuen Zustand zurück
interpret :: Turtle -> Zustand -> Zustand
interpret (Gehe a)	   t	      = gehe t a
interpret (Drehe w1)       t 	      = drehe t w1
interpret (Setze x1 y1 w1) (x,y,w,s)  = (x1,y1,w1,s)
interpret (Sichtbar)	   (x,y,w,s)  = (x,y,w,True)
interpret (Unsichtbar)	   (x,y,w,s)  = (x,y,w,False)

-- 4. Funktion zur Umwandlung
-- Funktion teilspuren: Aufteilen in Teilstrecken, unsichtbare Strecken aussortieren
teilspuren :: [Zustand] -> [[Zustand]]
teilspuren [] = []
teilspuren zs = vis : (teilspuren rest)
   where zs'  = dropWhile (istnichtsichtbar) zs   -- nicht sichtbare Elemente am Anfang entfernen
         vis  = takeWhile (istsichtbar) zs'       -- sichtbare Elemente am Anfang nehmen
	 rest = dropWhile (istsichtbar) zs'       -- restliche Strecke

-- 5. Funktion zur Umwandlung
-- Funktion toPoint: wandelt Zustände in Punkte um
toPoint :: [[Zustand]] -> [[Point]]
toPoint xxs = [toPoint' xs | xs <- xxs]

toPoint' :: [Zustand] -> [Point]
toPoint' xs = [(round x,round y) | (x,y,w,s) <- xs]

-- 6. Funktion zur Umwandlung
-- Funktion reduzieren:
reduzieren :: [[Point]] -> [[Point]]
reduzieren [] = []
reduzieren (x:xs)
	| length x > 1 = x : reduzieren xs
	| otherwise    = reduzieren xs


-- ------------------------------------------------
-- Zeichenroutinen
-- ------------------------------------------------

-- Funktion drawpolylines: verbindet und zeichnet Punkte zu einem Polygon
drawpolylines :: [[Point]] -> [Graphic]
drawpolylines []     = [emptyGraphic]
drawpolylines (x:xs) = (polyline x) : (drawpolylines xs)

-- Funktion drawmultiline: zeichnet mehrere Linien in ein Grafikfenster
drawmultiline linien w = drawInWindow w ((overGraphics (drawpolylines linien)))

-- Funktion zeichne: ruft Zeichenfunktion zur Darstellung einer übergebenen Punktliste in einem Grafikfenster auf
zeichne liste = runGraphics (do
	w <- openWindow "Turtle-Grafik" (winSizeX,winSizeY)
	drawInWindow w (withTextColor (RGB 255 0 0) $
                   	 withTextAlignment (Center,Bottom) $
   			 text (div winSizeX 2, winSizeY) "Ende mit beliebiger Taste")
	drawmultiline liste w
	getKey w
	closeWindow w
    )



-- ------------------------------------------------
-- Hauptfunktion
-- ------------------------------------------------

-- Funktion kroete: bekommt Anweisungen für Kröte sowie den Zustand
-- der Kröte, wandelt diese in Liste aus Punkten um und lässt diese zeichnen
kroete :: [Turtle] -> Zustand -> IO()
kroete turtle start = zeichne (reduzieren (toPoint (teilspuren (spur (ersetze turtle) start))))
