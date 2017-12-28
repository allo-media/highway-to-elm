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
    { id : Int
    , title : String
    , description : String
    , body : String
    }


type alias Model =
    { exercises : List Exercise
    }


server : String
server =
    -- XXX: do not hardcode the server endpoint here
    "http://localhost:3000"


decodeExercise : Decoder Exercise
decodeExercise =
    Decode.map4 Exercise
        (Decode.field "id" Decode.int)
        (Decode.field "title" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "body" Decode.string)


getExerciseList : Http.Request (List Exercise)
getExerciseList =
    Http.get (server ++ "/exercises") (Decode.list decodeExercise)


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
                [ model.exercises
                    |> List.map
                        (\ex ->
                            li []
                                [ a [ href <| "#/exercise/" ++ toString ex.id ]
                                    [ text ex.title ]
                                , br [] []
                                , text ex.description
                                ]
                        )
                    |> ul []
                ]
            , div [ id "exercice" ]
                [ Html.form
                    [ action (server ++ "/compile")
                    , method "post"
                    , target "result"
                    ]
                    [ textarea [ id "elm", name "elm" ]
                        [ text "module Main exposing (..)" ]
                    , button [ type_ "submit" ]
                        [ i [ class "icon-arrow-right" ] [] ]
                    ]
                , iframe [ id "result", name "result" ] []
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
