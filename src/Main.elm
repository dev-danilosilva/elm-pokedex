module Main exposing (..)

import Html exposing (Html, div, h1, p, text, input, a)
import Html.Attributes exposing (class, placeholder, type_)
import Html.Events exposing (onInput, onClick)
import Browser
import Utils exposing (nothingIfEmpty, newState)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }

type alias PokeResult = 
    { name : String
    , element : String
    , stats   : String
    }

type SearchState
    = Loading
    | Loaded (Result String PokeResult)

type alias Model =
    { q : Maybe String
    , searchState : SearchState
    }

type Msg
    = SavePokeQuery String
    | Search


init : a -> (Model, Cmd Msg)
init _ = ({q = Nothing, searchState = Loaded (Err "No results")}, Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of

    SavePokeQuery q ->
        let
            maybeQ =
                q
                |> String.toLower
                |> nothingIfEmpty
        in
            newState { model | q = maybeQ } Cmd.none
    
    Search  -> newState { model | searchState = Loading } Cmd.none


view : Model -> Html Msg
view model =
    div [class "container"]
        [ viewPageHeader
        , viewPokeResults model.q
        ]


viewPageHeader : Html Msg
viewPageHeader =
    div [class "pokedex"]
        [ h1 [ class "title mt-5" ]
            [ text "Welcome to Pokedex" ]
        , p [ class "subtitle" ]
            [ text "Awesome pokedex built with Elm"]
        , div [ class "field is-grouped" ]
            [ p [ class "control is-expanded" ]
                [ input [ class "input is-primary", placeholder "Find a repository", type_ "text", onInput SavePokeQuery ]
                    []
                ]
            , p [ class "control" ]
                [ a [ class "button is-primary", onClick Search]
                    [ text "Search"]
                ]
            ]
        ]


viewPokeResults : Maybe String -> Html Msg
viewPokeResults str = case str of
    Just q  -> text q

    Nothing -> text "No Result"

