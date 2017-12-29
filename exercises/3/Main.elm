module Main exposing (main)

import Html exposing (..)


things =
    [ "foo", "bar", "baz" ]


listItem smiley thing =
    li [] [ text <| thing ++ " " ++ smiley ]


main =
    ul [] (List.map listItem things)
