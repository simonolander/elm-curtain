module Util exposing (..)


cumulative : (a -> a -> a) -> List a -> List a
cumulative fun list =
    case list of
        h1 :: h2 :: tail ->
            h1 :: cumulative fun ( (fun h1 h2) :: tail )

        otherwise ->
            otherwise


zipWith : (a -> b -> c) -> List a -> List b -> List c
zipWith fun l1 l2 =
    case (l1, l2) of
        (h1 :: t1, h2 :: t2) ->
            fun h1 h2 :: zipWith fun t1 t2

        otherwise ->
            []


addList : List number -> List number -> List number
addList = zipWith (+)


pairs : List a -> List (a, a)
pairs list =
    case list of
        h1 :: h2 :: tail
            -> (h1, h2) :: pairs (h2 :: tail)

        otherwise ->
            []
