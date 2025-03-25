# seaqt
# Copyright (c) 2025 seaqt developers
# MIT, GPLv2, GPLv3 and WTFPL

## Generator for QMetaObject-compatible binary metadata - the format is not very
## well documented but can fairly easily be reverse-engineered by running `moc`
## and/or examining other metaobject-compatible tooling such as:
##
## * https://github.com/woboq/verdigris
## * https://woboq.com/blog/how-qt-signals-slots-work.html

import
  std/[macros, sequtils, strutils, tables],
  seaqt/[qmetamethod, qmetatype, qmetaobject, QtCore/qtcore_pkg]

export qmetamethod, qmetatype, qmetaobject

from system/ansi_c import c_calloc, c_malloc, c_free

const
  AccessPrivate = cuint 0x00
  AccessProtected = cuint 0x01
  AccessPublic = cuint 0x02
  AccessMask = cuint 0x03

  MethodMethod = cuint 0x00
  MethodSignal = cuint 0x04
  MethodSlot = cuint 0x08
  MethodConstructor = cuint 0x0c
  MethodTypeMask = cuint 0x0c

  MethodCompatibility = cuint 0x10
  MethodCloned = cuint 0x20
  MethodScriptable = cuint 0x40
  MethodRevisioned = cuint 0x80

  # PropertyFlags
  Invalid = cuint 0x00000000
  Readable = cuint 0x00000001
  Writable = cuint 0x00000002
  Resettable = cuint 0x00000004
  EnumOrFlag = cuint 0x00000008
  Alias = cuint 0x00000010
  StdCppSet = cuint 0x00000100
  Constant = cuint 0x00000400
  Final = cuint 0x00000800
  Designable = cuint 0x00001000
  Scriptable = cuint 0x00004000
  Stored = cuint 0x00010000
  Editable = cuint 0x00040000
  User = cuint 0x00100000
  Notify = cuint 0x00400000
  Required = cuint 0x01000000
  Bindable = cuint 0x02000000

  # MetaDataFlags
  IsUnresolvedType = cuint 0x80000000

  # QMetaObjectPrivate offsets (5.15, 6.0)
  revisionPos = 0
  classNamePos = 1
  classInfoCountPos = 2
  classInfoDataPos = 3
  methodCountPos = 4
  methodDataPos = 5
  propertyCountPos = 6
  propertyDataPos = 7
  enumCountPos = 8
  enumDataPos = 9
  constructorCountPos = 10
  constructorDataPos = 11
  flagsPos = 12
  signalCountPos = 13
  QMetaObjectPrivateElems = 14

  QtCoreBuildVersionNum = block:
    const tmp = QtCoreBuildVersion.split(".").mapIt(it.parseInt)
    (tmp[0], tmp[1])

  QMetaObjectRevision =
    when QtCoreBuildVersionNum < (5, 0):
      {.error: "Unsupported Qt version: " & QtCoreBuildVersion.}
    elif QtCoreBuildVersionNum < (6, 0):
      7
    elif QtCoreBuildVersionNum < (7, 0):
      9
    else:
      {.error: "Unsupported Qt version: " & QtCoreBuildVersion.}

type
  QMetaObjectData = object
    superdata: pointer
    stringdata: pointer
    data: ptr cuint
    static_metacall: pointer
    relatedMetaObjects: pointer
    when QMetaObjectRevision >= 9:
      metaTypes: pointer
    extradata: pointer

  QByteArrayData = object
    refcount: cint # atomic..
    size: cuint
    alloc: uint32 # bitfield...
    offset: uint # ptrdiff_t

  ParamDef* = object
    name*: string
    metaType*: cint

  MethodDef* = object
    name*: string
    returnMetaType*: cint
    params*: seq[ParamDef]
    flags*: cuint

  PropertyDef* = object
    name*: string
    metaType*: cint
    readSlot*, writeSlot*, notifySignal*: string

  QObjectDef* = object
    name*: string
    signals*: seq[MethodDef]
    slots*: seq[MethodDef]
    properties*: seq[PropertyDef]

template usizeof(T): untyped =
  cuint(sizeof(T))

func isSignal*(m: MethodDef): bool =
  (m.flags and MethodSignal) > 0
func isSlot*(m: MethodDef): bool =
  (m.flags and MethodSlot) > 0

proc signalDef*(
    _: type MethodDef, name: string, params: openArray[ParamDef]
): MethodDef =
  MethodDef(
    name: name,
    params: @params,
    returnMetaType: QMetaTypeTypeEnum.Void,
    flags: MethodSignal or AccessPublic,
  )

