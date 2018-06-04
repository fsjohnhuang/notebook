module Log where

import Control.Applicative

data MessageType = Info
                 | Warning
                 | Error Int
                 deriving (Show, Eq)

type TimeStamp = Int

data LogMessage = LogMessage MessageType TimeStamp String
                | Unknown String
                deriving (Show)

instance Eq LogMessage where
  (LogMessage _ a _) == (LogMessage _ b _) = a == b
  _ == _ = False

instance Ord LogMessage where
  (LogMessage _ a _) < (LogMessage _ b _) = a < b
  (LogMessage _ a _) <= (LogMessage _ b _) = a <= b
  

data MessageTree = Leaf
                 | Node LogMessage MessageTree  MessageTree
                 deriving (Show, Eq)
