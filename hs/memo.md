## Intro
### Features of functional languague
1. Functions are first-class.
2. The language is centered around evaluating expressions rather than executing instructions.

### Expressions are Referentially transparent(引用透明)
1. Everything (variables, data structures ...) is immutable.
2. Expressions have no side-effect.
3. Evaluating the same expression with the same arguments results in the same ouput every time.

Benefits of referentially transparent:
1. Equational reasoning(等式推导) and refactoring: replace equals by equals.
2. Parallelism: not to effect to one another.


### Benefits of Types
1. Helps clarify thinking and express program structure.
2. Serves as a form of documentation.
3. Truns run-time errors into compile-time errors.

### Abstraction
**Parametric polymorphism**, **higher-order functions**, and **type classes** are all aid in the fight against repetition.
`Monoid`,`Semigroup`,`Functor`,`Applicative`,`Monad` are common abstract patterns with laws.

### Wholemeal Progamming
Think big - first solve a general problem, then extract the interesting bits and pieces by transforming the general program into more specialised ones.
Wholemeal programming is complemented by projective programming.

Example to show the differenc between imperative and functional
```js
let lst = [1,2,3,4]
    sum = 0
for (let i = 0, l = lst.length; i < l; ++i){
  sum += 3 * lst[i]
}
```
```hs
lst = [1..4]
sum $ map (3*) lst
```
1. No need to worry about the low-level iterating over an array by keeping track of a current index.
2. Two seperate operations: multiplying every item in a list by 3; summing the results.

Breaking the function into a pipeline of incremental transformations to an entire data structure.

## Module
### dir structure
```
Core.hs
Util.hs
Geometry
   |----- Sphere.hs
   |----- Cube.hs
```
### source file
```
module Core
where

import Geometry.Sphere
-- import module by qualified name
import qualified Util
-- import module by qualified name with indicated members
import qualified Util (filter)
-- import module by qualified alias
import qualified Util as U
-- just import @nub@ and @sort@ from @Data.List@ module
import Data.List (nub, sort)
-- import all members of @Data.Maybe@ except @mapMaybe@
import Data.Maybe hiding (mapMaybe)

main =
  do putStrLn $ "Area:" ++ show $ area 123
  do putStrLn $ "Volumn:" ++ show $ volumn 123
  do putStrLn $ show $ U.filter (>3) [1..5]
  do putStrLn $ show $ Util.filter (>3) [1..5]
```

Geometry/Sphere.hs
```
module Geometry.Sphere
( volume
, area
) where

volumn :: Float -> Float
volumn radius = (4.0 / 3.0) * pi * (radius ^ 3)

area :: Float -> Float
area radius = 4 * pi * (radius ^ 2)
```

Util.hs
```
module Util
( filter
) where

filter :: (a -> Bool) -> [a] -> [a]
filter _ [] = []
filter p (x:xs)
  | p x = x : filter p xs
  | otherwise = filter p xs
```

## Comment
```
-- single comment
{- multlines comment 
   abcdefg. -}
```

## Declarations
```
x :: Int
x = 2
```
`::`, is pronounced "has type". so `x :: Int` means variable x with type Int.
`=`, means definition like in mathematics rather than assignment in C or Java-ish. so `x = 2` means x is defined to be 4, and multiple definition is not allowed.

```
map :: (a -> b) -> [a] -> [b]
fmap :: Functor f => (a -> b) -> f a -> f b

words :: String -> [String]
unwords :: [String] -> String

reverse :: [a] -> [a]
```

```
-- if-then-else
if condition
then expression
else expression
```

## GHCi Commands
```
-- Ask for the type of an expression, returns type signature.
:type something
:t something

-- Load Haskell files
:load path
:l path

-- Reload Haskell files
:reload path
:r path

:info -- ??????

:? -- show a list of commands
```

`()` is an empty tuple, pronounced *unit*

## Arithmetic
```
+,-,/,*,^

mod :: (Integral a) => a -> a -> a
sum :: (Num a, Foldable t) => t a -> a
```
backticks make a function name into an **infix operator**(中缀操作符). like make `mod 1 2` to `1 ``mod`` 2`.

