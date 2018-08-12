module View exposing (view)

import Css exposing (..)
import Html.Attributes
import Html.Styled exposing (..)
import Math.Matrix4 exposing (Mat4)
import Math.Vector3 exposing (Vec3, vec3)
import Model exposing (..)
import Noise
import Util exposing (..)
import WebGL exposing (Mesh, Shader)


view : Model -> Html Msg
view model =
    styled div
        [ (width << px << toFloat) model.windowSize.width
        , (height << px << toFloat) model.windowSize.height
        , backgroundColor (hex "251d1d")
        ]
        []
        [ webgl model ]


webgl : Model -> Html Msg
webgl model =
    WebGL.toHtml
        [ Html.Attributes.width model.windowSize.width
        , Html.Attributes.height model.windowSize.height
        , Html.Attributes.style [ ( "display", "block" ) ]
        ]
        [ WebGL.entity
            vertexShader
            fragmentShader
            (curtain model)
            { perspective = perspective (model.time / 10) }
        ]
    |> fromUnstyled







perspective : Float -> Mat4
perspective t =
    Math.Matrix4.mul
        (Math.Matrix4.makePerspective 45 1 0.01 100)
        (Math.Matrix4.makeLookAt (vec3 (4 * cos t) 0 (4 * sin t)) (vec3 0 0 0) (vec3 0 -1 0))



-- Mesh


type alias Vertex =
    { position : Vec3
    , color : Vec3
    }


mesh : Mesh Vertex
mesh =
    WebGL.triangles
        [ ( Vertex (vec3 0 0 0) (vec3 1 0 0)
          , Vertex (vec3 1 1 0) (vec3 0 1 0)
          , Vertex (vec3 1 -1 0) (vec3 0 0 1)
          )
        ]

lines : Mesh Vertex
lines =
    WebGL.lineStrip
        [ Vertex (vec3 0 0 0) (vec3 1 0 0)
        , Vertex (vec3 1 1 0) (vec3 0 1 0)
        , Vertex (vec3 1 -1 0) (vec3 0 0 1)
        ]


curtain : Model -> Mesh Vertex
curtain model =
    let
        minX =
            -1.5

        maxX =
            1.5

        minY =
            -1.5

        maxY =
            1.5

        numberOfRows =
            model.windowSize.height // 10

        numberOfColumns =
            model.windowSize.width // 10

        rowHeight =
            (maxY - minY) / toFloat (numberOfRows - 1)

        wiggleHeight =
            rowHeight / 3

        indexToY index =
            minY + toFloat index * rowHeight

        positionToColor x y =
            vec3
                (Noise.noise3d model.redTable (toFloat x) (toFloat y) (model.time / 3) / 2 + 0.5)
                (Noise.noise3d model.greenTable (toFloat x) (toFloat y) (model.time / 3) / 2 + 0.5)
                (Noise.noise3d model.blueTable (toFloat x) (toFloat y) (model.time / 3) / 2 + 0.5)

        rowToLine rowIndex row =
            let
                numberOfColumns =
                    List.length row

                columnWidth =
                    (maxX - minX) / toFloat (numberOfColumns - 1)

                indexToX index =
                    minX + toFloat index * columnWidth

                baseY =
                    indexToY rowIndex

                pairToVertex index (f1, f2) =
                    ( Vertex (vec3 (indexToX index) (baseY + f1 * wiggleHeight) 0) (vec3 0.7 0.42 0.42)
                    , Vertex (vec3 (indexToX (index + 1)) (baseY + f2 * wiggleHeight) 0) (vec3 0.7 0.42 0.42)
                    )
            in
                row
                |> pairs
                |> List.indexedMap pairToVertex
    in
        Util.matrix (\col row -> Noise.noise3d model.wiggleTable (toFloat col) (toFloat row) (model.time / 3)) numberOfColumns numberOfRows
        |> cumulative (zipWith (+))
        |> List.indexedMap rowToLine
        |> List.concat
        |> WebGL.lines





-- Shaders


type alias Uniforms =
    { perspective : Mat4 }


vertexShader : Shader Vertex Uniforms { vcolor : Vec3 }
vertexShader =
    [glsl|
        attribute vec3 position;
        attribute vec3 color;
        uniform mat4 perspective;
        varying vec3 vcolor;
        void main () {
            gl_Position = perspective * vec4(position, 1.0);
            vcolor = color;
        }
    |]


fragmentShader : Shader {} Uniforms { vcolor : Vec3 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec3 vcolor;
        void main () {
            gl_FragColor = vec4(vcolor, 1.0);
        }
    |]
