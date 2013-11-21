module Tpl where

import Control.Applicative ( (<$>) )
import System.Random
import System.IO

replace :: Eq a => [a] -> [a] -> [a] -> [a]
replace [] _ _ = []
replace s find repl =
    if take (length find) s == find
        then repl ++ (replace (drop (length find) s) find repl)
        else [head s] ++ (replace (tail s) find repl)

template :: [(String, String)] -> String -> String
template [] s = s
template (m:ms) s = template ms (replace s (fst m) (snd m))

{-m = [("Path", "a car"),("y", "a animal")]
s = "this is Path"
main :: IO ()
main = do
  print $ strRep m s-}
