module Main exposing (Model, Msg(..), getVideos, init, main, subscriptions, toYoutubeUrl, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, string, succeed)
import Json.Decode.Pipeline exposing (required, requiredAt)
import List exposing (..)
import Url.Builder as Url



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Video =
    { id : String
    , title : String
    , description : String
    , thumb : String
    }


type alias Model =
    { topic : String
    , videos : List Video
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "ambient" []
    , getVideos "ambient"
    )



-- UPDATE


type Msg
    = Search String
    | NewVideos (Result Http.Error (List Video))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Search query ->
            ( { model | topic = query }
            , getVideos query
            )

        NewVideos result ->
            case result of
                Ok videos ->
                    ( { model | videos = videos }
                    , Cmd.none
                    )

                Err _ ->
                    ( model
                    , Cmd.none
                    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text model.topic ]
        , input [ onInput Search, placeholder "Search" ] []
        , br [] []
        , div [] (List.map viewVideo model.videos)
        ]


viewVideo : Video -> Html Msg
viewVideo video =
    div [ class "video-container" ]
        [ div [ class "video" ]
            [ a
                [ href ("https://www.youtube.com/watch?v=" ++ video.id)
                ]
                [ div [ class "front" ]
                    [ p [ class "title" ] [ text video.title ]
                    , img [ src video.thumb ] []
                    ]
                , div [ class "back" ]
                    [ p [] [ text video.description ]
                    ]
                ]
            ]
        ]



-- HTTP


getVideos : String -> Cmd Msg
getVideos topic =
    Http.send NewVideos (Http.get (toYoutubeUrl topic) decodeVideoList)


toYoutubeUrl : String -> String
toYoutubeUrl topic =
    Url.crossOrigin "https://www.googleapis.com"
        [ "youtube", "v3", "search" ]
        [ Url.string "part" "snippet"
        , Url.string "maxResults" "20"
        , Url.string "type" "video"
        , Url.string "key" "AIzaSyD4YJITOWdfQdFbcxHc6TgeCKmVS9yRuQ8"
        , Url.string "q" topic
        ]


decodeVideoList : Decoder (List Video)
decodeVideoList =
    Decode.field "items" (Decode.list decodeVideo)


decodeVideo : Decoder Video
decodeVideo =
    succeed Video
        |> requiredAt [ "id", "videoId" ] string
        |> requiredAt [ "snippet", "title" ] string
        |> requiredAt [ "snippet", "description" ] string
        |> requiredAt [ "snippet", "thumbnails", "medium", "url" ] string