Type Convertions
```
fromIntegral :: (Integral a, Num b) => a -> b
round,floor,ceiling :: (Integral b, RealFrac a) => a -> b
show :: Show a => a -> String
read :: Read a => String -> a

type ReadS a = String -> [(a, String)]
reads :: Read a => ReadS a
-- a parser for a type a, represented as a function that takes a String and returns a list of possible parses as (a, String) pairs.
-- returns [(a, "")] if parse is successful.

reads "1" :: [(Int, String)]
```

## Functions
```
myFactorial :: (Int a) => a -> a
myFactorial 1 = 1
myFactorial n = n * (myFactorial $ n - 1)
```
### Anonymous Function / Lambda Abstraction
```
(\arg1 arg2 ... argn -> expression)
```
operator section(操作符截断)
```
(>3) == (\o1 -> o1 > 3)
(*3) == (\o1 -> o1 * 3)
```

### Guards
```
myFactorial :: (Int a) => a -> a
myFactorial n
  | n == 1 = 1
  | otherwise = n * (myFactorial $ n - 1)
```

### Tuple
pair, `(a,b)`
empty tuple, `()`, pronounced unit
```
pair = (1,2)
fst pair -- 1
snd pair -- 2
```

### List
stands for non-deterministic values.
```
1:2:3:[] == [1..3]
```
`a ++ (b ++ (c ++ (d ++ (e ++ f))))` is much more efficient than `((((a ++ b) ++ c) ++ d) ++ e) ++ f  `.because List is constructed from left to right.

### Difference List
which executes prepending only
```
main = putStrLn $ show diffListResult

newtype DiffList a = DiffList { getDiffList :: [a] -> [a] }

toDiffList :: [a] -> DiffList a
toDiffList xs = DiffList (xs++)

fromDiffList :: DiffList a -> [a]
fromDiffList (DiffList f) = f []

instance Monoid (DiffList a) where
  mempty = DiffList ([]++)
  (DiffList f) `mappend` (DiffList g) = DiffList $ f . g

instance (Show a) => Show (DiffList a) where
  show (DiffList f) = show $ f []

diffListResult = foldl1 `mappend` $ map toDiffList [[1,2,3], [4,5,6]]
```

### Algebraic data types
```
data NaturalNum = 1 | 2 | 3 | 4
  deriving (Show, Eq)

data LogMessage = Info
          | Error Int
  deriving (Show,Eq)
log1 :: LogMessage
log1 = Info
log2 :: LogMessage
log2 = Error 123

type Name = String
type Age = Int
data Sex = Male | Female
  deriving Show
data Person = Person Name Age Sex
  deriving Show

john :: Person
john = Person "john" 18 Male
```
`NaturalNum`,`LogMessage`,`Sex` and `Person` which is left to the assignment mark are **type constructor**. Those stand for data types.

`1`,`Info`,`Person` which is right to the assignment mark are **data constructor**. Data constructor is just like function, can be invoked with 0 or many arguments. One type constructor could correspond to at least one data constructor, seperated by `|`.

Type constructor and data constructor inhabit in different namespaces. And must always start with captial letter.

## Polymorphism
### Polymorphic data types
```
-- define polymorphic data type
infixr 5 :->
data List a = Empty
            | a :-> Empty
intLst :: List Int
intLst = 1 :-> 2 :-> Empty
strLst :: List String
strLst = "abc" :-> "def" :-> Empty

-- define polymorphic function
mapList :: (a -> b) -> List a -> List b
mapList _ Empty = Empty
mapList f (x :-> xs) = f x :-> mapList f xs
```
`a` is type variable, and must be start with lowercase letter.

### Record syntax
```
data Sex = Male | Female
  deriving Show
data Person = Person {name :: String, age :: Int, sex :: Sex}
  deriving Show

person :: Person
person = Person {name = "john", age = 18, sex = Male}

getName :: Person -> String
getName (Person {name = c}) = c

name person -- "john"
```

### Recursive data types
```
-- Custom Int List Int type.
data IntList = EmptyList
             | Cons Int IntList
lst1, lst2 :: IntList
lst1 = Cons 1 (Cons 2 EmptyList)
lst2 = 1 `Cons` 2 `Cons` EmptyList
```
Binary Search Tree
```
type Content = Int
data Tree = EmptyTree
          | Node Content Tree Tree

insert :: Content -> Tree -> Tree
insert n EmptyTree = []
insert n (Node o left right)
  | n == o = Node n left right
  | n < o  = Node o (insert n left) right
  | n > o  = Node o left (insert n right)

build :: [Content] -> Tree
build = foldr insert EmptyTree

inOrder :: Tree -> [Content]
inOrder EmptyTree = []
inOrder (Node content left right) = inOrder left ++ (content : inOrder right)
```

