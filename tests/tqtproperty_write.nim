## Regression test for QtProperty WriteProperty scalar marshaling.
##
## Exercises the path Qt -> WriteProperty -> write slot -> arguments[N].intVal/doubleVal.
## Before the int fix, large values hit RangeDefect or truncation when the slot read
## a LongLong QVariant through intVal (cint). Before the float fix, setProperty then
## property() still failed on ReadProperty (same subnormal garbage as the read-only test).

import NimQml
import ./private/scalarhelpers

QtObject:
  type WriteObj = ref object of QObject
    m_amount: float
    m_count: int

  proc delete(self: WriteObj)
  proc setup(self: WriteObj)

  proc newWriteObj(): WriteObj =
    new(result, delete)
    result.setup

  proc delete(self: WriteObj) =
    self.QObject.delete

  proc setup(self: WriteObj) =
    self.QObject.setup

  proc amountChanged(self: WriteObj) {.signal.}
  proc getAmount(self: WriteObj): float {.slot.} =
    self.m_amount
  proc setAmount(self: WriteObj, amount: float) {.slot.} =
    self.m_amount = amount
    self.amountChanged()
  QtProperty[float] amount:
    read = getAmount
    write = setAmount
    notify = amountChanged

  proc countChanged(self: WriteObj) {.signal.}
  proc getCount(self: WriteObj): int {.slot.} =
    self.m_count
  proc setCount(self: WriteObj, count: int) {.slot.} =
    self.m_count = count
    self.countChanged()
  QtProperty[int] count:
    read = getCount
    write = setCount
    notify = countChanged

proc test() =
  for expected in intCases:
    let o = newWriteObj()
    defer: o.delete()
    setLongLongProp(o, "count", expected.clonglong)
    doAssert o.m_count == expected,
      "WriteProperty int broken: expected m_count " & $expected & " got " & $o.m_count
    let roundTrip = readLongLong(o, "count")
    doAssert roundTrip == expected,
      "WriteProperty int round-trip broken: expected " & $expected & " got " & $roundTrip

  for expected in writeDoubleCases:
    let o = newWriteObj()
    defer: o.delete()
    setDoubleProp(o, "amount", expected)
    let amount = readDouble(o, "amount")
    doAssert abs(amount - expected) < 1e-12,
      "WriteProperty float round-trip broken: expected " & $expected & " got " & $amount

  echo "tqtproperty_write: OK"

test()
