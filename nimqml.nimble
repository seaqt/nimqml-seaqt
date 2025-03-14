# Package

version       = "0.9.2"
author        = "Filippo Cucchetto"
description   = "QML bindings for Nim"
license       = "LGPLv3"
srcDir        = "src"

# Deps

requires "nim >= 2.0.0"
requires "https://github.com/seaqt/nim-seaqt.git"

task buildExamples, "Build examples":
  exec "nim c examples/helloworld/main"
  exec "nim c examples/abstractitemmodel/main"
  exec "nim c examples/charts/main"
  exec "nim c examples/connections/main"
  exec "nim c examples/contactapp/main"
  exec "nim c examples/helloworld/main"
  exec "nim c examples/qmlregistertype/main"
  exec "nim c examples/resourcebundling/main"
  exec "nim c examples/simpledata/main"
  exec "nim c examples/slotsandproperties/main"

task test, "Run a few tests":
  exec "nim c -r examples/connections/main"
  exec "nim c --mm:refc -r examples/connections/main"

  exec "nim c -r src/seaqt/private/test_metaobjectgen"
