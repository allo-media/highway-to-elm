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
    div [ class "wrapper" ]
        [ div [ class "topbar" ]
            [ img [ alt "Logo", src "./img/logo.svg" ] [] ]
        , div [ class "content" ]
            [ div [ class "list-exercise" ]
                [ model.exercises
                    |> List.map
                        (\ex ->
                            option []
                                [ text ex.title ]
                        )
                    |> select []
                ]
            , div [ class "exercise" ]
                [ div [ class "summary" ]
                    [ div [ class "inner" ]
                        [ h1 [] [ text "Solve Me" ]
                        , text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac ex ac massa pharetra placerat et non eros. Integer accumsan, tortor eu tincidunt elementum, felis nibh mollis erat, eu suscipit erat quam ut nunc. Suspendisse ac eros orci. Proin commodo vitae nisl eu lacinia. Sed sagittis nisl ut enim semper, ac posuere quam tincidunt. Mauris dignissim dolor in fringilla tristique. Integer congue justo et enim malesuada, in maximus nibh commodo. Ut facilisis blandit elementum. Duis finibus dictum magna, faucibus finibus arcu tincidunt ac. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Aliquam erat volutpat. Nam quis enim dignissim, auctor enim sit amet, fringilla diam. Nulla sagittis sed diam eu scelerisque. Praesent massa erat, tempor vel tempor vitae. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac ex ac massa pharetra placerat et non eros. Integer accumsan, tortor eu tincidunt elementum, felis nibh mollis erat, eu suscipit erat quam ut nunc. Suspendisse ac eros orci. Proin commodo vitae nisl eu lacinia. Sed sagittis nisl ut enim semper, ac posuere quam tincidunt. Mauris dignissim dolor in fringilla tristique. Integer congue justo et enim malesuada, in maximus nibh commodo. Ut facilisis blandit elementum. Duis finibus dictum magna, faucibus finibus arcu tincidunt ac. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Aliquam erat volutpat. Nam quis enim dignissim, auctor enim sit amet, fringilla diam. Nulla sagittis sed diam eu scelerisque. Praesent massa erat, tempor vel tempor vitae. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac ex ac massa pharetra placerat et non eros. Integer accumsan, tortor eu tincidunt elementum, felis nibh mollis erat, eu suscipit erat quam ut nunc. Suspendisse ac eros orci. Proin commodo vitae nisl eu lacinia. Sed sagittis nisl ut enim semper, ac posuere quam tincidunt. Mauris dignissim dolor in fringilla tristique. Integer congue justo et enim malesuada, in maximus nibh commodo. Ut facilisis blandit elementum. Duis finibus dictum magna, faucibus finibus arcu tincidunt ac. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Aliquam erat volutpat. Nam quis enim dignissim, auctor enim sit amet, fringilla diam. Nulla sagittis sed diam eu scelerisque. Praesent massa erat, tempor vel tempor vitae"
                        ]
                    , div [ class "panel-title" ] [ text "Summary" ]
                    ]
                , Html.form
                    [ action (server ++ "/compile")
                    , method "post"
                    , target "result"
                    ]
                    [ textarea [ id "elm", name "elm" ]
                        [ text "module Main exposing (..)" ]
                    , button [ type_ "submit" ]
                        [ i [ class "icon-arrow-right" ] [] ]
                    , div [ class "panel-title" ] [ text "Code" ]
                    ]
                , div [ class "iframe-wrapper" ]
                    [ iframe [ id "result", name "result" ] []
                    , div [ class "panel-title" ] [ text "Result" ]
                    ]
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
