module Tpl
    ( module M
    , template
    )
where

import Data.String.Utils as M

template :: [(String, String)] -> String -> String
template = flip $ foldl (flip $ uncurry replace)
