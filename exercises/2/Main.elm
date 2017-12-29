module Main exposing (main)

import Html exposing (..)


things : List String
things =
    [ "foo", "bar", "baz" ]


listItem : String -> Html msg
listItem thing =
    -- implement me!


main : Html msg
main =
    ul [] (List.map listItem things)
