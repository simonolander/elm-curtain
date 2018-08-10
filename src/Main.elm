module Main exposing (..)

import Html
import Html.Styled exposing (toUnstyled)
import Model exposing (..)
import Random
import Task exposing (perform)
import View exposing (view)
import Window exposing (Size)
import AnimationFrame
import Update exposing (update)


---- INIT ----


init : ( Model, Cmd Msg )
init =
    let
        windowSize =
            Size 0 0

        model =
            { windowSize = windowSize
            , time = 0.0
            , matrix = []
            }

        cmd =
            Cmd.batch
                [ perform Resize Window.size
                , Random.generate ReceiveMatrix (generateMatrix 200 100 (Random.float -1 1))
                ]
    in
        ( model
        , cmd
        )


---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view >> toUnstyled
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Window.resizes Resize
        , AnimationFrame.diffs DeltaTime
        ]


generateMatrix : Int -> Int -> Random.Generator a -> Random.Generator (Matrix a)
generateMatrix width height generator =
    Random.list
        height
        (Random.list width generator)
