module TypedFormat
    exposing
        ( Format
        , (<++>)
        , sprintf
        , s
        , bool
        , char
        , string
        , int
        , float
        , custom
        , prettyFloat
        , simplePrettyFloat
        , currency
        , simpleCurrency
        )

{-| This library helps you turn data into nicely formatted strings
in a type-safe manner.

The API deliberately mirrors [url-parser](https://github.com/evancz/url-parser)
which is based on the same idea (see references).

# Basic formatters (not a real word)
@docs Format, s, bool, char, string, int, float

# Custom formatters
@docs custom, prettyFloat, simplePrettyFloat, currency, simpleCurrency

# Combining Formatters
@docs (<++>)

# Apply Formatter
@docs sprintf

#References
The library is based on the final representation of the `Printer` type from
Oleg Kiselyov's [Formatted Printer Parsers](http://okmij.org/ftp/tagless-final/course/PrintScanF.hs)

The [url-parser](https://github.com/evancz/url-parser) library is based on the
corresponding `Scanner` type.
-}

import String
import Dict exposing (Dict)


{-| A `Format` is a way of constructing type-safe `printf` functions.

The type `b` corresponds to the type of the argument your formatter will expect
when applied with `sprintf`.
-}
type Format a b
    = Format ((String -> a) -> b)


{-| Apply your formatter creating a function which expects arguments matching
the formatter. For example, given the formatter:

  myFormatter : Format a (String -> Int -> a)
  myFormatter =
      s "Using " <++> string <++> s " makes me " <++> int <++> s "% more productive."

, we can apply `sprintf` to get the function:

  myFormat : String -> Int -> String
  myFormat =
      sprintf myFormatter

-}
sprintf : Format String b -> b
sprintf (Format f) =
    f identity


{-| Combine formatters. It can be used to combine very simple building blocks
like this:

  hello : Format a (String -> a)
  hello =
    s "hello " <++> string

So we can say hello to whoever we want. It can also be used to put together
arbitrarily complex parsers, so you *could* say something like this too:

  doubleHello : Format a (String -> String -> a)
  doubleHello =
      hello <++> hello

-}
(<++>) : Format b c -> Format a b -> Format a c
(<++>) (Format a) (Format b) =
    Format <|
        \k -> a (\sa -> b (\sb -> k (sa ++ sb)))
infixl 5 <++>


{-| A formater to add string literals
-}
s : String -> Format a a
s str =
    Format <| \k -> k str


{-| Allows you to create a formatter using a custom function to turn your
type into a string. `prettyFloat`, `simplePrettyFloat`, `currency` and
`simpleCurrency` are all examples.
-}
custom : (b -> String) -> Format a (b -> a)
custom typeToString =
    Format <| \k -> k << typeToString


{-| A formater for `Bool`s
-}
bool : Format a (Bool -> a)
bool =
    custom toString


{-| A formater for *any* data type using Elm's magic `toString`.
-}
any : Format a (b -> a)
any =
    custom toString


{-| A formater for `Char`s
-}
char : Format a (Char -> a)
char =
    custom String.fromChar


{-| A formater for `String`s
-}
string : Format a (String -> a)
string =
    custom identity


{-| A formater for `Int`s
-}
int : Format a (Int -> a)
int =
    custom toString


{-| A formater for `Float`s
-}
float : Format a (Float -> a)
float =
    custom toString


{-| Formatter to pretty-print a `Float`.
The arguments are as follows:
- prefix : an optional prefix string, appearing before any leading sign (+/-)
- suffix : an optional suffix string, appearing after the number
- showPos : indicate whether a '+' should be prefixed for positive numbers
- sep : character to use a seprator (e.g. ','' in '1,000.00')
- decimalPoint : character to be used for decimal points
- decimalPlace : the numer of decimal places to print
-}
prettyFloat :
    Maybe String
    -> Maybe String
    -> Bool
    -> Char
    -> Char
    -> Int
    -> Format a (Float -> a)
prettyFloat prefix suffix showPos sep decimalPoint decimalPlaces =
    custom <| prettyFloatHelper prefix suffix showPos sep decimalPoint decimalPlaces


{-| Formatter to pretty-print a `Float` using default settings.
-}
simplePrettyFloat : Int -> Format a (Float -> a)
simplePrettyFloat =
    prettyFloat Nothing Nothing False ',' '.'


{-| Formatter to pretty-print a `Float` representing a currency amount.
The arguments are:
- symbol :  currency symbol
- abbreviateUnits : indicate whether standard abbreviations for currency amounts should be used
- isAccouting : indicate whether a '+' should be prefixed for positive amounts
- sep : character to use a seprator (e.g. ','' in '1,000.00')
- decimalPoint : character to be used for decimal points
-}
currency : String -> Bool -> Bool -> Char -> Char -> Format a (Float -> a)
currency symbol abbreviateUnits isAccounting sep decimalPoint =
    let
        toCurrencyStr x =
            if abbreviateUnits then
                let
                    ( x', b ) =
                        numberWithBase x

                    suffix =
                        Dict.get b currencySuffix
                in
                    prettyFloatHelper (Just symbol) suffix isAccounting ',' '.' 2 x'
            else
                prettyFloatHelper (Just symbol) Nothing isAccounting ',' '.' 2 x
    in
        custom toCurrencyStr


{-| Formatter to pretty-print a `Float` representing a currency amount
using default settings.
-}
simpleCurrency : String -> Format a (Float -> a)
simpleCurrency symbol =
    currency symbol True False ',' '.'



-- Helpers


currencySuffix : Dict Int String
currencySuffix =
    Dict.fromList
        [ ( 3, "k" )
        , ( 6, "mn" )
        , ( 9, "bn" )
        , ( 12, "tn" )
        , ( 15, "qn" )
        ]


numberWithBase : Float -> ( Float, Int )
numberWithBase x =
    let
        n =
            logBase 10 x |> floor

        b =
            n - (n % 3)
    in
        ( x / (10.0 ^ toFloat b), b )


prettyFloatHelper :
    Maybe String
    -> Maybe String
    -> Bool
    -> Char
    -> Char
    -> Int
    -> Float
    -> String
prettyFloatHelper prefix suffix showPos sep decimalPoint decimalPlaces val =
    let
        absVal =
            abs val

        sign =
            if val < 0.0 then
                "-"
            else if showPos then
                "+"
            else
                ""
    in
        case String.split "." (toString absVal) of
            [ lhs, rhs ] ->
                let
                    lhss =
                        List.map (String.fromList) <| chunksOf 3 (String.toList lhs)

                    rhsTrunc =
                        String.padRight decimalPlaces '0' <|
                            String.left decimalPlaces rhs

                    sepStr =
                        String.fromChar sep

                    dpStr =
                        String.fromChar decimalPoint

                    pfxStr =
                        Maybe.withDefault "" prefix

                    sfxStr =
                        Maybe.withDefault "" suffix
                in
                    sign ++ pfxStr ++ String.join sepStr lhss ++ dpStr ++ rhsTrunc ++ sfxStr

            _ ->
                "#error"


chunksOf : Int -> List a -> List (List a)
chunksOf chunkSize xs =
    chunksOfHelper chunkSize [] [] 0 (List.reverse xs)


chunksOfHelper :
    Int
    -> List (List a)
    -> List a
    -> Int
    -> List a
    -> List (List a)
chunksOfHelper chunkSize accu currentChunk currentChunkSize xs =
    case xs of
        [] ->
            case currentChunk of
                [] ->
                    accu

                _ ->
                    currentChunk :: accu

        next :: rest ->
            if currentChunkSize == chunkSize then
                chunksOfHelper chunkSize (currentChunk :: accu) [ next ] 1 rest
            else
                chunksOfHelper chunkSize accu (next :: currentChunk) (currentChunkSize + 1) rest
