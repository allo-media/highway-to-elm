module View.Select exposing (Config, State, view)

import Data.Exercise exposing (Exercise)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode exposing (Decoder)


type alias Config msg =
    { onSelect : Int -> msg
    }


type alias State =
    { exercises : List Exercise
    , current : Maybe Exercise
    }


decodeStringAsInt : Decoder Int
decodeStringAsInt =
    let
        resultDecoder x =
            case String.toInt x of
                Ok a ->
                    Decode.succeed a

                Err e ->
                    Decode.fail e
    in
        Decode.at [ "target", "value" ] Decode.string
            |> Decode.andThen resultDecoder


view : Config msg -> State -> Html msg
view config state =
    let
        exerciseOption ex =
            option
                [ value <| toString ex.id
                , selected <| (Maybe.withDefault 0 (Maybe.map .id state.current)) == ex.id
                ]
                [ text ex.title ]
    in
        div [ class "list-exercise" ]
            [ ({ title = "-------", description = "", body = "", id = 0 } :: state.exercises)
                |> List.map exerciseOption
                |> select
                    [ on "change" (Decode.map config.onSelect decodeStringAsInt) ]
            ]
