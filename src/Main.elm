module Main exposing (..)

import Browser
import Http
import Html.Events exposing (onInput, onClick)
import Utils exposing (nothingIfEmpty, newState)
import Html.Attributes exposing (class, placeholder, type_)
import Html exposing (Html, div, h1, p, text, input, a, i, span, ul, li)

import PokeApiClient exposing (requestPokemonList, PokemonList)

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



type alias Model =
    { q : Maybe String
    , pokemonList : PokemonList
    }

type Msg
    = SavePokeQuery String
    | Search
    | ApiPokeList (Result Http.Error PokemonList)


init : flags -> (Model, Cmd Msg)
init _ = ({q = Nothing, pokemonList = []}, requestPokemonList ApiPokeList)



update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of

    SavePokeQuery q ->
        let
            maybeQ =
                q
                |> String.toLower
                |> String.trim
                |> String.replace " " "-"
                |> nothingIfEmpty
        in
            newState { model | q = maybeQ } Cmd.none

    Search  -> newState { model | pokemonList = [] } (requestPokemonList ApiPokeList)

    ApiPokeList res -> case res of
        Ok pokemonList ->
            newState { model | pokemonList = pokemonList }  Cmd.none
        Err error ->
            newState { model | pokemonList = [] } Cmd.none





view : Model -> Html Msg
view model =
    div [class "container"]
        [ viewPageHeader
        , viewSearchBar
        , text <| mirror model.q
        , viewPokeResults model
        ]

mirror mx = case mx of
    Just x -> x
    Nothing -> ""

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



viewPokeResults : Model -> Html Msg
viewPokeResults model = ul [] <| List.map (\pk -> li [] [text pk.name]) (List.filter (\pk -> String.startsWith (mirror model.q) pk.name) model.pokemonList )


