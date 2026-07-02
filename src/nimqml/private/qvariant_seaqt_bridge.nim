## Bridges between nimqml's QVariant and seaqt's QVariant.

from seaqt/QtCore/gen_qvariant_types import nil
from seaqt/QtCore/gen_qvariant import nil

proc seaqt*(self: QVariant): gen_qvariant_types.QVariant =
  ## nimqml QVariant -> seaqt QVariant, BORROWED.
  ## owned:false so seaqt's =destroy never frees the pointer nimqml still owns.
  gen_qvariant_types.QVariant(h: cast[pointer](self.vptr), owned: false)

proc newQVariant*(value: gen_qvariant_types.QVariant): QVariant =
  ## seaqt QVariant -> nimqml QVariant, CLONED.
  ## `value` is only read (borrowed) to deep-copy via the seaqt copy ctor; the clone
  ## is then owned by nimqml. Cloning (rather than transferring `value.h`) keeps the
  ## two ownership systems disjoint and avoids any double-free of a seaqt-owned result.
  var cloned = gen_qvariant.create(gen_qvariant_types.QVariant, value)  # owned:true deep copy
  result = newQVariantTakingPtr(cloned.h)  # nimqml takes ownership of the clone
  cloned.owned = false                     # neutralize seaqt =destroy; nimqml owns it now
