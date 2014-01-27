{-# LANGUAGE TypeSynonymInstances, FlexibleInstances #-}

module Server where

--import Data.Char
--import System.IO
--import Network
--import Data.Time.LocalTime

import Control.Arrow

import Text.Printf

data RequestType 
    = GET 
    | POST 

    deriving (Show)

data Request  = Request 
    { rtype   :: RequestType
    , path    :: String
    , options :: [(String,String)]
    }

    deriving Show

data Response = Response 
    { version    :: String
    , statuscode :: Int
    , location   :: String
    }

instance Show Response where
  show r = format 
      (       version    r) 
      (show $ statuscode r) 
      (       showCode   r) 
      (       location   r)

    where
      format = printf $ unlines
          [ "%s %s %s\r"
          , "Server: HHydra beta\r" 
          , "Content-Length: 0\r"   
          , "Location: %s\r"
          , "\r"
          , "\r"
          ]

      showCode response = case statuscode response of
          100   -> "Continue"
          200   -> "OK"
          302   -> "Found"
          404   -> "Not Found"
          other -> error $ "status code not supported: " ++ show other
    

fromString :: String -> RequestType
fromString type_ = case type_ of
    "GET"  -> GET
    "POST" -> POST
    other  -> error $ "request head not supported: " ++ other

--- This should really validate input or something. Separate validator? Or as-we-go?
parseRequest :: [String] -> Request
parseRequest lns = case words $ head lns of
    [t,p,_] -> Request 
        { rtype   = fromString t
        , path    = p
        , options = parseOptions $ tail lns 
        }

    other -> error $ "corrupted request: " ++ show other

  where
    parseOptions :: [String] -> [(String,String)]
    parseOptions = takeWhile (':' `elem`) >>> map (break (== ' '))
  
