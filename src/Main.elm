module Main exposing (main)

import Data.Exercise exposing (Exercise, decodeExercise)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder)
import Ports
import View.Exercise as Exercise
import View.Select as Select


-- import Ports

import View.Exercise as Exercise
import View.Select as Select


-- import Html.Events exposing (..)


type Msg
    = ListReceived (Result Http.Error (List Exercise))
    | SelectExercise Int


type alias Model =
    { exercises : List Exercise
    , current : Maybe Exercise
    }


session : Session
session =
    { server =
        -- XXX: do not hardcode the server endpoint here
        "http://localhost:3000"
    }


getExerciseList : Session -> Http.Request (List Exercise)
getExerciseList session =
    Http.get (session.server ++ "/exercises") (Decode.list decodeExercise)


init : ( Model, Cmd Msg )
init =
    { exercises = []
    , current = Nothing
    }
        ! [ getExerciseList session |> Http.send ListReceived
          ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ListReceived (Ok exercises) ->
            { model | exercises = exercises } ! []

        ListReceived (Err error) ->
            let
                _ =
                    Debug.log "Error" error
            in
                model ! []

        SelectExercise id ->
            let
                match =
                    List.filter (\x -> x.id == id) model.exercises
                        |> List.head
            in
                case match of
                    Just exercise ->
                        { model | current = Just exercise }
                            ! [ Ports.clearEditor ()
                              , Ports.createEditor ()
                              ]

                    Nothing ->
                        { model | current = Nothing } ! []


view : Model -> Html Msg
view model =
    div [ class "wrapper" ]
        [ div [ class "topbar" ]
            [ img [ alt "Logo", src "./img/logo.svg" ] [] ]
        , div [ class "content" ]
            [ Select.view { onSelect = SelectExercise }
                { exercises = model.exercises
                , current = model.current
                }
            , case model.current of
                Nothing ->
                    p [] [ text "please pick and exercise." ]

                Just exercise ->
                    Exercise.view session exercise
            ]
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }
