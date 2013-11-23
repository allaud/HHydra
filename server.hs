module Server where

import Data.Char
import System.IO
import Network
import Data.Time.LocalTime

data RequestType = GET | POST deriving (Show)
data Request = Request { rtype :: RequestType, path :: String, options :: [(String,String)] }
data Response = Response { version :: String, statuscode :: Int, location :: String}

instance Show Request where
  show r = "Request { " ++ show((rtype r)) ++ " " ++ (path r)  ++ (foldl (\acc (k,v) -> acc ++ "\n  " ++ k ++ ": " ++ v) "" (options r)) ++ "\n}"

instance Show Response where
  show r = version(r) ++ " " ++ show(statuscode(r)) ++ " " ++ (case statuscode(r) of
    100 -> "Continue"
    200 -> "OK"
    302 -> "Found"
    404 -> "Not Found") ++ "\r\n" ++ (
    "Server: HHydra beta\r\n" ++
    "Content-Length: 0\r\n" ++
    "Location: " ++ location(r) ++ "\r\n" ++
    "\r\n\r\n"
    )

fromString :: String -> RequestType
fromString t = case t of
  "GET" -> GET
  "POST" -> POST

--- This should really validate input or something. Separate validator? Or as-we-go?
parseRequestHelper :: ([String], [(String,String)]) -> [(String,String)]
parseRequestHelper ([], accum) = accum
parseRequestHelper ((l:rest), accum)
  | (length (words l)) < 2 = accum
  | otherwise = parseRequestHelper(rest, accum ++ [(reverse . tail . reverse . head . words $ l, unwords . tail . words $ l)] )

parseRequest :: [String] -> Request
parseRequest lns = case (words (head lns)) of
  [t,p,_] -> Request {rtype=(fromString t), path=p, options=parseRequestHelper((tail lns),[])}
