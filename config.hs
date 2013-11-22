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
       rule <- cells
       char '>'
       ws
       char '['
       hs <- cells
       char ']'
       return (name, rule, hs)

rule_line = do
  rules <- cells
  return (rules)