`Prelude` module is implicitly imported into every Haskell program.
`Data.List`
use `foldr'` instead of `foldr`

`Data.Maybe` module has functions for working with Maybe values.
a Maybe value represents a computation that might have failed.
a List value represents non-deterministic values.
a Writer value represents the value have another value attached that acts as a sort of log value.
and allow to do computations while making sure that all log values are combined into one log value that get attached to the final result.

### Fixity Declaration
Defines functions as operators(infix functions).
1. The name of function/opertor must be comprised of only special characters.
2. The name of infix data constructor must be start with `:`.
3. Priority is higher while has greater fixity.
4. `infixl` means operator is according to left-associative.
5. `infixr` means operator is according to right-associative.
```
-- Define +: operator
infixl 5 +:
(+:) :: Int -> Int -> Int
(+:) a b = sum [1, a, b]

result = 1 +: 2 +: 3
-- or result = (+:) ((+:) 1 2) 3
-- result == 8

-- Define :->: data constructor
infixr 5 :->:
data Lst = Empty
         | Int :->: Lst
  deriving Show
lst :: Lst
lst = 1 :->: 2 :->: Empty
```

### Pattern-matching
Pattern grammer:
```
pat ::= _
     |  var
     |  var @ ( pat )
     |  ( Data-Constructor pat1 pat2 ... patn )
```
`_` is wildcard, means we don't care about this variable. And Haskell wouldn't evaluate this expression.

#### Case expression
Case expression is the fundamental construct for doing pattern-matching.
```
case expr of
  pat1 -> expr1
  pat2 -> expr2
```

## Total and Partial Functions
Partial Function(偏函数)
1. There are certain inputs for which the function will crash.
2. There are certain inputs make the function recurse infinitely.

有输入不一定有输出，有可能报错，或不断执行

Total Function
1. Functions are well-defined for all possible inputs.

有输入一定有输出

Haskell内置的partial function
```
{- head, tail, init, last, (!!) is partial functions
 - Define total function by pattern-matching and return @Maybe a@
 -}
head' :: [a] -> Maybe a
head' [] = Nothing
head' (x:_) = Just x

last' :: [a] -> Maybe a
last' [] = Nothing
last' = head' . reverse

tail' :: [a] -> [a]
tail' [] = []
tail' (_:xs) = xs

init' :: [a] -> [a]
init' [] = []
init' (_:x:xs) = x : init' xs
```
Cautions:
```
{- would throw @type variable a is ambiguous@
 - because of ghc cannot recognize type from @[]@
 - so we should add @type annotation@
 - @let a = head' ([] :: [Int]) @
main = let a = head' []
       in
       do putStrLn $ show a
```
If some conditions are really guaranteed, then the types should reflect the guaranteed.
```
-- define a new type to reflect the guaranteed.
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

-- usage
lst = [1,2,3]
nelLst = listToNel lst
headNel nelLst
```

## List Comprehension
??

## Type Classes
Haskell types are erased by the compiler after being checked.

Type Class correspond to sets of types which have certain operations defined for them.
```
-- definition of type class Eq
class Eq a where
  (==) :: a -> a -> Bool
  (/=) :: a -> a -> Bool
  a == a = not $ a /= a
  a /= a = not $ a == a

-- instance of Eq
data Colors = Red | Green
instance Eq Colors where
  Red == Red     = True
  Green == Green = True
  _ == _         = False

Red == Green


-- instance of Eq
data Plus a = Plus a
instance Eq a => Eq (Plus a) where
  (Plus x) == (Plus y) = x == y

Plus 1 == Plus 2
```
`Eq` requires type variable `a` is a concrete type, and `Plus a` is a concrete type.

**The differences between Java's interface and Type Class.**
1. When a Java class is defined, any interfaces it implements must be declared.
   Type class intances are declared separately from the declaration of the corresponding types, and can even be put in a separate module.
2. multi-paramerter type class.
```
{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances #-}
class Blerg a b where
  blerg :: a -> b -> Bool

instance Blerg Int String where
  blerg a b = show a ++ b

putStrLn $ show $ blerg (1::Int) "2"
-- False
```
Write pregme `{-# LANGUAGE MultiParamTypeClasses #-}` to enable multi-parameter type classes feature.

