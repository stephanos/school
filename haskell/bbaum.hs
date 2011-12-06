-- Abstrakte Datenstruktur binärer Suchbaum



-- Datentypdefinition
data BBaum a = E | K (BBaum a) a (BBaum a)
	deriving(Show)


-- Element in Baum einfügen
einfuegen :: Ord a => a -> BBaum a -> BBaum a
einfuegen arg E = K (E) arg (E)
einfuegen arg b@(K (b1) a (b2))
	| arg < a   = K (einfuegen arg b1) a b2
	| arg > a   = K b1 a (einfuegen arg b2)
	| otherwise = b

-- Leerer Baum
leererBaum :: BBaum a -> BBaum a
leererBaum (K (b1) a (b2)) = E

-- Element auf Vorhandensein prüfen
enthalten :: Ord a => a -> BBaum a -> Bool
enthalten arg E = False
enthalten arg (K (b1) a (b2))
	| arg < a   = enthalten arg b1
	| arg > a   = enthalten arg b2
	| otherwise = True

-- Baum auf Leerheit checken
istleer :: BBaum a -> Bool
istleer E = True
istleer (K (b1) a (b2)) = False

-- Prüfen ob Baum ein Blatt ist
istBlatt :: BBaum a -> Bool
istBlatt (K (E) a (E)) = True
istBlatt (K (b1) a (b2)) = False

-- Traversierung: Reihenfolge preorder
preorder :: BBaum a -> [a]
preorder E = []
preorder (K (b1) a (b2)) = [a] ++ preorder b1 ++ preorder b2

-- Traversierung: Reihenfolge inorder
inorder :: BBaum a -> [a]
inorder E = []
inorder (K (b1) a (b2)) = inorder b1 ++ [a] ++ inorder b2

-- Traversierung: Reihenfolge postorder
postorder :: BBaum a -> [a]
postorder E = []
postorder (K (b1) a (b2)) = postorder b1 ++ postorder b2 ++ [a]

-- Funktion auf jedes Element des Baumes ausführen
mapBaum :: (a->b) -> BBaum a -> BBaum b
mapBaum f E = E
mapBaum f (K (b1) a (b2)) = K (mapBaum f b1) (f a) (mapBaum f b2)

-- Baum aus sortierter Liste erstellen
makeBaum :: Ord a => [a] -> BBaum a
makeBaum [] = E
makeBaum l  = K (makeBaum [y | y <- l, y < m]) m (makeBaum [y | y <- l, y > m])
	where 	h = div (length l) 2
		m = l !! h

ausgleichen :: Ord a => BBaum a -> BBaum a
ausgleichen b@(K (b1) a (b2)) = makeBaum (inorder b)

hoehe :: BBaum a -> Int
hoehe E = 0
hoehe (K (b1) a (b2)) = max (hoehe b1 + 1) (hoehe b2 + 1)

elemInEbene :: BBaum a -> Int -> [a]
elemInEbene E _ = []
elemInEbene (K (b1) a (b2)) e
	| e == 1    = [a]
	| otherwise = (elemInEbene b1 (e-1)) ++ (elemInEbene b2 (e-1))

groesstes :: BBaum a -> a
groesstes (K (b1) a (E))  = a
groesstes (K (b1) a (b2)) = groesstes b2

kleinstes :: BBaum a -> a
kleinstes (K (E) a (b2))  = a
kleinstes (K (b1) a (b2)) = kleinstes b1

levelorder :: BBaum a -> [a]
levelorder E = []
levelorder b = levelOrder b (hoehe b)

levelOrder :: BBaum a -> Int -> [a]
levelOrder E _ = []
levelOrder b 0 = []
levelOrder b e = elemInEbene b e ++ levelOrder b (e-1)
