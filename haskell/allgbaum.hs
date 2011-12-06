data Tree a = E | T a [Tree a]
	deriving(Show)
	
	
--Einfuegen eines neuen Schluessels (arg) an der Stelle key
insert :: Eq a => a -> a -> Tree a -> Tree a
insert arg _ E = T arg [E]
insert arg key t@(T ckey [E])
	| key == ckey = T ckey [T arg [E]]
	| otherwise = t
insert arg key (T ckey t)
	| key == ckey = T ckey (t++[T arg [E]])
	| otherwise = T ckey (map (insert arg key) t)
	
--Loeschen eines Schluessels samt Unterbaum
delete :: Eq a => a -> Tree a -> Tree a
delete _ E = E
delete arg (T ckey t)
	| arg == ckey = E
	| otherwise = T ckey (map (delete arg) t)


	
t1 = T 3 [E]
t2 = T 3 [T 4 [T 8 [E]],T 1 [E]]