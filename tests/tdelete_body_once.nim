## A QtObject's `delete` is called explicitly and again as its finalizer: its body must run
## exactly once, whatever happened to the Qt side in between.

import NimQml

var bodyRuns: int
var childDeletes: int

QtObject:
  type Child = ref object of QObject

  proc delete(self: Child)
  proc setup(self: Child)

  proc newChild(): Child =
    new(result, delete)
    result.setup

  proc setup(self: Child) =
    self.QObject.setup

  proc delete(self: Child) =
    inc childDeletes
    self.QObject.delete

QtObject:
  type Owner = ref object of QObject
    child: Child

  proc delete(self: Owner)
  proc setup(self: Owner)

  proc newOwner(): Owner =
    new(result, delete)
    result.child = newChild()
    result.setup

  proc setup(self: Owner) =
    self.QObject.setup

  proc delete(self: Owner) =
    inc bodyRuns
    self.child.delete
    self.QObject.delete

# Keeps its Qt side (like an object QML creates, which Nim does not own)
QtObject:
  type NoBaseDelete = ref object of QObject

  proc delete(self: NoBaseDelete)
  proc setup(self: NoBaseDelete)

  proc newNoBaseDelete(): NoBaseDelete =
    new(result, delete)
    result.setup

  proc setup(self: NoBaseDelete) =
    self.QObject.setup

  proc delete(self: NoBaseDelete) =
    inc bodyRuns

QtObject:
  type EarlyReturn = ref object of QObject
    keepQtSide: bool

  proc delete(self: EarlyReturn)
  proc setup(self: EarlyReturn)

  proc newEarlyReturn(): EarlyReturn =
    new(result, delete)
    result.keepQtSide = true
    result.setup

  proc setup(self: EarlyReturn) =
    self.QObject.setup

  proc delete(self: EarlyReturn) =
    inc bodyRuns
    if self.keepQtSide:
      return
    self.QObject.delete

var parentRuns: int
var childRuns: int

QtObject:
  type Base = ref object of QObject

  proc delete(self: Base)
  proc setup(self: Base)

  proc setup(self: Base) =
    self.QObject.setup

  proc delete(self: Base) =
    inc parentRuns
    self.QObject.delete

QtObject:
  type Derived = ref object of Base

  proc delete(self: Derived)

  proc newDerived(): Derived =
    new(result, delete)
    result.setup

  proc delete(self: Derived) =
    inc childRuns
    self.Base.delete

proc test() =
  block explicitThenFinalizer:
    bodyRuns = 0
    childDeletes = 0
    let o = newOwner()
    o.delete
    o.delete # what the finalizer does
    doAssert bodyRuns == 1, $bodyRuns
    doAssert childDeletes == 1, $childDeletes

  block deleteLaterStillRunsTheBody:
    bodyRuns = 0
    childDeletes = 0
    let o = newOwner()
    o.deleteLater
    o.delete
    o.delete
    doAssert bodyRuns == 1, $bodyRuns
    doAssert childDeletes == 1, "the children must still be deleted: " & $childDeletes

  block bodyWithoutBaseDelete:
    bodyRuns = 0
    let o = newNoBaseDelete()
    o.delete
    o.delete
    doAssert bodyRuns == 1, $bodyRuns

  block earlyReturn:
    bodyRuns = 0
    let o = newEarlyReturn()
    o.delete
    o.delete
    doAssert bodyRuns == 1, $bodyRuns

  block subtypeCallsParentDelete:
    parentRuns = 0
    childRuns = 0
    let o = newDerived()
    o.delete
    o.delete
    doAssert childRuns == 1, $childRuns
    doAssert parentRuns == 1, "the parent's body runs within the subtype's: " & $parentRuns

test()
echo "tdelete_body_once: OK"
