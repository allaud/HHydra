module Get where

import Text.ParserCombinators.Parsec
import Control.Applicative hiding ((<|>), optional, many)

cells :: GenParser Char st [String]
cells =
    do first <- cellContent
       next <- remainingCells
       return (first : next)

remainingCells :: GenParser Char st [String]
remainingCells =
    (char ',' >> cells)            -- Found comma?  More cells coming
    <|> (return [])                -- No comma?  Return [], no more cells

cellContent = do
  many (oneOf " ")
  host <- many (noneOf ",[]()")
  many (oneOf " ")
  return (host)


{-main :: IO ()
main = do
    print $ parse cells "" " http://a.ru,  http://b.ru, http://c.ru"-}
