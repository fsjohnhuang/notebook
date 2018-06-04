main = let lst = (-1) :- 2 :- 3 :- Empty
           absLst = mapIntList abs lst
           posLst = filterIntList (>0) lst
           total = foldlIntList (+) 0 lst

           strLst = "abc" :-> "cd" :-> "123c" :-> E
           boolLst = mapList (== "abc") strLst
           abcLst = filterList (== "abc") strLst
           str = foldlList (++) "" strLst
       in
       do
         putStrLn $ show lst
         putStrLn $ show absLst
         putStrLn $ show posLst
         putStrLn $ show total

         putStrLn $ show strLst
         putStrLn $ show boolLst
         putStrLn $ show abcLst
         putStrLn str

infixr 5 :-
data IntList = Empty
             | Int :- IntList
  deriving Show

mapIntList :: (Int -> Int) -> IntList -> IntList
mapIntList _ Empty = Empty
mapIntList f (x :- xs) = f x :- mapIntList f xs

filterIntList :: (Int -> Bool) -> IntList -> IntList
filterIntList _ Empty = Empty
filterIntList f (x :- xs)
  | f x = x :- filterIntList f xs
  | otherwise = filterIntList f xs

foldlIntList :: (a -> Int -> a) -> a -> IntList -> a
foldlIntList _ accu Empty = accu
foldlIntList f accu (x :- xs) = foldlIntList f (f accu x) xs

{- @a@ is type variable
 - @List@ is type constructor
 - @List Int@ is type 
 -}
infixr 5 :->
data List a = E
            | a :-> List a
  deriving Show

mapList :: (a -> b) -> List a -> List b
mapList _ E = E
mapList f (x :-> xs) = f x :-> mapList f xs

filterList :: (a -> Bool) -> List a -> List a
filterList _ E = E
filterList f (x :-> xs)
  | f x = x :-> filterList f xs
  | otherwise = filterList f xs

foldlList :: (a -> b -> a) -> a -> List b -> a
foldlList _ a E = a
foldlList f a (x :-> xs) = foldlList f (f a x) xs
