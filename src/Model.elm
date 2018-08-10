module Model exposing (..)

import Time exposing (Time)
import Window exposing (Size)


type alias Matrix a =
    List (List a)


type Msg =
    Resize Size
    | DeltaTime Time
    | ReceiveMatrix (Matrix Float)


type alias Model =
    { windowSize: Size
    , time: Time
    , matrix: Matrix Float
    }
