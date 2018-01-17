module Test exposing (..)


type Result
    = Pass
    | Fail String


assertEqual : a -> a -> Result
assertEqual x y =
    if x == y then
        Pass
    else
        Fail <| toString x ++ " /= " ++ toString y