### Functor
Functor is computational context.
```
class Functor (f :: * -> *) where
  fmap :: (a -> b) -> f a -> f b
  (<$) :: a -> f b -> f a
  (<$) = fmap . const
```
`f` is a type constructor not a concrete type with kind `* -> *`, means it has to take exactly one concrete type as type paramerter.(ie. Maybe)
`fmap` means map over the Functor instance. Extracts the value from the computational context, and invoke a given function by it, then put the result into the computational context again.
`fmap` is called **lifting function**, if we write the type definition in `fmap: (a -> b) -> (f a -> f b)` style.

`<$` is to put the normal value into the indicated computational context.
```
:t (1 <$ Left "") -- Left ""
:t (1 <$ Right "whatever") -- Right 1
```

instances of Functor
```
instance Functor Maybe where
  fmap _ Nothing = Nothing
  fmap f (Just a) = Just $ f a

instacne Functor (Either a) where
  fmap f (Right a) = Right $ f a
  fmap _ (Left a) = Left a

instance Functor IO where
  fmap f action = do
      result <- action
      return $ f result

{- @-> r@ is a type of function, as @a -> b@.
 - :k (->) = * -> * -> *
 - fmap :: (a -> b) -> f a -> b, @a@ and @b@ are the return type of function.
 -}
instance Functor ((->) r) where
  fmap = (.)
```

Laws:
1. `fmap id == id`
2. `fmap f . fmap g == fmap (f . g)`

examples
```
-- IO operation
main = do
        msg <- fmap ("echo:"++) . fmap (++"!") $ getLine
        -- msg <- fmap (("echo:"++) . (++"!")) $ getLine
        putStrLn msg
```
defines type Tree as an instance of Functor
```
data Tree a = Empty
            | Node a (Tree a) (Tree a)
  deriving Show

instance Functor Tree where
  fmap _ Empty = Empty
  fmap f (Node a l r) = Node (f a) (fmap f l) (fmap f r)
```

### Applicative Functor
Functors for this sort of "contextual application" is possible are called Applicative.

```
class Functor f => Applicative (f :: * -> *) where
  pure :: a -> f a
  (<*>) :: f (a -> b) -> f a -> f b
  -- Sequence actions, discarding the value of the first argument.
  (*>) :: f a -> f b -> f b
  -- Sequence actions, discarding the value of the second argument.
  (<*) :: f a -> f b -> f a
```
`pure` means put a value into a minimal context.
`<*>` pronounced "ap", short for "apply".

instances of Applicative
```
instance Applicative Maybe where
  pure a = Just a
  Nothing <*> _ = Nothing
  (Just f) <*> a = fmap f a

-- the default List instance of Applicative
instance Applicative [] where
  pure x = [x]
  fs <*> xs = [f x | f <- fs, x <- xs]
  {- or [] <*> _  = []
        (f:fs) <*> xs = map f xs ++ (fs <*> xs)

-- zipList instance
newtype ZipList a = ZipList a { getZipList :: [a] }
  deriving (Show, Eq, Functor)

instance Applicative ZipList where
  pure = ZipList . repeat
  ZipList fs <*> ZipList xs = ZipList $ zipWith ($) fs xs

instance Applicative IO where
  pure = return
  a <*> b = do
    f <- a
    x <- b
    return $ f x

-- reader or envirnment Applicative
instance Applicative ((->) r) where
  pure = const
  (<*>) :: (r -> a -> b) -> (r -> a) -> (r -> b)
  f <*> g = \x -> f x (g x)
```

Applicative laws:
1. identity, `pure id <*> v == id v == v`
2. homomorphism, `f <$> x == pure f <*> x`, `pure f <*> pure x == pure $ f x`
3. composition, `pure (.) <$> u <*> v <*> w == u <*> (v <*> w)` ???
4. interchange, `u <*> pure y == pure ($ y) <*> u == ($ y) <$> u`

```
f x y z = x + y + z
pure f <*> Just 1 <*> Just 2 <*> Just 3 == fmap f (Just 1) <*> Just 2 <*> Just 3
-- means @pure f <*> x == fmap f x@
-- and standard library exports @(<$>) :: Functor f => (a -> b) -> f a -> f b@
-- so we could simplify the above equation
f <$> Just 1 <*> Just 2 <*> Just 3
```
if a type is instance of Functor, we can lift a function receiving two parameters only, but we can lift a function no matter how much parameters with while the type is instance of Applicative.

