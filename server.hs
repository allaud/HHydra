module Server where

import Data.Char
import System.IO
import Network
import Data.Time.LocalTime

data RequestType = GET | POST deriving (Show)
data Request = Request { rtype :: RequestType, path :: String, options :: [(String,String)] }
data Response = Response { version :: String, statuscode :: Int }

instance Show Request where
  show r = "Request { " ++ show((rtype r)) ++ " " ++ (path r)  ++ (foldl (\acc (k,v) -> acc ++ "\n  " ++ k ++ ": " ++ v) "" (options r)) ++ "\n}"

instance Show Response where
  show r = version(r) ++ " " ++ show(statuscode(r)) ++ " " ++ (case statuscode(r) of
    100 -> "Continue"
    200 -> "OK"
    404 -> "Not Found") ++ "\r\n\r\n"

fromString :: String -> RequestType
fromString t = case t of
  "GET" -> GET
  "POST" -> POST

respond :: Request -> Handle -> IO ()
respond request handle = do
  putStrLn $ show request
  let response = Response {version = "HTTP/1.1", statuscode = 200}
  --hPutStr handle $ show(response)
  time <- getZonedTime
  hPutStr handle $ "Haskell says HELLO.\nThe time is currently " ++ show(time) ++ "\n\n\nHere is some info from your session:\n" ++ show(request)

--- This should really validate input or something. Separate validator? Or as-we-go?
parseRequestHelper :: ([String], [(String,String)]) -> [(String,String)]
parseRequestHelper ([], accum) = accum
parseRequestHelper ((l:rest), accum)
  | (length (words l)) < 2 = accum
  | otherwise = parseRequestHelper(rest, accum ++ [(reverse . tail . reverse . head . words $ l, unwords . tail . words $ l)] )

parseRequest :: [String] -> Request
parseRequest lns = case (words (head lns)) of
  [t,p,_] -> Request {rtype=(fromString t), path=p, options=parseRequestHelper((tail lns),[])}

{-handleAccept :: Handle -> String -> IO ()
handleAccept handle hostname = do
  putStrLn $ "Handling request from " ++ hostname
  request <- fmap (parseRequest . lines) (hGetContents handle)
  print $ (options request) ++ [("Path", path request)]
  respond request handle
  return ()-}
