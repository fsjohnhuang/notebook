main = do
  let t1 = updateTo 'C' [L, L, L] freeTree
  putStrLn $ show $ elemAt [L, L, L] freeTree
  putStrLn $ show $ elemAt [L, L, L] t1
  putStrLn $ show a

data Tree a = Empty | Node a (Tree a) (Tree a) deriving Show
data Dir = L | R deriving (Show, Eq)

updateTo :: a -> [Dir] -> Tree a -> Tree a
updateTo x (L:ds) (Node a l r) = Node a (updateTo x ds l) r
updateTo x (R:ds) (Node a l r) = Node a l (updateTo x ds r)
updateTo x [] (Node _ l r) = Node x l r
updateTo _ _ Empty = Empty

elemAt :: [Dir] -> Tree a -> Maybe a
elemAt (L:ds) (Node _ l _) = elemAt ds l
elemAt (R:ds) (Node _ _ r) = elemAt ds r
elemAt [] (Node a _ _) = Just a
elemAt _ Empty = Nothing

a = runState
  (do
    Just a <- goRightS
    Just b <- goRightS
    Just c <- goRightS
    return $ ((a,b,c), a + b + c))
  (fmap mapper freeTree, [])

mapper :: Char -> Int
mapper 'A' = 1
mapper 'B' = 2
mapper 'C' = 3
mapper 'D' = 4
mapper 'E' = 5
mapper 'F' = 6
mapper 'G' = 7
mapper 'H' = 8
mapper _ = 9

instance Functor Tree where
  fmap f (Node x l r) = Node (f x) (fmap f l) (fmap f r)
  fmap _ Empty = Empty

type Breadcrumbs = [Dir]
type WalkState a = (Tree a, Breadcrumbs)

goRightS :: State (WalkState a) (Maybe a)
goRightS = State goRight
  where
    goRight :: WalkState a -> (Maybe a, WalkState a)
    goRight ((Node x l r), ds) = (Just x, (r, R : ds))
    goRight (Empty, ds) = (Nothing, (Empty, ds))

goLeftS :: State (WalkState a) (Maybe a)
goLeftS = State goLeft
  where
    goLeft :: WalkState a -> (Maybe a, WalkState a)
    goLeft ((Node x l r), ds) = (Just x, (l, L : ds))
    goLeft (Empty, ds) = (Nothing, (Empty, ds))

newtype State s a = State { runState :: s -> (a, s)}
instance Functor (State s) where
  fmap f (State g) = State (\x -> let (a, s) = g x
                                  in (f a, s))

instance Applicative (State s) where
  pure a = State (\s -> (a, s))
  (State f) <*> (State g) = State (\x -> let (h, s) = f x
                                             (a, s') = g s
                                         in (h a, s'))

instance Monad (State s) where
  return = pure
  (State f) >>= g = State (\x -> let (a, s) = f x
                                     (State h) = g a
                                 in h s)

freeTree :: Tree Char
freeTree =   
    Node 'P'  
        (Node 'O'  
            (Node 'L'  
                (Node 'N' Empty Empty)  
                (Node 'T' Empty Empty)  
            )  
            (Node 'Y'  
                (Node 'S' Empty Empty)  
                (Node 'A' Empty Empty)  
            )  
        )  
        (Node 'L'  
            (Node 'W'  
                (Node 'C' Empty Empty)  
                (Node 'R' Empty Empty)  
            )  
            (Node 'A'  
                (Node 'A' Empty Empty)  
                (Node 'C' Empty Empty)  
            )  
        )  
