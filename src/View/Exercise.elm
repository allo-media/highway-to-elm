module View.Exercise exposing (view)

import Data.Exercise exposing (Exercise)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Markdown


extractElmCodeBlock : String -> Maybe String
extractElmCodeBlock markdown =
    -- You know what? I'm not even ashamed.
    case String.split "\n```elm\n" markdown of
        _ :: code :: _ ->
            case String.split "\n```\n" code of
                code :: _ ->
                    Just code

                _ ->
                    Nothing

        _ ->
            Nothing


view : Session -> Exercise -> Html msg
view session exercise =
    let
        code =
            Maybe.withDefault
                "-- I was unable to extract the code block for this exercise, sorry :("
                (extractElmCodeBlock exercise.body)
    in
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
                [ textarea [ id "elm", name "elm", value code ]
                    [ text code ]
                , button [ type_ "submit" ]
                    [ i [ class "icon-arrow-right" ] [] ]
                , div [ class "panel-title" ] [ text "Code" ]
                ]
            , div [ class "iframe-wrapper" ]
                [ iframe [ id "result", name "result" ] []
                , div [ class "panel-title" ] [ text "Result" ]
                ]
            ]
