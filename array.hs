module Array where

import Text.ParserCombinators.Parsec
import Control.Applicative hiding ((<|>), optional, many)

cells :: GenParser Char st [String]
cells =
    do first <- cellContent
       next <- remainingCells
       return (first : next)

remainingCells :: GenParser Char st [String]
remainingCells =
    (char ',' >> cells)
    <|> (return [])

cellContent = do
  many (oneOf " ")
  host <- many (noneOf ",;[]()<>")
  many (oneOf " ")
  return (host)
