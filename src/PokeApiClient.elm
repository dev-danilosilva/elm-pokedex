module PokeApiClient exposing (..)


import Http as Http
import Json.Decode as Json


type alias PokeUrl = String


type alias QueryParam =
    { property : String
    , value    : String
    }

type alias PokemonListItem =
    { name : String
    , url  : String
    }

type alias PokemonList = List PokemonListItem

baseUrl : PokeUrl
baseUrl = "https://pokeapi.co/api/v2/"


listLimit : Int
listLimit = 1118


buildUrl : List String -> List QueryParam -> String
buildUrl params qParams = baseUrl ++ (List.foldl (\param url-> url ++ param ++ "/") "" params) ++ buildQueryParams qParams


buildQueryParams : List QueryParam -> String
buildQueryParams params =
    let
        buildedParams = "?" ++ (List.foldl (\param builded -> builded ++ param.property ++ "=" ++ param.value ++ "&") "" params)
        finalParams = String.dropRight 1 buildedParams
    in
        finalParams

requestPokemonList : (Result Http.Error (PokemonList) -> msg) -> Cmd msg
requestPokemonList msg = Http.get
                            { url = buildUrl ["pokemon"] [QueryParam "limit" (String.fromInt listLimit)]
                            , expect = Http.expectJson msg pokemonListDecoder
                            }

pokemonListDecoder : Json.Decoder PokemonList
pokemonListDecoder = Json.field "results" (Json.list pokemonListItemDecoder)

pokemonListItemDecoder : Json.Decoder PokemonListItem
pokemonListItemDecoder = Json.map2 PokemonListItem
                            (Json.field "name" Json.string)
                            (Json.field "url"  Json.string)
