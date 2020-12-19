module Main exposing (..)

import Browser
import Http
import Html.Events exposing (onInput, onClick)
import Utils exposing (nothingIfEmpty, newState)
import Html.Attributes exposing (class, placeholder, src, type_)
import Html exposing (Html, a, div, h1, h2, i, img, input, li, p, span, text, ul)

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
    , searchStatus : SearchStatus
    , selectedPokemon : Maybe Pokemon
    }

type SearchStatus
    = Loading
    | Loaded
    | LoadError String

type Msg
    = SavePokeQuery String
    | Search
    | ApiPokeList (Result Http.Error PokemonList)
    | ApiPokeData (Result Http.Error Pokemon)


initialModel : Model
initialModel =
    { q               = Nothing
    , pokemonList     = []
    , searchStatus    = Loaded
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

    Search  -> case model.q of
        Nothing -> (model, Cmd.none)
        Just query ->
            let
                resultListPokemon = List.filter (\p -> String.startsWith query p.name) model.pokemonList
                firstPokemonResult = List.head resultListPokemon
            in case firstPokemonResult of
                Nothing -> newState { model | searchStatus = Loaded, selectedPokemon = Nothing} Cmd.none
                Just pokemonItem -> newState { model | searchStatus = Loading} (requestPokemonData pokemonItem ApiPokeData)



    ApiPokeList res -> case res of
        Ok pokemonList ->
            newState { model | pokemonList = pokemonList }  Cmd.none
        Err _ ->
            newState { model | pokemonList = [] } Cmd.none


    ApiPokeData res -> case res of
        Ok result ->
            newState { model | searchStatus = Loaded,  selectedPokemon = Just result} Cmd.none

        Err _ ->
            newState { model | searchStatus = LoadError "Load Error"} Cmd.none



view : Model -> Html Msg
view model =
    div [class "container"]
        [ viewPageHeader
        , viewSearchBar
        , viewPokeResults model
        ]


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
                    [ input [ class "input is-danger", placeholder "Find a Pokemon", type_ "text", onInput SavePokeQuery ]
                        []
                    , span [class "icon is-small is-left"]
                        [ img [src "https://camo.githubusercontent.com/929f7fe3851a486b7ce0be46b3ca85e1eeb93318fabc67a861878f93b161f48c/687474703a2f2f6968302e726564627562626c652e6e65742f696d6167652e35303431313437372e373430312f737469636b65722c333735783336302e75332e706e67"] [] ]
                    ]
                , p [ class "control" ]
                    [ a [ class "button is-danger", onClick Search]
                        [ text "Search"]
                    ]
                ]
            ]
        ]



viewPokeResults : Model -> Html Msg
viewPokeResults model = case model.searchStatus of
    Loaded -> case model.selectedPokemon of
        Nothing -> div [class "results columns"]
                    [ div [class "column is-12 has-text-centered"]
                        [text "No Data"]
                    ]

        Just result ->
            div [class "results columns"]
                [ div [class "column is-8 is-offset-2"]
                    [ div [class "columns"]
                        [ div [class "column"]
                            [img [src result.pokemonSprite] []
                            ]
                        , div [class "column"]
                            [ h2 [class "title"] [text <| String.toUpper <|"Name: " ++ result.pokemonName]
                            , div [] (List.map (\pokemonType -> span [class ("tag is-large m-3 " ++ selectTypeColor pokemonType)] [text<| String.toUpper <| pokemonType]) result.pokemonTypes)
                            ]
                        ]
                    ]
                ]

    Loading -> div [class "results columns"]
                    [ div [class "column is-12 has-text-centered"]
                        [text "Loading ..."]
                    ]

    LoadError string -> div [class "results columns"]
                    [ div [class "column is-12 has-text-centered"]
                        [text "Not Found"]
                    ]

selectTypeColor : String -> String
selectTypeColor pokemonType = case pokemonType of
    "dragon"    -> "is-success"
    "grass"     -> "is-success is-light"
    "poison"    -> "is-success"
    "fire"      -> "is-danger"
    "water"     -> "is-info"
    "electric"  -> "is-warning"
    "dark"      -> "is-dark"
    "ghost"     -> "is-dark"
    "flying"    -> "is-info is-light"
    _           -> "is-info"
