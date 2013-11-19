module Config where

import Text.ParserCombinators.Parsec
import Control.Applicative hiding ((<|>), optional, many)

import Array


ws :: Parser String
ws = many (oneOf " ")

word :: Parser String
word = many letter

rule :: Parser String
rule = many (noneOf ['\"', '\r', '\n', '[', ']', '<', '>'])

cell = do
       name <- word
       ws
       char '<'
       rule <- rule
       char '>'
       ws
       char '['
       hs <- cells
       char ']'
       return (name, rule, hs)


{-main :: IO ()
main = do
    --let rules = ["ab ! [http://asd.ru, http://bsd.ru]","bc  ! [http://asd.ru, http://bsd.ru]"]
    contents <- readFile "config"
    let rules = lines contents
    print $ map (\rule -> parse cell "" rule) rules

-}
