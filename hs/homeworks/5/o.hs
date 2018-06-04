{-# LANGUAGE FlexibleInstances, MultiParamTypeClasses #-}

main = let a = blerg (1::Int) "1"
       in
       do
       putStrLn $ show a

data Tree a = Empty
            | Node a (Tree a) (Tree a)
  deriving Show

instance Eq a => Eq (Tree a) where
  Empty == Empty = True
  (Node a _ _) == (Node b _ _) = a == b
  _ == _ = False

class Blerg a b where
  blerg :: a -> b -> Bool

instance Blerg Int String where
  blerg i s = show i == s
