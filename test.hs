import Control.Applicative ( (<$>) )
import System.Random
import System.IO

randomItem :: [Int] -> IO Int
randomItem xs = (xs!!)  <$> randomRIO (0, length xs - 1)

test :: IO Int
test = do
  result <- randomItem [1,2,3,4,5]
  return (result)



main :: IO ()
main = do
  item <- test
  print item
  return ()

