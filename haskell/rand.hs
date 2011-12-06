import Random


endlInts :: Int -> (Int,Int) -> Int -> [Int]
endlInts anzahl intervall keimzelle = take anzahl (randomRs intervall (mkStdGen keimzelle))
