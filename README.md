# Typed Format

This library helps you turn data into nicely formatted strings
in a type-safe manner.

The API deliberately mirrors [url-parser](https://github.com/evancz/url-parser)
which is based on the same idea (see references).

## Examples

See the [examples](https://github.com/enetsee/typed-format/tree/master/examples) for some simple examples.

## Installation
```
elm package install enetsee/typed-format
```

## References

The library is based on the final representation of the `Printer` type from
Oleg Kiselyov's [Formatted Printer Parsers](http://okmij.org/ftp/tagless-final/course/PrintScanF.hs)

The [url-parser](https://github.com/evancz/url-parser) library is based on the
corresponding `Scanner` type.
