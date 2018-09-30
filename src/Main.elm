module Main exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Decoder, field, int, list, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Task
import Time
import Url.Builder as Url


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Carshare =
    { id : Int
    , to : String
    , from : String
    , date : String
    , time : String
    , price : Int
    }


type alias Carshares =
    List Carshare


type alias Model =
    { carshares : Carshares
    , date : Time.Posix
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model [] (Time.millisToPosix 0), Cmd.none )



-- UPDATE


type Msg
    = ListCarshares (Result Http.Error Carshares)
    | Tick Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ListCarshares result ->
            case result of
                Ok carshares ->
                    ( { model | carshares = carshares }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [] (List.map text (List.map .to model.carshares))


carshareDecoder : Decoder Carshare
carshareDecoder =
    Decode.succeed Carshare
        |> required "id" int
        |> required "to" string
        |> required "from" string
        |> required "date" string
        |> required "time" string
        |> required "price" int


carsharesDecoder : Decoder Carshares
carsharesDecoder =
    list carshareDecoder


prevozUrl : Time.Posix -> String
prevozUrl date =
    let
        dateString =
            date
    in
    Url.crossOrigin "http://cors-anywhere.herokuapp.com/https://prevoz.org/api/search/shares/"
        []
        [ Url.string "fc" "SI"
        , Url.string "tc" "SI"
        , Url.string "d" "2018-09-31"
        , Url.string "exact" "false"
        , Url.string "intl" "false"
        ]


getCarshares : Model -> Cmd Msg
getCarshares model =
    Http.send ListCarshares (Http.get (prevozUrl model.date) (field "carshare_list" carsharesDecoder))
