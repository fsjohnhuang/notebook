{- TreeZipper
 -}

main = putStrLn ""

data Tree a = Empty | Node a (Tree a) (Tree a) deriving Show
type LeftTree a = Tree a
type RightTree a = Tree a
type Focus a = Tree a

data Crumb a = LeftCrumb a (RightTree a) | RightCrumb a (LeftTree a)
  deriving Show

type Breadcrumbs a = [Crumb a]
type Zipper a = (Focus a, Breadcrumbs a)

goLeft :: Zipper a -> Zipper a
goLeft (Node x l r, bs) = (l, LeftCrumb x r : bs)
goLeft (Empty, bs) = (Empty, bs)

goRight :: Zipper a -> Zipper a
goRight (Node x l r, bs) = (r, RightCrumb x l : bs)
goRight (Empty, bs) = (Empty, bs)

goUp :: Zipper a -> Zipper a
goUp (t, (LeftCrumb x r:bs)) = (Node x t r, bs)
goUp (t, (RightCrumb x l:bs)) = (Node x l t, bs)
goUp (t, []) = (t, [])

modify :: (a -> a) -> Zipper a -> Zipper a
modify f (Node x l r, bs) = (Node (f x) l r, bs)
modify f (Empty, bs) = (Empty, bs)

attach :: Tree a -> Zipper a -> Zipper a
attach t (_, bs) = (t, bs)

topMost :: Zipper a -> Zipper a
topMost z@(t, []) = z
topMost z = topMost $ goUp z

infixl 5 -:
(-:) :: a -> (a -> b) -> b
a -: f = f a
