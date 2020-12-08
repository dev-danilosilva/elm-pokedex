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

type alias PokemonType   = String
type alias PokemonName   = String
type alias PokemonSprite = String

type alias Pokemon =
    { pokemonName : PokemonName
    , pokemonType : List PokemonType
    , pokemonSprite: PokemonSprite
    }

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
    in
        String.dropRight 1 buildedParams

requestPokemonList : (Result Http.Error (PokemonList) -> msg) -> Cmd msg
requestPokemonList msg = Http.get
                            { url = buildUrl ["pokemon"] [QueryParam "limit" (String.fromInt listLimit)]
                            , expect = Http.expectJson msg pokemonListDecoder
                            }
requestPokemonData : PokemonListItem -> (Result Http.Error Pokemon -> msg) -> Cmd msg
requestPokemonData pokemon msg = Http.get
                        { url = pokemon.url
                        , expect = Http.expectJson msg pokemonDetailsDecoder
                        }


pokemonListDecoder : Json.Decoder PokemonList
pokemonListDecoder = Json.field "results" (Json.list pokemonListItemDecoder)

pokemonListItemDecoder : Json.Decoder PokemonListItem
pokemonListItemDecoder = Json.map2
                            PokemonListItem (Json.field "name" Json.string) (Json.field "url"  Json.string)


pokemonNameDecoder : Json.Decoder PokemonName
pokemonNameDecoder = Json.field "name" Json.string

pokemonTypeListDecoder : Json.Decoder (List PokemonType)
pokemonTypeListDecoder = Json.field "name" Json.string
                         |> Json.field "type"
                         |> Json.list
                         |> Json.field "types"

pokemonSpriteDecoder : Json.Decoder PokemonSprite
pokemonSpriteDecoder = Json.field "front_default" Json.string
                       |> Json.field "official-artwork"
                       |> Json.field "other"
                       |> Json.field "sprites"

pokemonDetailsDecoder = Json.map3
                            Pokemon pokemonNameDecoder pokemonTypeListDecoder pokemonSpriteDecoder

