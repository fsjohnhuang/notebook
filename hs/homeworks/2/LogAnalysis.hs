module LogAnalysis where

import Log

main = putStrLn "H"

dummyLogs :: [String]
dummyLogs = [ "E 2 562 help help"
            , "I 29 la la la"
            , "This is not in the right format"]

parse :: [String] -> [LogMessage]
parse = map parseMessage

parseMessage :: String -> LogMessage
parseMessage = getLogMessage . words

getLogMessage :: [String] -> LogMessage
getLogMessage ("E":level:timeStamp:xs) = LogMessage (Error $ read level) (read timeStamp) (unwords xs)
getLogMessage ("I":timeStamp:xs) = LogMessage Info (read timeStamp) (unwords xs)
getLogMessage ("W":timeStamp:xs) = LogMessage Warning (read timeStamp) (unwords xs)
getLogMessage xs = Unknown (unwords xs)

-- binary search tree
insert :: LogMessage -> MessageTree -> MessageTree
insert log Leaf = Node log Leaf Leaf
insert nlog (Node log l r)
  | nlog == log = Node nlog l r
  | nlog < log = Node log (insert nlog l) r
  | otherwise = Node log l (insert nlog r)

isValidateLog :: LogMessage -> Bool
isValidateLog (LogMessage _ _ _) = True
isValidateLog _ = False

getValidateLogs :: [LogMessage] -> [LogMessage]
getValidateLogs = filter isValidateLog

build :: [LogMessage] -> MessageTree
build = (foldl (\tree log -> insert log tree) Leaf) . getValidateLogs

-- inorder traversal
inOrder :: MessageTree -> [LogMessage]
inOrder Leaf = []
inOrder (Node log l r) = inOrder l ++ (log : inOrder r)

result = (build . getValidateLogs . parse) dummyLogs