examples
```
main = do
  msg <- (++) <$> getLine <*> getLine
  putStrLn msg
```
```
pair :: Applicative f => f a -> f b -> f (a, b)
pair = liftA2 (,)
```

#### Helper Function
```
import Control.Applicative

-- `liftA`, lifting function of Applicative with 1 parameters
liftA (+1) (Just 1) == f <$> Just 1

-- `liftA2`, lifting function of Applicative with 2 parameters
liftA2 (+) (Just 1) (Just 2) == f <$> Just 1 <*> Just 2

-- `liftA3`, lifting function of Applicative with 3 parameters
liftA3 (\a b c -> sum [a,b,c]) (Just 1) (Just 2) (Just 3) == f <$> Just 1 <*> Just 2 <*> Just 3
```

```
sequenceA :: Applicative f => [f a] -> f [a]
sequenceA [] = pure []
sequenceA (x:xs) = (:) <$> x <*> sequenceA xs

sequenceA' :: Applicative f => [f a] -> f [a]
sequenceA' = foldr (liftA2 (:)) (pure [])

-- sample
sequenceA [(+3), (+1), (*2)] 3
-- result is [6, 4, 6]

sequenceA [[1,2], [3,4]]
-- result is [[1,3], [1,4], [2,3], [2,4]]
```

### newtype
construct a new type from existing type.
```
newtype ZipList a = ZipList { getZipList :: [a]}
  deriving (Show, Eq, Ord)

newtype Pair a b = Pair { getPair :: (a, b) }
  deriving (Show, Eq, Ord)

instance Functor (Pair a) where
  fmap f (Pair (x, y)) = Pair (x, f y)
  
newtype Pair1 b a = Pair1 { getPair1 :: (a, b) }
  deriving (Show, Eq, Ord)

instance Functor (Pair1 b) where
  fmap f (Pair (x, y)) = Pair (f x, y)

newtype DiffList a = DiffList { getDiffList :: [a] -> [a]}
  deriving (Show, Eq)

fromDiffList :: DiffList a -> [a]
fromDiffList (DiffList f) = f []
```

the difference btween `data` and `newtype`
1. Value constructor of `newtype` must receive **one and only one parameter**.
2. `newtype` is much more effecient than `data`.
3. `data` is to make a new type from scratch, but `newtype`is to make a new type from an existing type.
4. Haskell wouldn't unwrap the value from the type defined by `newtype`, but it will do so to `data`
```
data ZipList1 a = ZipList1 {getZipList1 :: [a]}
newtype ZipList2 a = ZipList2 {getZipList2 :: [a]}

CoolBool1 :: ZipList1 Int -> Bool
CoolBool1 (ZipList1 _) = True

CoolBool2 :: ZipList2 Int -> Bool
CoolBool2 (ZipList2 _) = True

CoolBool1 undefined
-- result:
-- *** Exception: Prelude.undefined 

CoolBool2 undefined
-- result:
-- True
```

`undefined` means an erroneous computation.

### Monoid
types with an associative binary opertaion that has an identity.
defined in `Data.Monoid`
```
class Monoid (m :: *) where
  mempty :: m
  mappend :: m -> m -> m
  mconcat :: [m] -> m
  mconcat = foldr mappend mempty

(<>) :: Monoid a => a -> a -> a
infixr 6 <>
```
`mempty` is an identity of `mappend`, identity value for a particular monoid.
`mappend` is an associative binary operation.

the laws
1. identity, `x <> mempty == x`
2. identity, `mempty <> x == x`
3. associative, `x <> (y <> z) = x <> y <> z`

