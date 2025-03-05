# NimQML-seaqt

`NimQML-seaqt` is a fork of [NimQML](https://github.com/filcuc/nimqml)
that uses [`seaqt`](https://github.com/seaqt/nim-seaqt) instead of
[`DOtherSide`](https://github.com/filcuc/dotherside/) to provide Qt bindings.

Switching to `NimQML-seaqt` should require no application changes beyond changing
the dependency - the changes are all in the `nimqml` private code.

Oof, really need a better name, it's a mess to type.

## Requirements

* [Nim](http://nim-lang.org/) 2.0.0 or higher
* Qt with pkg-config support installed

## Nimble instructions

```
requires "https://github.com/seaqt/nimqml-seaqt"
```

```
nimble install https://github.com/seaqt/nimqml-seaqt
```

## Examples

The examples can be built by executing the following command
```
nimble buildExamples
```

## Documentation

The project documentation can be read [here](http://filcuc.github.io/nimqml/)

## Differences compared to `nimqml`

* Simplified build system - no separate `DOtherSide` library, build,
  `cmake` etc. Qt is located using `pkg-config` and the wrappers are built as
  part of the application using `{.compile.}` pragmas
* Excellent metaobject integration - metadata for introspection is generated at
  compile time using the same binary format as `moc`, leading to a "native-like"
  metaobject experience, with excellent tooling integration and performance.
* Access to all of Qt - `seaqt` bindings are generated from the Qt source
  code giving access a wide range of libraries and utilities.

See [this upsteam issue](https://github.com/filcuc/nimqml/issues/54) for more
information - any code developed for this fork is put in the public domain in the
hope that it will be useful and potentially integrated by the upstream project.
