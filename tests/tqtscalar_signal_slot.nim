## Regression test for scalar marshaling on signal -> connected slot delivery.
##
## emit() stores the payload correctly via newQVariant, but the receiving slot reads
## arguments[1].intVal / floatVal. Before the int fix, large int signal args failed
## the same way as WriteProperty (cint truncation / RangeDefect).
##
## connect() signatures must use Qt C++ type names (qlonglong, float, double), not
## Nim type names (int, float32, float). A mismatch silently prevents the connection.

import NimQml
import ./private/scalarhelpers

QtObject:
  type RelayObj = ref object of QObject
    m_receivedInt: int
    m_receivedRatio: float32

  proc delete(self: RelayObj)
  proc setup(self: RelayObj)

  proc newRelayObj(): RelayObj =
    new(result, delete)
    result.setup

  proc delete(self: RelayObj) =
    self.QObject.delete

  proc setup(self: RelayObj) =
    self.QObject.setup

  proc intArrived(self: RelayObj, value: int) {.signal.}
  proc onInt(self: RelayObj, value: int) {.slot.} =
    self.m_receivedInt = value

  proc ratioArrived(self: RelayObj, value: float32) {.signal.}
  proc onRatio(self: RelayObj, value: float32) {.slot.} =
    self.m_receivedRatio = value

proc test() =
  block intSignal:
    let o = newRelayObj()
    defer: o.delete()
    discard QObject.connect(o, intArrived, o, onInt)
    for expected in intCases:
      o.m_receivedInt = 0
      o.intArrived(expected)
      doAssert o.m_receivedInt == expected,
        "signal->slot int broken: expected " & $expected & " got " & $o.m_receivedInt

  block ratioSignal:
    let o = newRelayObj()
    defer: o.delete()
    discard QObject.connect(o, ratioArrived, o, onRatio)
    for expected in floatCases:
      o.m_receivedRatio = 0.0'f32
      o.ratioArrived(expected)
      doAssert abs(o.m_receivedRatio - expected) < 1e-5'f32,
        "signal->slot float32 broken: expected " & $expected & " got " & $o.m_receivedRatio

  echo "tqtscalar_signal_slot: OK"

test()
