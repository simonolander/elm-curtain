module Update exposing (update)

import Model exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Resize size ->
            ( { model
              | windowSize = size
              }
            , Cmd.none
            )

        DeltaTime diff ->
            ( { model
              | time = model.time + diff / 1000
              }
            , Cmd.none
            )

        ReceiveMatrix matrix ->
            ( { model
              | matrix = matrix
              }
            , Cmd.none
            )
