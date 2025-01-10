# Package

version       = "0.9.2"
author        = "Filippo Cucchetto"
description   = "QML bindings for Nim"
license       = "LGPLv3"
srcDir        = "src"

# Deps

requires "nim >= 1.2.0"
requires "https://github.com/seaqt/nim-seaqt.git#qt-5.15"

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

