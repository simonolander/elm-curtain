module View exposing (view)

import Css exposing (..)
import Html.Attributes
import Html.Styled exposing (..)
import Math.Matrix4 exposing (Mat4)
import Math.Vector3 exposing (Vec3, vec3)
import Model exposing (..)
import Util exposing (..)
import WebGL exposing (Mesh, Shader)


view : Model -> Html Msg
view model =
    styled div
        [ (width << px << toFloat) model.windowSize.width
        , (height << px << toFloat) model.windowSize.height
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
            (curtain model.matrix)
            { perspective = perspective 1.5 }
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


curtain : Matrix Float -> Mesh Vertex
curtain matrix =
    let
        numberOfRows =
            List.length matrix

        rowHeight =
            2 / toFloat (numberOfRows - 1)

        wiggleHeight =
            rowHeight / 3

        indexToY index =
            -1 + toFloat index * rowHeight

        rowToLine rowIndex row =
            let
                numberOfColumns =
                    List.length row

                columnWidth =
                    2 / toFloat (numberOfColumns - 1)

                indexToX index =
                    -1 + toFloat index * columnWidth

                baseY =
                    indexToY rowIndex

                pairToVertex index (f1, f2) =
                    ( Vertex (vec3 (indexToX index) (baseY + f1 * wiggleHeight) 0) (vec3 0 0 0)
                    , Vertex (vec3 (indexToX (index + 1)) (baseY + f2 * wiggleHeight) 0) (vec3 0 0 0)
                    )
            in
                row
                |> pairs
                |> List.indexedMap pairToVertex
    in
        cumulative (zipWith (+)) matrix
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
