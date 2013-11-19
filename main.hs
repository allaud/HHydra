module Main where

import Text.ParserCombinators.Parsec
import Control.Applicative hiding ((<|>), optional, many)
import Network
import System.IO
import Control.Monad
import Data.Either

import Config
import Server


{-main :: IO ()
main = do
    --let rules = ["ab ! [http://asd.ru, http://bsd.ru]","bc  ! [http://asd.ru, http://bsd.ru]"]
    contents <- readFile "config"
    let rules = lines contents
    print $ map (\rule -> parse cell "" rule) rules

-}
handleAccept :: Handle -> String -> [(String, String, [String])] -> IO ()
handleAccept handle hostname rules = do
  putStrLn $ "Handling request from " ++ hostname
  request <- fmap (parseRequest . lines) (hGetContents handle)
  print $ (options request) ++ [("Path", path request)]
  print rules
  respond request handle
  return ()

main = withSocketsDo $ do
  sock <- listenOn (PortNumber 9000)
  contents <- readFile "config"
  let rules = map (\rule -> (\(Right t) -> t) $ (parse cell "" rule)) (lines contents)

  putStrLn "Listening on port 9000"

  forever $ do
    (handle, hostname, port) <- accept sock
    handleAccept handle hostname rules
    hClose handle
