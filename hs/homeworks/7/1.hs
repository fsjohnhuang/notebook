{- RPN calculator 
 - valid RPN expression is "1 2 * 4 +"
 - RPN(Reverse Polish Notation) is a suffix notation
 - a - b + c -> a b - c +
 - advantage of RPN is to simplify the complexity expression into an easy one which can be evaluated by pushing and poppingk on stack.
 -}

import Control.Monad

main = putStrLn $ show ((eval' . lexer) "1 2 - 4 +")

type Token = String
type TokenStream = [Token]

{- simple one -}
lexer :: Token -> TokenStream
lexer = words

eval :: TokenStream -> Int
eval = head . (foldl solve [])
  where
    solve (x:y:xs) "*" = (x * y) : xs
    solve (x:y:xs) "+" = (x + y) : xs
    solve (x:y:xs) "-" = (y - x) : xs
    solve xs token = read token : xs

{- capable of graceful failure -}
numberize :: Token -> Maybe Int
numberize token = case reads token of
                  [(x, "")] -> Just x
                  _ -> Nothing

solve' :: [Int] -> Token -> Maybe [Int]
solve' (x:y:xs) "*" = return $ (x * y) : xs
solve' (x:y:xs) "+" = return $ (x + y) : xs
solve' (x:y:xs) "-" = return $ (y - x) : xs
solve' xs token = liftM (:xs) (numberize token)

-- m b = Maybe [Int]
eval' :: TokenStream -> Maybe Int
eval' = (liftM head) . (foldM solve' [])
eval1' tokens = do
  [result] <- foldM solve' [] tokens
  return result
