## Regression test for QtProperty scalar marshaling.
##
## Nim `float` is float64. Reading a `QtProperty[float]` must travel
##   Nim getter -> QVariant(Double) -> QMetaObject ReadProperty -> QVariant(Double)
## without narrowing to 32 bits anywhere on the way.
##
## The bug this guards against: the getter used to store its result in a 32-bit
## `Float` QVariant (`floatVal=`), while the property metatype is `Double`. During
## `ReadProperty` the 8-byte Double buffer was then `construct`ed from only the
## 4 bytes of that Float storage, yielding garbage subnormal doubles in QML
## (e.g. a real 0.00729879 arriving as ~4.9e-315).
##
## The same pattern applies to Nim `int` on 64-bit: the property metatype is
## `LongLong` (8 bytes), but `intVal=` used to store a 32-bit `Int` QVariant.
## ReadProperty then `construct`s the 8-byte LongLong buffer from only 4 bytes,
## corrupting even in-range values and truncating anything outside int32 range.
##
## IMPORTANT: the value must be read back through `QObject.property()` (the real
## metacall/ReadProperty path). Inspecting the slot's `arguments[0].doubleVal`
## directly would NOT catch the bug, because QVariant's own Float->double
## conversion masks it - only the raw `construct` step corrupts the bytes.

import NimQml
import ./private/scalarhelpers

QtObject:
  type ScalarObj = ref object of QObject
    m_amount: float
    m_ratio: float32
    m_marketCap: float
    m_count: int

  proc delete(self: ScalarObj)
  proc setup(self: ScalarObj)

  proc newScalarObj(amount: float, ratio: float32, marketCap: float, count: int): ScalarObj =
    new(result, delete)
    result.m_amount = amount
    result.m_ratio = ratio
    result.m_marketCap = marketCap
    result.m_count = count
    result.setup

  proc delete(self: ScalarObj) =
    self.QObject.delete

  proc setup(self: ScalarObj) =
    self.QObject.setup

  proc amountChanged(self: ScalarObj) {.signal.}
  proc getAmount(self: ScalarObj): float {.slot.} =
    self.m_amount
  QtProperty[float] amount:
    read = getAmount
    notify = amountChanged

  proc ratioChanged(self: ScalarObj) {.signal.}
  proc getRatio(self: ScalarObj): float32 {.slot.} =
    self.m_ratio
  QtProperty[float32] ratio:
    read = getRatio
    notify = ratioChanged

  proc marketCapChanged(self: ScalarObj) {.signal.}
  proc getMarketCap(self: ScalarObj): float {.slot.} =
    self.m_marketCap
  QtProperty[float] marketCap:
    read = getMarketCap
    notify = marketCapChanged

  proc countChanged(self: ScalarObj) {.signal.}
  proc getCount(self: ScalarObj): int {.slot.} =
    self.m_count
  QtProperty[int] count:
    read = getCount
    notify = countChanged

proc test() =
  for expected in doubleCases:
    let o = newScalarObj(expected, 0.0'f32, expected * 1000.0, 0)
    defer: o.delete()

    let amount = readDouble(o, "amount")
    doAssert abs(amount - expected) < 1e-12,
      "amount marshaling broken: expected " & $expected & " got " & $amount

    let marketCap = readDouble(o, "marketCap")
    doAssert abs(marketCap - expected * 1000.0) < 1e-9,
      "marketCap marshaling broken: expected " & $(expected * 1000.0) & " got " & $marketCap

  for expected in floatCases:
    let o = newScalarObj(0.0, expected, 0.0, 0)
    defer: o.delete()
    let ratio = readFloat(o, "ratio")
    doAssert abs(ratio - expected) < 1e-5'f32,
      "ratio (float32) marshaling broken: expected " & $expected & " got " & $ratio

  for expected in intCases:
    let o = newScalarObj(0.0, 0.0'f32, 0.0, expected)
    defer: o.delete()
    let count = readLongLong(o, "count")
    doAssert count == expected,
      "count (int/LongLong) marshaling broken: expected " & $expected & " got " & $count

  echo "tqtproperty_marshaling: OK"

test()
