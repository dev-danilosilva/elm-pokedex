module Main exposing (..)

import Browser
import Http
import Html.Events exposing (onInput, onClick)
import Utils exposing (nothingIfEmpty, newState)
import Html.Attributes exposing (class, placeholder, src, type_)
import Html exposing (Html, a, div, h1, i, img, input, li, p, span, text, ul)

import PokeApiClient exposing (PokemonList, PokemonListItem, requestPokemonList, requestPokemonData, Pokemon)

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
    , searchResult : Maybe PokemonListItem
    , selectedPokemon : Maybe Pokemon
    }

type Msg
    = SavePokeQuery String
    | Search
    | ApiPokeList (Result Http.Error PokemonList)
    | ApiPokeData (Result Http.Error Pokemon)


initialModel : Model
initialModel =
    { q               = Nothing
    , pokemonList     = []
    , searchResult    = Nothing
    , selectedPokemon = Nothing
    }

init : flags -> (Model, Cmd Msg)
init _ = (initialModel, requestPokemonList ApiPokeList)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of

    SavePokeQuery q ->
        let
            updatedQ =
                q
                |> String.toLower
                |> String.trim
                |> String.replace " " "-"
                |> nothingIfEmpty
        in
            newState { model | q = updatedQ } Cmd.none

    Search  ->
        let
            resultListPokemon = List.filter (\p -> String.startsWith (extractString model.q) p.name) model.pokemonList
            firstPokemonResult = List.head resultListPokemon
        in case firstPokemonResult of
            Nothing -> newState { model | searchResult = firstPokemonResult, selectedPokemon = Nothing} Cmd.none
            Just pokemon -> newState { model | searchResult = firstPokemonResult} (requestPokemonData pokemon ApiPokeData)


    ApiPokeList res -> case res of
        Ok pokemonList ->
            newState { model | pokemonList = pokemonList }  Cmd.none
        Err _ ->
            newState { model | pokemonList = [] } Cmd.none

    ApiPokeData res -> case res of
        Ok result ->
            newState { model | selectedPokemon = Just (Debug.log "search" result)} Cmd.none

        Err _ ->
            newState { model | searchResult = Nothing} Cmd.none



view : Model -> Html Msg
view model =
    div [class "container"]
        [ viewPageHeader
        , viewSearchBar
        , viewPokeResults model.selectedPokemon
        ]


extractString mx = case mx of
    Just x -> x
    Nothing -> ""


viewPageHeader : Html Msg
viewPageHeader =
    div [ class "pokedex-header columns"]
        [ div [class "pokedex-header column is-half is-offset-3 has-text-centered"]
            [ h1 [ class "title mt-5" ]
                [ text "Welcome to Elm Pokedex" ]
            , p [ class "subtitle" ]
                [ text "Awesome Pokedex built with Elm"]
            ]
        ]

viewSearchBar : Html Msg
viewSearchBar =
    div [class "columns"]
        [ div [class "column is-half is-offset-3"]
            [ div [ class "field is-grouped my-5" ]
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
            ]
        ]



viewPokeResults : Maybe Pokemon -> Html Msg
viewPokeResults pokemon = case pokemon of
    Nothing -> text "Pokemon Not Found"

    Just result -> img [src result.pokemonSprite] []
