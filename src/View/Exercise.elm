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
            [ div [ class "panel-title" ] [ text exercise.description ]
            , div [ class "inner" ]
                [ h1 [] [ text exercise.title ]
                , Markdown.toHtml [] exercise.body
                ]
            ]
        , div [ class "code" ]
            [ div [ class "code-panel" ]
                [ Html.form
                    [ action (session.server ++ "/compile")
                    , method "post"
                    , target "result"
                    ]
                    [ div [ class "panel-title" ] [ text "Code" ]
                    , textarea [ id "elm", name "elm", value exercise.main ]
                        [ text exercise.main ]
                    , button [ type_ "submit" ]
                        [ i [ class "icon-arrow-right" ] [] ]
                    ]
                ]
            , div [ class "tests-panel" ]
                [ div [ class "panel-title" ] [ text "Tests" ]
                , pre [] [ text "-- tests here" ]
                ]
            ]
        , div [ class "iframe-wrapper" ]
            [ iframe [ id "result", name "result", src "about:blank" ] []
            , div [ class "panel-title" ] [ text "Result" ]
            ]
        ]


testsView : Html msg
testsView =
    div [ class "tests" ]
        [ div [ class "panel-title" ]
            [ text "Tests"
            , div [ class "test-summary" ]
                [ div [] [ i [ class "icon-check" ] [], text "4" ]
                , div [] [ i [ class "icon-close" ] [], text "4" ]
                ]
            ]
        , div [ class "inner" ]
            [ div [ class "test passed" ]
                [ h2 [] [ text "All Tests Data.Media changeSpeed should prevent exceeding min speed" ]
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
        ]
