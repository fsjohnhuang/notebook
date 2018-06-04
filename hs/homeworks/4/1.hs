main = let a = [4,7]
           b = 4
           c = fun2 b
           d = [True, True, False, False]
           e = xor d
       in
       do
       putStrLn $ show $ fun1 a
       putStrLn $ show c
       putStrLn $ show e

{- Exercise 1
 - Wholemeal Programming
 -}
{- Exercise 1.1
 - fun1 :: [Integer] -> Integer
 - fun1 [] = 1
 - fun1 (x:xs)
 -  | even x = (x - 2) * fun1 xs
 -  | otherwise = fun1 xs
 -}

fun1 :: [Integer] -> Integer
fun1 = foldl1 (*) . map (\x -> x - 2) . filter even


{- Exercise 1.2
 - fun2 :: Integer -> Integer
 - fun2 1 = 0
 - fun2 n | even n = n + fun2 (n `div` 2)
 -        | otherwise = fun2 (3 * n + 1)
 -}

fun2 :: Integer -> Integer
fun2 = sum . (takeWhile (/=0)) . (iterate f)
  where f n
          | n == 1 = 0
          | even n = n `div` 2
          | otherwise = 3 * n + 1

{- Exercise 2
 - Folding with trees
 -}
data Tree a = Leaf
            | Node Integer (Tree a) a (Tree a)
  deriving (Show, Eq)

--foldTree :: [a] -> Tree a

{- Exercise 3
 - More folds!
 -}
xor :: [Bool] -> Bool
xor = odd . length . (filter id)

map' :: (a -> b) -> [a] -> [b]
map' f xs = foldr (\a b -> (f a) : b) [] xs

cartProd :: [a] -> [b] -> [(a,b)]
cartProd xs ys = [(x,y) | x <- xs, y <- ys]
