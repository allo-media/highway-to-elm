module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Ports


-- import Html.Events exposing (..)


type Msg
    = NoOp
    | Plop


type alias Exercise =
    { title : String
    , description : String
    , body : String
    }


type alias Model =
    { exercises : List Exercise
    }


init : ( Model, Cmd Msg )
init =
    { exercises = [] } ! [ Ports.transformTextarea () ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    model ! []


view : Model -> Html Msg
view model =
    div []
        [ div [ id "topbar" ]
            [ img [ alt "Logo", src "./img/logo.svg" ] [] ]
        , div [ class "content" ]
            [ div []
                [ p [] [ text "This is a description" ] ]
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
