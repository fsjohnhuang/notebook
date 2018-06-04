main = do
  putStrLn $ show step1
  putStrLn $ show step2
  putStrLn $ show step3
  putStrLn $ show step4
  putStrLn $ show dd
  putStrLn $ show d1
  putStrLn $ show (execOps [])
  putStrLn $ show (execOps' [])
  putStrLn $ show (execOps1 [3,4])
  putStrLn $ show (execOps1' [3,4])

newtype State' s a = State' { runState' :: (a, s) }
  deriving Show

instance Functor (State' s) where
  fmap f (State' x) = State' ((f . fst) x, snd x)

newtype State s a = State { runState :: s -> (a, s) }

instance Functor (State s) where
  -- fmap :: (a -> b) -> State s a -> State s b
  fmap f (State g) = State (\x -> let (a, s) = g x
                                  in (f a, s))

instance Applicative (State s) where
  pure a = State (\s -> (a, s))
  -- <*> :: State s (a -> b) -> State s a -> State s b
  -- f   :: s -> ((a -> b), s)
  -- g   :: s -> (a, s)
  -- (\a b c -> ...) <$> f1 <*> f2 <> f3, execution sequence is from f1 to f3
  -- return value of f3 restored in a, f2 restored in b and f3 restored in c.
  (State f) <*> (State g) = State (\x -> let (h, s) = f x
                                             (a, s') = g s
                                         in (h a, s'))

-- Functor and Applicative just can update the value field
-- Monad can update the value and the state field

instance Monad (State s) where
  return = pure
  -- (>>=) :: State s a -> (a -> State s b) -> State s b
  (State f) >>= g = State (\x -> let (a, s) = f x
                                     (State h) = g a
                                 in h s)

-- monad sample
statefulOps = (statefulPush 2) >>=
              \_ -> statefulPop >>=
              return
execOps = runState statefulOps

statefulOps' = do
  statefulPush 2
  statefulPop
execOps' = runState statefulOps'

statefulOps1 = (statefulPush 2) >>= 
               \_ -> statefulPop >>= 
               \a -> statefulPop >>= 
               \b -> return $ a + b
execOps1 = runState statefulOps1

statefulOps1' = do
  statefulPush 2
  a <- statefulPop
  b <- statefulPop
  return $ a + b
execOps1' = runState statefulOps1'

atom = []
defaultStatefulEval a = State (\s -> (a, s))
statefulPush a = State (\s -> ((), a:s))
statefulPop = State (\(x:xs) -> (x, xs))

statefulP a = State (\s -> (show a ++ "!", s))

dd = runState
  (statefulPop >>= statefulP) [1,2]

d1 = runState
  (fmap (\a -> show a ++ "!") statefulPop) [1,2]

step1 = runState
  (statefulPush 4) atom
step2 = runState
  (statefulPush 2) (snd step1)

statefulPopPlus = fmap (+1) statefulPop
statefulPopPlus2 = fmap (+2) statefulPop

--step3 = runState
--  statefulPopPlus2 (snd step2)
step3 = runState
  (statefulPush 3) (snd step2)

--step4 = runState
--  ((\a b c -> a + b + c) <$> statefulPop <*> statefulPop <*> statefulPop) (snd step3)

proc4 state = runState
  ((\a b c -> c) <$>
   (statefulPush 5) <*>
   statefulPop <*>
   statefulPop) state

step4 = proc4 $ (snd step3)

--(def a (atom ""))

--(defn eval1 [a]
--  (set! a 1)
--  (set! a 2))
