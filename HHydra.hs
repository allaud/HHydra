module Main where

import Control.Monad

import Data.List

import Network

import System.IO
import System.Random

import Text.ParserCombinators.Parsec
import Text.Regex.Posix

import Config
import Server
import Tpl

ruleEval :: String -> Bool
ruleEval r = 
    eval (r =~ "#\\{(.+)\\} +(.+) +(.+)" :: [[String]])
  
  where 
    eval ([[_, str, re, "=~"]]) = str =~ re :: Bool
    eval ([[_, str, re, "=="]]) = str == re :: Bool
    eval  other                 = error $ "misshapen config rule: " ++ show other

rulesEval :: [String] -> Bool
rulesEval = any ruleEval

randomItem :: [String] -> IO String
randomItem xs = (xs !!) `fmap` randomRIO (0, length xs - 1)

respond :: Request -> Handle -> String -> IO ()
respond request handle redirect_host = do
  print request
  
  let response = Response 
        { version    = "HTTP/1.1"
        , statuscode = 302
        , location   = redirect_host
        }
  
  hPutStr handle $ show response

handleAccept :: Handle -> String -> [(String, [String], [String])] -> IO ()
handleAccept handle _hostname rules = do

  rawPacket <- hGetContents handle

  let request = parseRequest . lines $ rawPacket

  let params      = options request ++ [("Path", path request)]
  let clean_rules = for rules snd3
  let tpl         = template params
  let t_rules     = for clean_rules $ map tpl

  let (Just ((_, _, arr), _)) = find snd $ zip rules $ map rulesEval t_rules

  redirect_host <- randomItem arr
  
  respond request handle redirect_host
  
  return ()

main :: IO ()
main = withSocketsDo $ do
  sock     <- listenOn $ PortNumber 9000
  contents <- readFile "config"
  
  case parse config "config" contents of
      Left  err   -> print err
      Right rules -> do
          putStrLn "Listening on port 9000"

          forever $ do
              (handle, hostname, _port) <- accept sock

              handleAccept handle hostname rules
              hClose       handle

for :: [a] -> (a -> b) -> [b]
for = flip map

snd3 :: (a, b, c) -> b
snd3 (_, r, _) = r