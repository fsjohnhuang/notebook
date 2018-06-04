{- Code golf!
 -}
main = let a = "abcd!"
           b = skips a
           c = [1,2,1,3,2,5]
           d = localMixima c
           o1 = [1,1,2,3,1,1,1]
           e = histogram o1
       in
       do
          putStrLn $ show b
          putStrLn $ show d
          putStrLn $ show o1
          putStrLn e

{- Exercise 1 Hopscotch
 - 1. the sequence of n = [0..n-1]
 - 2. remove n items from list
 - 3. pick the first one from the above result list
 -}
everyNth :: Int -> [a] -> [a]
everyNth _ [] = []
everyNth n xs = head' ys ++ everyNth n (tail' ys)
  where ys = drop n xs
        head' [] = []
        head' (x:xs) = [x]
        tail' [] = []
        tail' (x:xs) = xs

skips :: [a] -> [[a]]
skips xs = map (\n -> everyNth n xs) $ init [0..(length xs)]

{- Exercise 2 Local maxima
 -}
localMixima :: [Integer] -> [Integer]
localMixima (x:y:z:xs)
  | x < y && y > z = y : localMixima (z : xs)
  | otherwise = localMixima xs
localMixima _ = []

{- Histogram
 - 1. filter inputs that ensures the elements of inputs is in the 0 to 9 range.
 - 2. statistic the count of each elements.
 - 3. assemble 10 x 10 matrix
 - 4. paint the matrix
 -}
histogram :: [Integer] -> String
histogram = (foldl1 (\accu a -> accu ++ "\n" ++ a)) . (++[xAixs]) . (map showLine) . ctrHistData

xAixs = (unwords (replicate 10 "=")) ++ "\n" ++ (unwords (map show[0..9]))

showLine :: [Int] -> String
showLine = unwords . (map decode)
  where
    decode 0 = " "
    decode 1 = "*"

ctrHistData :: [Integer] -> [[Int]]
ctrHistData = reverse . transpose . assemble . statsNums . getValidNums

getValidNums :: [Integer] -> [Integer]
getValidNums = filter (`elem` [0..9])

statsNums :: [Integer] -> [(Integer, Int)]
statsNums [] = []
statsNums xs = map (statsNumCount xs) [0..9]

statsNumCount :: [Integer] -> Integer -> (Integer, Int)
statsNumCount nums n =  (n, length $ filter (n==) nums)

--type Vector = [Bool,Bool,Bool,Bool,Bool,Bool,Bool,Bool,Bool,Bool]
--type Matrix = [Vector]
--assemble :: [StatsResult] -> Matrix
assemble = map (\(n, count) -> replicate count 1  ++ replicate (10 - count) 0)

--transpose :: Matrix -> Matrix
transpose matrix = map transNthColToRow idxs
  where
    idxs = init [0..(length matrix)]
    transNthColToRow i = map (\r -> matrix !! r !! i) idxs
