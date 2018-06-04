{- ListZipper -}

main = putStrLn $ show $ initListZipper -: goForward -: goForward -: goBack
lst = 5 :- 4 :- 3 :- Empty
initListZipper = ListZipper (lst, Empty)

infixl 5 -:
(-:) :: a -> (a->b) -> b
a -: f = f a

infixr 5 :-
data List a = Empty | a :- List a
  deriving Show

type Crumbs a = List a

newtype ListZipper a = ListZipper (List a, Crumbs a)
  deriving Show

goForward :: ListZipper a -> ListZipper a 
goForward z@(ListZipper (Empty, bs)) = z
goForward (ListZipper (x :- xs, bs)) = ListZipper (xs, x:-bs)

goBack :: ListZipper a -> ListZipper a
goBack z@(ListZipper (xs, Empty)) = z
goBack (ListZipper (xs, b:-bs)) = ListZipper (b:-xs, bs)

goInit :: ListZipper a -> ListZipper a
goInit z@(ListZipper (xs, Empty)) = z
goInit z = goInit $ goBack z
