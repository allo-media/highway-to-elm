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
            , div [ class "tests" ]
                [ div [ class "inner" ]
                    [ div [ class "test-summary" ]
                        [ div [] [ text "Passed: 4" ]
                        , div [] [ text "Failed: 4" ]
                        ]
                    , div [ class "test passed" ]
                        [ h2 [] [ text "All Tests Data.Media changeSpeed should prevent exceeding min speed" ]
                        , div []
                            [ div []
                                [ div [ class "result-title" ] [ text "Expected" ]
                                , pre [] [ text "zefzefzefezfzzf" ]
                                ]
                            , div []
                                [ div [ class "result-title" ] [ text "Result" ]
                                , pre [] [ text "zefzefzefezfzzf" ]
                                ]
                            ]
                        ]
                    , div [ class "test failed" ]
                        [ h2 [] [ text "All Tests Data.Media changeSpeed should prevent exceeding min speed" ]
                        , div []
                            [ div []
                                [ div [ class "result-title" ] [ text "Expected" ]
                                , pre [] [ text "zefzefzefezfzzf" ]
                                ]
                            , div []
                                [ div [ class "result-title" ] [ text "Result" ]
                                , pre [] [ text "zefzefzefezfzzf" ]
                                ]
                            ]
                        ]
                    ]
                , div [ class "panel-title" ] [ text "tests" ]
                ]
            ]
