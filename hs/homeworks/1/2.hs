{- The Towers of Hanoi -}

type Peg = String
type Move = (Peg, Peg)
--hanoi :: Integer -> Peg -> Peg -> Peg -> [Move]

data Thing = A 
      | B 
      | C
  deriving Show

isThing :: Thing -> Bool
isThing A = True
isThing n = False
