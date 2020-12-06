module Utils exposing (nothingIfEmpty, newState)

nothingIfEmpty : String -> Maybe String
nothingIfEmpty x =
    if String.isEmpty x then
        Nothing
    else
        Just x


newState : model -> Cmd msg -> (model, Cmd msg)
newState m cmd = (m, cmd)