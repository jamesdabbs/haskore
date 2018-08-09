module Main where

import Lib

main :: IO ()
main = do
  -- ask for a number
  -- get the number
  -- for i from 1 .. number
    -- if i / 3
      -- print Fizz
    -- else
      -- print number

  puts "What's the number?"
  number <- gets

  let converted = toInt number
  case converted of
    Just realNumber -> do
      for_ [1 .. realNumber] $ \n -> do
        if n `mod` 3 == 0
          then puts "Fizz"
          else puts $ show n
    Nothing -> puts "No"
