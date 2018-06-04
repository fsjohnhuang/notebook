import Data.Ratio

main = do
  putStrLn $ show p1
  putStrLn $ show (fmap (+1) p1)
  putStrLn $ show (pure (+2) <*> p1)
  putStrLn $ show (p1 >>= (\a -> Prob [(a, 1%3)]))
  putStrLn $ show (getAllHeadProb flipThree)

newtype Prob a = Prob { getProb :: [(a, Rational)] } deriving Show

instance Functor Prob where
  fmap f (Prob xs) = Prob $ map (\(a, r) -> (f a, r)) xs

instance Applicative Prob where
  pure x = Prob [(x, 1)]
  -- (<*>) :: [((a->b),r)] -> [(a,r)] -> [(b,r)]
  --(Prob fs) <*> (Prob ps) = let rs = fs >>= \(f, _) -> ps >>= \(a, p) -> return (f a, p)
  --                          in Prob rs
  (Prob fs) <*> (Prob ps) = Prob
                            (do
                              (f, _) <- fs
                              (a, p) <- ps
                              return (f a, p))

flatten :: Prob (Prob a) -> Prob a
flatten (Prob xs) = Prob $ concat $ fmap multAll xs
  where multAll (Prob innerxs, p) = innerxs >>= \(a, p') -> return (a, p'*p)

instance Monad Prob where
  return = pure
  -- Prob a -> (a -> Prob b) -> Prob b
  m >>= f = flatten $ fmap f m

p1 = Prob [(1, 1%3),(2, 2%3)]
p2 = Prob [(Prob [(1,1%3), (2, 2%3)], 1%3)]

data Coin = Heads | Tails deriving (Show, Eq)
coins, loadedCoins :: Prob Coin
coins = Prob [(Heads, 1%2), (Tails, 1%2)]
loadedCoins =  Prob [(Heads, 1%10), (Tails, 9%10)]
flipThree = do
            a <- coins
            b <- coins
            c <- loadedCoins
            return (all (==Tails) [a,b,c])

getAllHeadProb :: Prob Bool -> Rational
getAllHeadProb = snd . head . (filter (\(a, _) -> a)) . getProb
