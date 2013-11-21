module Main where

import Text.ParserCombinators.Parsec
import Control.Applicative hiding ((<|>), optional, many)
import Control.Applicative ( (<$>) )
import System.Random

import Network
import System.IO
import Control.Monad
import Data.Either
import Data.List
import Text.Regex.Posix

import Config
import Server
import Tpl

rule_eval :: String -> Bool
rule_eval r = eval $ (r =~ "#\\{(.+)\\} +(.+) +(.+)" :: [[String]])
  where eval ([[_, str, re, "=~"]]) = str =~ re :: Bool
        eval ([[_, str, re, "=="]]) = str == re :: Bool

rules_eval :: [String] -> Bool
rules_eval a = all id (map rule_eval a)

randomItem :: [String] -> IO String
randomItem xs = (xs!!)  <$> randomRIO (0, length xs - 1)

respond :: Request -> Handle -> String -> IO ()
respond request handle redirect_host = do
  putStrLn $ show request
  let response = Response {version = "HTTP/1.1", statuscode = 302, location = redirect_host}
  hPutStr handle $ show(response)

handleAccept :: Handle -> String -> [(String, [String], [String])] -> IO ()
handleAccept handle hostname rules = do
  request <- fmap (parseRequest . lines) (hGetContents handle)
  let params = (options request) ++ [("Path", path request)]
  let clean_rules = map (\(_, r, _) -> r) rules
  let tpl = \r -> template params r
  let t_rules = map (\(rs) -> map tpl rs ) clean_rules
  let (Just ((_, _, arr), _)) = find (\(_, t) -> t == True) $ zip rules (map (\x -> rules_eval x) t_rules)
  redirect_host <- randomItem arr
  respond request handle redirect_host
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

