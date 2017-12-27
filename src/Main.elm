module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Ports
import Http
import Json.Decode as Decode exposing (Decoder)


-- import Html.Events exposing (..)


type Msg
    = ListReceived (Result Http.Error (List Exercise))


type alias Exercise =
    { title : String
    , description : String
    , body : String
    }


type alias Model =
    { exercises : List Exercise
    }


decodeExercise : Decoder Exercise
decodeExercise =
    Decode.map3 Exercise
        (Decode.field "title" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "body" Decode.string)


getExerciseList : Http.Request (List Exercise)
getExerciseList =
    Http.get "http://localhost:3000/exercises" (Decode.list decodeExercise)


init : ( Model, Cmd Msg )
init =
    { exercises = [] }
        ! [ Ports.transformTextarea ()
          , Http.send ListReceived getExerciseList
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


view : Model -> Html Msg
view model =
    div []
        [ div [ id "topbar" ]
            [ img [ alt "Logo", src "./img/logo.svg" ] [] ]
        , div [ class "content" ]
            [ div []
                [ p [] [ text (toString model) ] ]
            , div [ id "exercice" ]
                -- XXX: do not hardcode the server endpoint here
                [ Html.form [ action "http://localhost:3000/compile", method "post", target "result" ]
                    [ textarea [ id "elm", name "elm" ]
                        [ text "module Main exposing (..)" ]
                    , button [ type_ "submit" ]
                        [ i [ class "icon-arrow-right" ]
                            []
                        ]
                    ]
                , iframe [ id "result", name "result" ]
                    []
                ]
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
