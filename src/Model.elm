module Model exposing (..)

import Noise exposing (PermutationTable)
import Time exposing (Time)
import Window exposing (Size)


type alias Matrix a =
    List (List a)


type Msg =
    Resize Size
    | DeltaTime Time
    | ReceiveWiggleTable PermutationTable


type alias Model =
    { windowSize: Size
    , time: Time
    , wiggleTable: PermutationTable
    , redTable: PermutationTable
    , greenTable: PermutationTable
    , blueTable: PermutationTable
    }
