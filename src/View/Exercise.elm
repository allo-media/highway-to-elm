module View.Exercise exposing (view)

import Data.Exercise exposing (Exercise)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Markdown


view : Session -> Exercise -> Html msg
view session exercise =
    div [ class "exercise" ]
        [ div [ class "summary" ]
            [ div [ class "inner" ]
                [ h1 [] [ text exercise.title ]
                , Markdown.toHtml [] exercise.body
                ]
            , div [ class "panel-title" ] [ text exercise.description ]
            ]
        , Html.form
            [ action (session.server ++ "/compile")
            , method "post"
            , target "result"
            ]
            [ textarea [ id "elm", name "elm", value exercise.main ]
                [ text exercise.main ]
            , button [ type_ "submit" ]
                [ i [ class "icon-arrow-right" ] [] ]
            , div [ class "panel-title" ] [ text "Code" ]
            ]
        , div [ class "iframe-wrapper" ]
            [ iframe [ id "result", name "result" ] []
            , div [ class "panel-title" ] [ text "Result" ]
            ]
        ]
