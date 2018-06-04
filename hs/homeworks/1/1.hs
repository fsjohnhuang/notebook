{- Validating Credit Card Numbers.
 - 1. Double the value of every second digit begining from the right.
 - 2. Add the digits of the doubled values and the undoubled digits from the original number.
 - 3. Calculate the remainder when the sum is divided by 10.
 - 4. If the result equals 0, then the number is valid. -}

main = do
  let r = validate 26
  putStrLn $ show r

toDigitsRev :: Integer -> [Integer]
toDigitsRev n
  | n <= 0    = []
  | otherwise = let remainder = n `mod` 10
                    highOrder = floor $ (fromIntegral n) / 10
                in 
                remainder : toDigitsRev highOrder

toDigits :: Integer -> [Integer]
toDigits = reverse . toDigitsRev

doubleEveryOther :: [Integer] -> [Integer]
doubleEveryOther [] = []
doubleEveryOther [a] = [a]
doubleEveryOther (a:b:xs) = a : b*2 : doubleEveryOther xs

sumDigits :: [Integer] -> Integer
sumDigits = sum . (foldl (\accu n -> toDigits n ++ accu) [])

validate :: Integer -> Bool
validate = (0 ==) . (`mod` 10) . sumDigits . doubleEveryOther . toDigitsRev
