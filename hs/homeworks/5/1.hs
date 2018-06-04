main = let a = (Lit 3 :+: Lit 3) :*: Lit 2 
           b = eval a
       in
       do
       putStrLn $ show a
       putStrLn $ show b

{- Exercise 1 -}
infixl 5 :*:
infixl 4 :+:
data ExprT = Lit Integer
           | ExprT :*: ExprT
           | ExprT :+: ExprT
  deriving (Show, Eq)

class Calculator e where
  eval :: e -> Integer

instance Calculator ExprT where
  eval (Lit a) = a
  eval (a :*: b) = eval a * eval b
  eval (a :+: b) = eval a + eval b

{- Exercise 2 -}
parseExp :: ExprT -> ExprT -> ExprT -> String -> ExprT
