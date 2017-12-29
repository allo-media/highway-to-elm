module Test exposing (..)

import Expect
import Test exposing (..)
import Main exposing (shout)


suite : Test
suite =
    describe "shout"
        [ test "should uppercase a word" <|
            \_ -> Expect.equal (shout "hello") "HELLO"
        ]
