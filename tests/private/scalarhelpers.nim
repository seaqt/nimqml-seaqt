## Shared helpers and scalar test vectors for QtProperty regression tests.

from seaqt/qobject as seaqt_qobject import nil
from seaqt/qvariant as seaqt_qvariant import nil

const
  intCases* = when sizeof(int) == sizeof(cint):
    [42, int.high, int.low]
  else:
    [42, 5_000_000_000, -5_000_000_000, int.high, int.low]
  doubleCases* = [0.00729879, 22.796, 15.091, 1234.56789, -0.5, 1e-9]
  writeDoubleCases* = [0.00729879, 22.796, -0.5, 1e-9]
  floatCases* = [0.98599'f32, 3.14159'f32, -12.5'f32]

proc qobj*[T](o: T): seaqt_qobject.QObject =
  seaqt_qobject.QObject(h: o.vptr, owned: false)

proc readDouble*[T](o: T, name: cstring): float64 =
  seaqt_qvariant.toDouble(seaqt_qobject.property(qobj(o), name))

proc readFloat*[T](o: T, name: cstring): float32 =
  seaqt_qvariant.toFloat(seaqt_qobject.property(qobj(o), name))

proc readLongLong*[T](o: T, name: cstring): int =
  seaqt_qvariant.toLongLong(seaqt_qobject.property(qobj(o), name)).int

proc setDoubleProp*[T](o: T, name: cstring, value: float64) =
  discard seaqt_qobject.setProperty(
    qobj(o), name, seaqt_qvariant.create(seaqt_qvariant.QVariant, value))

proc setLongLongProp*[T](o: T, name: cstring, value: clonglong) =
  discard seaqt_qobject.setProperty(
    qobj(o), name, seaqt_qvariant.create(seaqt_qvariant.QVariant, value))