proc slotDef*(
    _: type MethodDef, name: string, returnMetaType: cint, params: openArray[ParamDef]
): MethodDef =
  MethodDef(
    name: name,
    params: @params,
    returnMetaType: returnMetaType,
    flags: MethodSlot or AccessPublic,
  )

proc genMetaObjectData*(
    className: string,
    signals: openArray[MethodDef],
    slots: openArray[MethodDef],
    props: openArray[PropertyDef],
): (seq[cuint], seq[byte], seq[pointer]) =
  # Class names need to be globally unique
  # TODO use something other than a thread var
  var counter {.threadvar.}: CountTable[string]

  let c = counter.getOrDefault(className, 0)
  counter.inc(className)

  let
    hasNotifySignals = anyIt(props, it.notifySignal.len > 0)
    (methodSize, propSize) =
      when QMetaObjectRevision == 7:
        (cuint 5, cuint(if hasNotifySignals: 4 else: 3))
      elif QMetaObjectRevision == 9:
        (cuint 6, cuint 5)
      else:
        raiseAssert "Unsupported revision"

  static:
    doAssert QMetaObjectPrivateElems == 14, "Same in all supported versions"

  let
    className = className & (if c > 0: $c else: "")
    methods = @signals & @slots
    methodCount = cuint(methods.len())
    propertyCount = cuint(props.len())
    methodParamsSize = cuint(foldl(methods, a + b.params.len, 0)) * 2 + methodCount

    metaSize =
      QMetaObjectPrivateElems + methodCount * methodSize + methodParamsSize +
      cuint(props.len) * propSize + 1

  var metaTypes: seq[pointer]
  template addMetaType(s: cint): uint32 =
    let mt = QMetaType.create(s)
    metaTypes.add(
      if mt.isValid():
        mt.iface()
      else:
        nil
    )
    uint32(metaTypes.len() - 1)

  var strings: OrderedTable[string, int]
  template addString(s: untyped): cuint =
    let
      slen = strings.len()
      pos = strings.mgetOrPut($s, slen)
    pos.cuint

  var data = newSeq[cuint](metaSize.int)
  template addData(v: cuint) =
    data[dataIndex] = v
    dataIndex += 1

  data[revisionPos] = QMetaObjectRevision

  var dataIndex = cuint QMetaObjectPrivateElems
  var paramsIndex = cuint(0)

  template addType(metaType: cint): cuint =
    if metaType == QMetaTypeTypeEnum.UnknownType:
      raiseAssert "Unknown types not supported yet"
    else:
      cuint metaType

  block: # classinfo
    discard

  block: # private data
    data[classNamePos] = addString(className)
    data[methodCountPos] = methodCount
    data[methodDataPos] = if methodCount == 0: 0 else: dataIndex
    dataIndex += methodSize * methodCount

    paramsIndex = dataIndex
    dataIndex += methodParamsSize

    data[propertyCountPos] = propertyCount
    data[propertyDataPos] = if propertyCount == 0: 0 else: dataIndex

    dataIndex += propSize * propertyCount

    data[signalCountPos] = cuint signals.len

  dataIndex = QMetaObjectPrivateElems

  when QMetaObjectRevision >= 9:
    for p in props:
      discard addMetaType(p.metaType)

  block: # Methods and their parameters
    for m in methods:
      addData(addString(m.name))
      addData(cuint m.params.len)
      addData(paramsIndex)
      addData(addString("")) # tag
      addData(m.flags)

      when QMetaObjectRevision >= 9:
        addData(addMetaType(m.returnMetaType))

        for p in m.params:
          discard addMetaType(p.metaType)

      paramsIndex += 1 + cuint m.params.len * 2

  block: # Return types
    for m in methods:
      # TODO moc does not allow return-by-reference, replacing it with void:
      # https://github.com/openwebos/qt/blob/92fde5feca3d792dfd775348ca59127204ab4ac0/src/tools/moc/moc.cpp#L400
      addData(addType(m.returnMetaType))

      for p in m.params:
        addData(addType(p.metaType))

      for p in m.params:
        addData(addString(p.name))

  template signalIndex(nameParam: string): cuint =
    if nameParam.len > 0:
      var x = cuint 0
      for m in methods.filterIt(it.isSignal):
        if m.name == nameParam:
          break
        x += 1
      x
    else:
      0

  block: # Properties
    for p in props:
      addData(addString(p.name))
      addData(addType(p.metaType))
      addData(
        block:
          var v = Scriptable or Designable or Stored or Editable
          if p.readSlot.len > 0:
            v = v or Readable
          if p.writeSlot.len > 0:
            v = v or Writable
          if p.notifySignal.len > 0:
            v = v or Notify
          if p.writeSlot.len == 0 and p.notifySignal.len == 0:
            v = v or Constant
          v
      )

      when QMetaObjectRevision >= 9:
        addData(signalIndex(p.notifySignal))
        addData(0) # revision

  when QMetaObjectRevision < 9:
    if hasNotifySignals:
      for p in props:
        addData(signalIndex(p.notifySignal))

  addData(0) # terminator

  static:
    doAssert sizeof(pointer) == 8, "Only 64-bit support implemented"
  var stringtmp: string

  for s in strings.keys():
    stringtmp.add s
    stringtmp.add '\0'

  proc toBytes(v: SomeInteger): array[sizeof(v), byte] =
    # VM can't do casts :/
    for i in 0 ..< sizeof(result):
      result[i] = byte((v shr (i * 8)) and 0xff)

  when QMetaObjectRevision < 9:
    var
      stringdata = newSeq[byte](strings.len * sizeof(QByteArrayData) + stringtmp.len)
      pos = 0
      offset = cuint(sizeof(QByteArrayData) * strings.len)

    for s in strings.keys():
      assert(sizeof(QByteArrayData) == 24)

      stringdata[pos .. pos + 3] = toBytes(cast[cuint](-1))
      pos += 4

      stringdata[pos .. pos + 3] = toBytes(cast[cuint](s.len()))
      pos += 4

      stringdata[pos .. pos + 3] = toBytes(cast[cuint](0))
      pos += 4

      pos += 4 # Alignment

      stringdata[pos .. pos + 7] = toBytes(cast[uint64](offset))
      pos += 8

      offset -= usizeof(QByteArrayData)
      offset += uint32(s.len() + 1)

    let pstrings = sizeof(QByteArrayData) * strings.len
  else:
    var
      stringdata = newSeq[byte](strings.len * 2 * sizeof(cint) + stringtmp.len)
      pos = 0
      offset = cuint(strings.len() * 2 * sizeof(cint))
    for s in strings.keys():
      let len = cuint s.len()
      stringdata[pos .. pos + 3] = toBytes(offset)
      pos += 4
      stringdata[pos .. pos + 3] = toBytes(len)
      pos += 4

      offset = offset + len + 1
    let pstrings = strings.len * 2 * sizeof(cint)

  for i, c in stringtmp:
    stringdata[pstrings + i] = byte(stringtmp[i])

  (data, stringdata, metaTypes)

