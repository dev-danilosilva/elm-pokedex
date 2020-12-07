module PokeApiClient exposing (..)


import Http as Http


type alias PokeUrl = String

type alias ListLimit = Int

type ApiResponse
    = ApiResponse (Result Http.Error String)

type alias PokeList = List PokeListItem

type PokeListItem = PokeListItem
    { name : String
    , url  : String
    }

type alias QueryParam =
    { property : String
    , value    : String
    }


baseUrl : PokeUrl
baseUrl = "https://pokeapi.co/api/v2/"


listLimit : ListLimit
listLimit = 200


buildUrl : List String -> List QueryParam -> String
buildUrl params qParams = baseUrl ++ (List.foldl (\param url-> url ++ param ++ "/") "" params) ++ buildQueryParams qParams


buildQueryParams : List QueryParam -> String
buildQueryParams params =
    let
        buildedParams = "?" ++ (List.foldl (\param builded -> builded ++ param.property ++ "=" ++ param.value ++ "&") "" params)
        compiledParams = String.dropRight 1 buildedParams
    in
        compiledParams


requestPokemonList : (Result Http.Error String -> msg) -> Cmd msg
requestPokemonList msg = Http.get
                            { url = buildUrl ["pokemon"] [QueryParam "limit" (String.fromInt listLimit)]
                            , expect = Http.expectString msg
                            }

