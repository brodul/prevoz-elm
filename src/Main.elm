module Main exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Decoder, field, int, list, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Url.Builder as Url


main =
    Browser.element { init = init, update = update, subscriptions = subscriptions, view = view }



-- MODEL


type alias Carshare =
    { id : Int
    , to : String
    , from : String
    , date : String
    , time : String
    }


type alias Carshares =
    List Carshare


type alias Model =
    Carshares


init : () -> ( Model, Cmd Msg )
init _ =
    ( [], getCarshares )



-- UPDATE


type Msg
    = ListCarshares (Result Http.Error Carshares)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ListCarshares result ->
            case result of
                Ok carshares ->
                    ( carshares, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [] (List.map text (List.map .to model)) 


carshareDecoder : Decoder Carshare
carshareDecoder =
    Decode.succeed Carshare
        |> required "id" int
        |> required "to" string
        |> required "from" string
        |> required "date" string
        |> required "time" string


carsharesDecoder : Decoder Carshares
carsharesDecoder =
    list carshareDecoder


prevozUrl : String
prevozUrl =
    Url.crossOrigin "http://cors-anywhere.herokuapp.com/https://prevoz.org/api/search/shares/"
        []
        [ Url.string "fc" "SI"
        , Url.string "tc" "SI"
        , Url.string "d" "2018-09-25"
        , Url.string "exact" "false"
        , Url.string "intl" "false"
        ]


getCarshares : Cmd Msg
getCarshares =
    Http.send ListCarshares (Http.get prevozUrl (field "carshare_list" carsharesDecoder))
