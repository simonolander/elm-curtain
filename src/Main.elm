module Main exposing (..)

import Html
import Html.Styled exposing (toUnstyled)
import Model exposing (..)
import Noise
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
        seed =
            Random.initialSeed 0

        (wiggleTable, wiggleSeed) =
            Noise.permutationTable seed

        (redTable, redSeed) =
            Noise.permutationTable wiggleSeed

        (greenTable, greenSeed) =
            Noise.permutationTable redSeed

        (blueTable, blueSeed) =
            Noise.permutationTable greenSeed

        model =
            { windowSize = Size 0 0
            , time = 0.0
            , wiggleTable = wiggleTable
            , redTable = redTable
            , greenTable = greenTable
            , blueTable = blueTable
            }

        cmd =
            Cmd.batch
                [ perform Resize Window.size
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
