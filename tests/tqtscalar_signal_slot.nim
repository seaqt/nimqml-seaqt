## Regression test for scalar marshaling on signal -> connected slot delivery.
##
## emit() stores the payload correctly via newQVariant, but the receiving slot reads
## arguments[1].intVal. Before the int fix, large int signal args failed the same
## way as WriteProperty (cint truncation / RangeDefect).

import NimQml
import ./private/scalarhelpers

QtObject:
  type RelayObj = ref object of QObject
    m_receivedInt: int

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

proc test() =
  let o = newRelayObj()
  defer: o.delete()
  discard QObject.connect(o, intArrived, o, onInt)
  for expected in intCases:
    o.m_receivedInt = 0
    o.intArrived(expected)
    doAssert o.m_receivedInt == expected,
      "signal->slot int broken: expected " & $expected & " got " & $o.m_receivedInt

  echo "tqtscalar_signal_slot: OK"

test()