proc createMetaObject*(
    superclassMetaObject: gen_qobjectdefs_types.QMetaObject,
    data: openArray[cuint],
    stringdata: openArray[byte],
    metaTypes: openArray[pointer],
): gen_qobjectdefs.QMetaObject =
  template align(n: int): int =
    ((n + 7) div 8) * 8

  let
    superdata = superclassMetaObject.h
    dataBytes = data.len * sizeof(cuint)
    metaTypesBytes = metaTypes.len * sizeof(pointer)
    blob = cast[ptr UncheckedArray[byte]](c_malloc(
      csize_t(align(dataBytes) + align(stringdata.len) + metaTypesBytes)
    ))

  copyMem(addr blob[0], addr data[0], dataBytes)
  copyMem(addr blob[align(dataBytes)], addr stringdata[0], stringdata.len())

  var metaObjectData = QMetaObjectData(
    superdata: superdata,
    data: cast[ptr cuint](addr blob[0]),
    stringdata: addr blob[align(dataBytes)],
  )

  when QMetaObjectRevision >= 9:
    if metaTypes.len > 0:
      copyMem(
        addr blob[align(dataBytes) + align(stringdata.len)],
        addr metaTypes[0],
        metaTypesBytes,
      )

    metaObjectData.metaTypes = addr blob[align(dataBytes) + align(stringdata.len)]

  let tmp = gen_qobjectdefs.QMetaObject.create()
  copyMem(tmp.h, addr metaObjectData, sizeof(QMetaObjectData))
  tmp

proc genMetaObject*(
    superclassMetaObject: gen_qobjectdefs_types.QMetaObject,
    className: string,
    signals, slots: openArray[MethodDef],
    props: openArray[PropertyDef],
): gen_qobjectdefs_types.QMetaObject =
  let (data, stringdata, metaTypes) =
    genMetaObjectData(className, signals, slots, props)
  createMetaObject(superclassMetaObject, data, stringdata, metaTypes)
