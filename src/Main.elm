module Main exposing (..)

import Html exposing (Html, div, h1, p, text, input, a, i)
import Html.Attributes exposing (class, placeholder, type_)
import Html.Events exposing (onInput, onClick)
import Browser
import Utils exposing (nothingIfEmpty, newState)
import Dict exposing (Dict)
import Html exposing (span)
import Html exposing (q)
import PokeApiClient exposing (requestPokemonList)
import Http as Http

type SearchState
    = Loading
    | Loaded (Result Http.Error String)

type alias Model =
    { q : Maybe String
    , searchState : SearchState
    }

type Msg
    = SavePokeQuery String
    | Search
    | ApiResponse (Result Http.Error String)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of

    SavePokeQuery q ->
        let
            updatedQ =
                q
                |> String.toLower
                |> nothingIfEmpty
        in
            newState { model | q = updatedQ } Cmd.none
    
    Search  -> newState { model | searchState = Loading } (requestPokemonList ApiResponse)

    ApiResponse res -> newState { model | searchState = Loaded res }  Cmd.none



init : flags -> (Model, Cmd Msg)
init _ = ({q = Nothing, searchState = Loaded (Ok "No Results")}, Cmd.none)

view : Model -> Html Msg
view model =
    div [class "container"]
        [ viewPageHeader
        , viewSearchBar
        , viewPokeResults model.q
        ]


viewPageHeader : Html Msg
viewPageHeader =
    div [class "pokedex-header"]
        [ h1 [ class "title mt-5" ]
            [ text "Welcome to Pokedex" ]
        , p [ class "subtitle" ]
            [ text "Awesome pokedex built with Elm"]
        ]

viewSearchBar : Html Msg
viewSearchBar =
    div [ class "field is-grouped my-5" ]
        [ p [ class "control is-expanded has-icons-left" ]
            [ input [ class "input is-primary", placeholder "Find a Pokemon", type_ "text", onInput SavePokeQuery ]
                []
            , span [class "icon is-small is-left"]
                [ i [class "fas fa-bolt"] [] ]
            ]
        , p [ class "control" ]
            [ a [ class "button is-primary", onClick Search]
                [ text "Search"]
            ]
        ]

viewPokeResults : Maybe String -> Html Msg
viewPokeResults q = case q of
    Nothing -> text "No Results"

    Just x  -> text x


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