instances
```
instance Monoid [a] where
  mempty = []
  mappend = ++

instance Monoid String where
  mempty = ""
  mappend = ++

newtype Product a = Product {getProduct :: a}
  deriving (Eq, Ord, Read, Show, Bounded, Generic, Generic1, Num)
newtype Sum a = Sum {getSum :: a}
  deriving (Eq, Ord, Read, Show, Bounded, Generic, Generic1, Num)
instance Num a => Monoid (Product a) where
  mempty = Product 1
  mappend (Product a) (Product b) = Product $ a * b
instance Num a => Monoid (Sum a) where
  mempty = Sum 0
  mappend (Product a) (Product b) = Product $ a + b

newtype All = All {getAll :: Bool}
  deriving (Eq, Ord, Read, Show, Bounded)
newtype Any = Any {getAny :: Bool}
  deriving (Eq, Ord, Read, Show, Bounded)
instance Monoid All where
  mempty = All True
  mappend (All x) (All y) = All $ x && y
instance Monoid Any where
  mempty = Any True
  mappend (Any x) (Any y) = Any $ x || y

getAny . mconcat . map Any $ [True, False, True]
-- result: True

instance Monoid Ordering where
  mempty = EQ
  mappend EQ y = y
  mappend LT _ = LT
  mappend GT _ = GT

lengthCompare :: String -> String -> Ordering
lengthCompare x y = compare (length x) (length y) 
                    <> compare x y

instance Monoid a => Monoid (Maybe a) where
  mempty = Nothing
  mappend Nothing _ = Nothing
  mappend _ Nothing = Nothing
  mappend (Just x) (Just y) = Just $ x <> y

-- if we can not guarantee the value inside Maybe is an instance of Monoid
newtype First a = First { getFirst :: Maybe a }
newtype Last a = Last { getLast :: Maybe a }

instance Monoid (First a) where
  mempty = First Nothing
  mappend (First (Just x)) _ = (First (Just x))
  mappend Nothing x = x

instance Monoid (Last a) where
  mempty = Last Nothing
  mappend _ (Last (Just x)) = (Last (Just x))
  mappend x Nothing = x
```

### Semigroup
```
class Semigroup a where
  mappend :: a -> a -> a
```
1. associative, `x <> (y <> z) = x <> y <> z`

### Foldable
defined in `Data.Foldable`
```
class Foldable (t :: * -> *) where
  fold :: Monoid m => t m -> m
  fold = foldMap id

  foldMap :: Monoid m => (a -> m) -> t a -> m
  foldMap f = foldr (mappend . f) mempty
```

### Monad
```
class Applicative m => Monad (m :: * -> *) where
  return :: a -> m a
  return = pure
  fail :: String -> m a
  (>>=) :: m a -> (a -> m b) -> m b
  (>>) :: m a -> m b -> m b
  m1 >> m2 = m1 >>= const m2
```
`m a` is called monadic value or computation or mobit.
`>>=` called bind.

instance Maybe
```
instance Monad Maybe where
  return = Just
  Nothing >>= _ = Nothing
  Just x >>= k = k x
  (>>) = (*>)
  fail _ = Nothing

{- If the difference btween the both sides of pole is greater than 3,
 - the tightrole walker would fall as losing balance.
 -}
type Birds = Int
type Pole = (Birds, Birds)
landLeft :: Birds -> Pole -> Pole
landLeft x (l, r) = (l + x, r)
landRight :: Birds -> Pole -> Pole
landRight x (l, r) = (l, r + x)

infixl 5 -:
(-:) :: a -> (a -> a) -> a
x -: f = f x

pole = (0, 0)
pole -: landLeft 1 -: landRight 5 -: landRight (-2)
-- the change of pole is: (0, 0) -> (1, 0) -> (1, 5) -> (1, 3)
-- (1, 5) is an error status obviously, but the final result is success. It's wrong.

landLeft' :: Birds -> Pole -> Maybe Pool
landLeft' x (l, r)
  | nl - r -: abs > 3 = Nothing
  | otherwise         = Maybe (nl, r)
  where nl = x + l

landRight' :: Birds -> Pole -> Maybe Pool
landRight' x (l, r)
  | l - nr -: abs > 3 = Nothing
  | otherwise         = Maybe (l, nr)
  where nr = x + r

return pool >>= landLeft 1 >>= landRight 5 >>= landRight (-2)
-- the change of result is: Maybe (0, 0) -> Maybe (1, 0) -> Nothing -> Nothing
```

instance List
```
instance Monad [] where
  return x = [x]
  xs >>= f = concat $ map f xs
  fail _ = []

[1,2,3] >>= (\x -> [x+1])
-- result: [2,3,4]
[1,2,3] >>= (\x -> [x,-x])
-- result: [1,-1,2,-2,3,-3]
listOfTuples = [1,2] >>= \n -> ['a', 'b'] >>= \ch -> return (n, ch)
-- result: [(1, 'a'),(2, 'a'),(1, 'b'),(2, 'b')]
```

instance reader/environment
```
instance Monad ((->) r) where
  return = const
  f >>= g = \w -> g (f w) w

addStuff :: Int -> Int
```

