{- A very simple file system -}

main = putStrLn $ show $ fsTo "goat_yelling_like_man.wmv" (myDisk, [])

type Name = String
type Data = String
data FSItem = File Name Data | Folder Name [FSItem]
  deriving Show

data FSCrumb = FSCrumb Name [FSItem] [FSItem]
  deriving Show

type FSZipper = (FSItem, [FSCrumb])

break' :: (a -> Bool) -> [a] -> ([a], [a])
break' f xs = foldl (\(as, bs) x -> if (f x) then (as, x:bs) else (x:as, bs)) ([],[]) xs

fsUp :: FSZipper -> Maybe FSZipper
fsUp (item, (FSCrumb name ls rs) : bs) = Just (Folder name $ ls ++ [item] ++ rs, bs)
fsUp (item, []) = Nothing

fsTo :: Name -> FSZipper -> Maybe FSZipper
fsTo _ (File _ _, _) = Nothing
fsTo name (Folder n fs, bs) =
  case break' (isFound name) fs of
  (ls, r : rs) -> Just (r, FSCrumb name ls rs : bs)
  otherwise -> Nothing
  where
  isFound name (File n _) = name == n
  isFound name (Folder n _) = name == n

myDisk :: FSItem  
myDisk = 
    Folder "root"   
        [ File "goat_yelling_like_man.wmv" "baaaaaa"  
        , File "pope_time.avi" "god bless"  
        , Folder "pics"  
            [ File "ape_throwing_up.jpg" "bleargh"  
            , File "watermelon_smash.gif" "smash!!"  
            , File "skull_man(scary).bmp" "Yikes!"  
            ]  
        , File "dijon_poupon.doc" "best mustard"  
        , Folder "programs"  
            [ File "fartwizard.exe" "10gotofart"  
            , File "owl_bandit.dmg" "mov eax, h00t"  
            , File "not_a_virus.exe" "really not a virus"  
            , Folder "source code"  
                [ File "best_hs_prog.hs" "main = print (fix error)"  
                , File "random.hs" "main = print 4"  
                ]  
            ]  
        ]  
