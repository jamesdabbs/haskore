module Lib
    ( module X
    , module Lib
    ) where

import Protolude   as X hiding (gets)
import Data.String as X (String)

import qualified Data.Text as T

default (Int)

puts :: String -> IO ()
puts msg = putStrLn $ T.pack msg

gets :: IO String
gets = do
    text <- getLine
    return $ T.unpack text

read :: Read a => String -> Maybe a
read = readMaybe

toInt :: String -> Maybe Int
toInt = read