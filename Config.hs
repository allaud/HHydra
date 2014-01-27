module Config where

import Control.Applicative           hiding ((<|>), optional, many)
import Text.ParserCombinators.Parsec

import Data.List (group)

type Config     = [ConfigLine]
type ConfigLine = (String, [String], [String])

config :: Parser Config
config =
    ruleLine `sepEndBy` try (char '\n')

ruleLine :: Parser ConfigLine
ruleLine = do
    name <- word <?> "rule name"
    spaces
    from <- commaSeparatedList `within` "<>" <?> "redirect shortcut list"
    spaces
    to   <- commaSeparatedList `within` "[]" <?> "redirect destinations list"

    return (name, from, to)

  <?> "Config line"

word :: Parser String
word = many (letter <?> "continuation of word")

within :: Parser a -> String -> Parser a
parser `within` [l, r] =
    char l *> parser <* char r
      <?> ("list within " ++ [l, r])

_parser `within` other =
    error $ "as second parameter, within must get 2 chars, but got: " ++ show (group other)

commaSeparatedList :: Parser [String]
commaSeparatedList =
    cellContent `sepBy` char ','
      <?> "comma separated list"

  where
    cellContent :: Parser String
    cellContent =
        spaces *> many (noneOf ",;[]()<>") <* spaces