laws:
1. Left identity, `return x >>= f == f x`
2. Right identity, `m >>= return == m`
3. Associative, `m >>= f >>= g == m >>= (\x -> f x >>= g)`

```
(<=<) ::Monad m => (b -> m c) -> (a -> m b) -> (a -> m c)
```

### do notation
its principle is *gluing together the monadic values in sequence*.
```
listOfTuples' :: [(a, b)]
listOfTuples' = do
    n <- [1, 2]
    ch <- ['a', 'b']
    return (n, ch)

failCase :: Maybe Char
failCase = do
    (x:xs) <- Just ""
    return x
-- result: Nothing
-- it would invoke `fail` function, if there is an error thrown by do block.
```

### Writer Monad
Self-difined Writer instance of Monad.
```
{-# LANGUAGE DeriveFunctor #-}
{- since 7.10 Monad must inherit from Applicative, and Applicative must inherit from Functor.
 - in detail: https://ghc.haskell.org/trac/ghc/wiki/Migration/7.10
 -}
newtype Writer w a = Writer { runWriter :: (a w)}
                     deriving (Functor, Show)

instance Monoid w => Applicative (Writer w) where
  pure = return
  (Writer (f, _)) <*> (Writer (x, m)) = Writer (f x, m)

instance Monoid w => Monad (Writer w) where
  return a = Writer (a, mempty)
  (Writer (x, v)) >>= f = let (Writer (y, v')) = f x
                          in Writer (y, v `mappend` v')

-- in >>= style
gcd' :: Int -> Int -> Writer [String] Int
gcd' a b
  | b == 0 = Writer (a, ["Finish with " ++ show a])
  | otherwise = return a 
                >>= (\x -> Writer (b, [show a ++ " mod " ++ show b])
                           >>= (\y -> gcd' y (x `mod` y)))
```

### State Monad
State is attched to evaluations not live in outer environment.
```
newtype State s a = State { runState :: s -> (a, s) }
instance Functor (State s) where
  -- fmap :: (a -> b) -> State s a -> State s b
  fmap f (State g) = State (f . fst . g)

instance Applicative (State s) where
  pure x = State (\s -> (x, s))
  -- (<*>) :: State s (a -> b) -> State s a -> State s b
  -- (<*>) :: (s -> ((a -> b), s)) -> (s -> (a, s)) -> (s -> (b, s))
  <*> (State f) (State g) = State (\s -> let (a, v) = g s
                                             (h, v') = f v
                                         in (h a, v'))

instance Monad (State s) where
  return = pure
  -- (>>=) :: State s a -> (a -> State s b) -> State s b
  -- (>>=) :: (s -> (a, s)) -> (a -> (s -> (b, s))) -> (s -> (b, s))
  >>= (State f) g = State (\s -> let (a, v) = f s
                                     (State h) = g a
                                 in h v)
```
Implements Stack Data Structure with State Monad
```
data Stack a = Stack [a]

-- push and pop without state
push :: a -> Stack a -> Stack a
push x (Stack xs) = x:xs
pop :: Stack a -> a
pop (Stack (x:xs)) = x

-- push and pop with state
spush x = State (\s -> ((), push x s))
spop = State (\s -> (pop s, tail s))


stack = Stack [1,2,3]
{- sequence opertaions on Stack -}
-- 1. restore state each step style
optStack1 :: Stack a -> (a, Stack a)
optStack1 stack = 
  let step1 = runState spop stack
      step2 = runState (spush 4) (snd step1)
      step3 = runState (spush 5) (snd step2)
  in step3
{- 
 - step1 = (1, Stack [2, 3])
 - step2 = ((), Stack [4, 2, 3])
 - step3 = ((), Stack [5, 4, 2, 3])
 -}

-- 2. in <*> style
optStack2 :: Stack a -> (a, Stack a)
optStack2 = runState
  ((\step1 step2 step3 -> step3) <$>
   spop <*>
   spush 4 <*>
   spush 5)

-- 3. in >>= style
optStack3 :: Stack a -> (a, Stack a)
optStack3 = runState
  (spop >>=
   \a1 -> spush 4 >>=
   \a2 -> spush 5 >>=
   \a3 -> return a3)

-- 4. in do notation
optStack4 :: Stack a -> (a, Stack a)
optStack4 = runState
  (do
    a1 <- spop
    a2 <- spush 4
    a3 <- spush 5
    return a3)

{- operation on a value portion -}
spopPlus :: Stack a -> (a, Stack a)
spopPlus = runState $ fmap (+1) spop

result1 = spopPlus $ Stack [3,2,1]
-- result1: (4, Stack [2, 1])

{- operation on many value portions -}
sumTop3 :: Stack a -> (a, Stack a)
sumTop3 = runState $ (\a b c -> a + b + c) <$> spop <*> spop <*> spop

result2 = sumTop3 $ Stack [3,2,1]
-- result2: (6, Stack [])
```

