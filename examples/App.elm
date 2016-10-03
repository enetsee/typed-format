module App exposing (main)

import Html exposing (Html)
import Html.Attributes
import TypedFormat exposing (..)


main : Html a
main =
    Html.div []
        [ Html.h4 [] [ Html.text "Combining formatters" ]
        , Html.div []
            [ Html.text <| sprintf hello "world" ]
        , Html.div []
            [ Html.text <| sprintf doubleHello "world" "Elm" ]
        , Html.div []
            [ Html.text <| sprintf myMessage 'A' 'Z' ]
        , Html.h4 [] [ Html.text "Explicitly signed Float, 2 decimal places" ]
        , Html.div []
            [ Html.text <| sprintf signedFloat 1.23456789 ]
        , Html.div []
            [ Html.text <| sprintf signedFloat 12.3456789 ]
        , Html.div []
            [ Html.text <| sprintf signedFloat 123.456789 ]
        , Html.div []
            [ Html.text <| sprintf signedFloat 1234.56789 ]
        , Html.div []
            [ Html.text <| sprintf signedFloat 12345.6789 ]
        , Html.div []
            [ Html.text <| sprintf signedFloat 123456.789 ]
        , Html.div []
            [ Html.text <| sprintf signedFloat 1234567.89 ]
        , Html.div []
            [ Html.text <| sprintf signedFloat 12345678.9 ]
        , Html.h4 [] [ Html.text "Float, 4 decimal places" ]
        , Html.div []
            [ Html.text <| sprintf float4dp 1.23456789 ]
        , Html.div []
            [ Html.text <| sprintf float4dp 12.3456789 ]
        , Html.div []
            [ Html.text <| sprintf float4dp 123.456789 ]
        , Html.div []
            [ Html.text <| sprintf float4dp 1234.56789 ]
        , Html.div []
            [ Html.text <| sprintf float4dp 12345.6789 ]
        , Html.div []
            [ Html.text <| sprintf float4dp 123456.789 ]
        , Html.div []
            [ Html.text <| sprintf float4dp 1234567.89 ]
        , Html.div []
            [ Html.text <| sprintf float4dp 12345678.9 ]
        , Html.h4 [] [ Html.text "Explicity signed money" ]
        , Html.div []
            [ Html.text <| sprintf money 1.23456789 ]
        , Html.div []
            [ Html.text <| sprintf money 12.3456789 ]
        , Html.div []
            [ Html.text <| sprintf money 123.456789 ]
        , Html.div []
            [ Html.text <| sprintf money 1234.56789 ]
        , Html.div []
            [ Html.text <| sprintf money 12345.6789 ]
        , Html.div []
            [ Html.text <| sprintf money 123456.789 ]
        , Html.div []
            [ Html.text <| sprintf money 1234567.89 ]
        , Html.div []
            [ Html.text <| sprintf money 12345678.9 ]
        , Html.h4 [] [ Html.text "Abbreviated  money" ]
        , Html.div []
            [ Html.text <| sprintf abbreviatedMoney 1.23456789 ]
        , Html.div []
            [ Html.text <| sprintf abbreviatedMoney 12.3456789 ]
        , Html.div []
            [ Html.text <| sprintf abbreviatedMoney 123.456789 ]
        , Html.div []
            [ Html.text <| sprintf abbreviatedMoney 1234.56789 ]
        , Html.div []
            [ Html.text <| sprintf abbreviatedMoney 12345.6789 ]
        , Html.div []
            [ Html.text <| sprintf abbreviatedMoney 123456.789 ]
        , Html.div []
            [ Html.text <| sprintf abbreviatedMoney 1234567.89 ]
        , Html.div []
            [ Html.text <| sprintf abbreviatedMoney 12345678.9 ]
        , Html.div []
            [ Html.text <| sprintf abbreviatedMoney 12345678912.3 ]
        ]


hello : Format a (String -> a)
hello =
    s "hello " <++> string <++> s "!"


doubleHello : Format a (String -> String -> a)
doubleHello =
    hello <++> hello


myMessage : Format a (Char -> Char -> a)
myMessage =
    s "Elm gets me from " <++> char <++> s " to " <++> char


signedFloat : Format a (Float -> a)
signedFloat =
    prettyFloat Nothing Nothing True ',' '.' 2


float4dp : Format a (Float -> a)
float4dp =
    simplePrettyFloat 4


money : Format a (Float -> a)
money =
    currency "$" False True ',' '.'


abbreviatedMoney : Format a (Float -> a)
abbreviatedMoney =
    simpleCurrency "£"
