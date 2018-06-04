main = let a = show $ head' []
           b = show $ last' [1,2]
       in
       do
          putStrLn a
          putStrLn b

head' :: Show a => [a] -> Maybe a
head' [] = Nothing
head' (x:_) = Just x

last' :: Show a => [a] -> Maybe a
last' = head' . reverse

data NotEmptyList a = NEL a [a]
  deriving (Show, Eq)

nelToList :: NotEmptyList a -> [a]
nelToList (NEL x xs) = x:xs

listToNel :: [a] -> Maybe (NotEmptyList a)
listToNel [] = Nothing
listToNel (x:xs) = Just $ NEL x xs

headNel :: NotEmptyList a -> a
headNel (NEL x _) = x

tailNel :: NotEmptyList a -> a
tailNel (NEL _ xs) = xs
