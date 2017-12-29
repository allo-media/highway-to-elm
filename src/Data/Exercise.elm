module Data.Exercise exposing (Exercise, decodeExercise)

import Json.Decode as Decode exposing (Decoder)


type alias Exercise =
    { id : Int
    , title : String
    , description : String
    , body : String
    , main : String
    }


decodeExercise : Decoder Exercise
decodeExercise =
    Decode.map5 Exercise
        (Decode.field "id" Decode.int)
        (Decode.field "title" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "body" Decode.string)
        (Decode.field "main" Decode.string)
