import Control.Applicative ( (<$>) )
import System.Random
import System.IO

randomItem :: [Int] -> IO Int
randomItem xs = (xs!!)  <$> randomRIO (0, length xs - 1)

main :: IO ()
main = do
  result <- randomItem [1,2,3,4,5]
  print result