### Useful monadic function
Monadic Function, receiving or return monadic value.
```
-- liftM is the monadic counterpart of fmap.
liftM :: Monad m => (a -> b) -> m a -> m b

-- ap is the monadic counterpart of <*>.
ap :: Monad m => m (a -> b) -> m a -> m b

-- liftM2 is the monadic counterpart of liftA2.
liftM2 :: Monad a => (a -> b -> c) -> m a -> m b -> m c

-- flatten the neat monadic value, Functor and Applicative couldn't perform join operation.
join :: Monad m => m (m a) -> m a

-- filterM is the monadic counterpart of filter 
filterM :: Monad m => (a -> m Bool) -> [a] -> m [a]

-- foldM is the monadic counterpart of foldl
foldM :: Monad m => (a -> b -> m a) -> a -> [b] -> m a
```

join
```
Nothing == join Nothing
Just 1 == join (Just (Just 1))
[1,2,3] == join [[1,2],[3]]
(1, "bbaa") == runWriter $ join (Writer (Writer (1, "aa"), "bb"))
Left "Error" == join $ Left "Error"
```
`m >>= f` == `join (fmap f m)`

### Zipper
A pair that contains **a focused part** of a data structure and **its surroundings** is called a zipper.
moving focus up and down the data structure resembles the operation of a zipper on regular pair of pants.

List can be viewed as Tree which has at most a single sub-list.

## Kind
the type of type
`*`, means concrete type
`* -> *`, means type constructor with one parameter
`* -> * -> *`, means  type constructor with two parameter
sample
```
:k Int
-- Int :: *

:k Maybe
-- Maybe :: * -> *

:k Either
-- Either :: * -> * -> *

:k Either Int
-- Either Int :: * -> *
```

## IO Action
IO action would be performed in these situations:
1. `main` binding
```
main = putStrLn "Hello World!"
```
2. `do` block
```
main = do putStrLn "Hello World!"
          putStrLn "Bye!!"
```
3. `repl` environment
```
Prelude> putStrLn "Hello World!"
```

### `return :: Monad m => a -> m a`
Wrap a pure value into an IO action, doesn't mean get out from current subroutine.
```
main = do m1 <- getLine
```

### `let binding` within `do`
```
-- `in` is optional when invoke `let` under `do` expression.
-- `let binding` is for pure expression bindings only.
main = do
   content <- getLine
   let name = "john"
       message = content ++ name ++ "!!"
   putStrLn message
```

RealFrac,Num,Int,Integer,Bool,Float,Double,Rational


### IO actions bindings
```
variable <- IO a
```

Prelude module
```
putStrLn :: String -> IO ()
-- print the content to terminal immediately

putStr :: String -> IO ()
-- put the content to buffer only ???

getLine :: IO String
{-
  -- Fetch content from IO Functor
  content <- getLine
-}
```

System.IO module


mapM_ :: (Monad m, Foldable t) => (a -> m b) -> t a -> m ()

## GHC
`ghci`, enter REPL of GHC
`runghc <hs-file-path>`, run the hs file immediately

package -*> module
`ghc-pkg list`, list the installed packages.


Monad, Monad Transformation, Monad Control
Arrow, Arrow Transformer

## Debug
```
import Debug.Trace (trace)

-- trace :: String -> a -> a
-- traceM :: Monad m => String -> m ()

subStr :: String -> Int -> String
subStr s n = trace ("s is " ++ show s) take n s

monadicSubStringToIndex ::  Int -> State String ()
monadicSubStringToIndex n = do
  s <- get
  traceM $ "original string is " ++ show s   <-- 看这里看这里
  modify $ (\s -> take n s)

main :: IO ()
main = putStrLn $ snd $ runState (monadicSubStringToIndex 2) "abcde"
```
