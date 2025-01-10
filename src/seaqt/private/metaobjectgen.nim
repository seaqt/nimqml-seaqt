# seaqt
# Copyright (c) 2025 seaqt developers
# MIT, GPLv2, GPLv3 and WTFPL

import
  std/[macros, sequtils, strutils, tables], seaqt/[qmetamethod, qmetatype, qmetaobject]

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
  StdCppSet = cuint 0x00000100
  Constant = cuint 0x00000400
  Final = cuint 0x00000800
  Designable = cuint 0x00001000
  ResolveDesignable = cuint 0x00002000
  Scriptable = cuint 0x00004000
  ResolveScriptable = cuint 0x00008000
  Stored = cuint 0x00010000
  ResolveStored = cuint 0x00020000
  Editable = cuint 0x00040000
  ResolveEditable = cuint 0x00080000
  User = cuint 0x00100000
  ResolveUser = cuint 0x00200000
  Notify = cuint 0x00400000
  Revisioned = cuint 0x00800000
  Required = cuint 0x01000000

  # QMetaObjectPrivate offsets (5.15)
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

  QMetaObjectRevision = 8
    # 7 == 5.0
    # 8 == 5.12

type
  QMetaObjectData = object
    superdata: pointer
    stringdata: pointer
    data: ptr cuint
    static_metacall: pointer
    relatedMetaObjects: pointer
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
): (seq[cuint], seq[byte]) =
  # Class names need to be globally unique
  # TODO use something other than a thread var
  var counter {.threadvar.}: CountTable[string]

  let c = counter.getOrDefault(className, 0)
  counter.inc(className)

  let
    className = className & (if c > 0: $c else: "")
    methods = @signals & @slots
    methodCount = cuint(methods.len())
    methodParamsSize = cuint(foldl(methods, a + b.params.len, 0)) * 2 + methodCount

    hasNotifySignals = anyIt(props, it.notifySignal.len > 0)
    metaSize =
      QMetaObjectPrivateElems + methodCount * 5 + methodParamsSize + cuint(
        props.len * 3
      ) + cuint(ord(hasNotifySignals)) * cuint(props.len) + 1

  var data = newSeq[cuint](metaSize.int)
  data[revisionPos] = QMetaObjectRevision

  var dataIndex = cuint QMetaObjectPrivateElems
  var paramsIndex = cuint(0)

  block: # classinfo
    discard

  block: # methods
    data[methodCountPos] = methodCount
    data[methodDataPos] = dataIndex
    dataIndex += 5 * methodCount

    paramsIndex = dataIndex
    dataIndex += methodParamsSize

    data[propertyCountPos] = cuint(props.len)
    data[propertyDataPos] = dataIndex

    dataIndex += 3 * data[propertyCountPos]
    if hasNotifySignals:
      dataIndex += data[propertyCountPos]

    data[signalCountPos] = cuint signals.len

  dataIndex = QMetaObjectPrivateElems

  var
    strings: OrderedTable[string, int]
    indices: seq[QByteArrayData]
    stringtmp: string

  template addString(s: untyped): cuint =
    let slen = strings.len()
    let pos = strings.mgetOrPut($s, strings.len)
    if strings.len > slen:
      indices.add(QByteArrayData(refcount: -1, size: cuint(len(s))))

      stringtmp.add s
      stringtmp.add '\0'
    pos.cuint

  block:
    discard addString(className)

  block: # Methods and their parameters
    for m in methods:
      data[dataIndex] = addString(m.name)
      data[dataIndex + 1] = cuint m.params.len
      data[dataIndex + 2] = paramsIndex
      data[dataIndex + 3] = addString("") # TODO tag
      data[dataIndex + 4] = m.flags
      dataIndex += 5
      paramsIndex += 1 + cuint m.params.len * 2

  block: # Return types
    for m in methods:
      # TODO moc does not allow return-by-reference, replacing it with void:
      # https://github.com/openwebos/qt/blob/92fde5feca3d792dfd775348ca59127204ab4ac0/src/tools/moc/moc.cpp#L400
      data[dataIndex] = cuint m.returnMetaType
      dataIndex += 1
      for p in m.params:
        data[dataIndex] = cuint p.metaType # TODO builtin?
        dataIndex += 1

      for p in m.params:
        data[dataIndex] = addString p.name # TODO builtin?
        dataIndex += 1

  block: # Properties
    for p in props:
      data[dataIndex] = addString(p.name)
      data[dataIndex + 1] = cuint p.metaType
      data[dataIndex + 2] = block:
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

      dataIndex += 3

  if hasNotifySignals:
    for p in props:
      if p.notifySignal.len > 0:
        var x = cuint 0
        for m in methods.filterIt(it.isSignal):
          if m.name == p.notifySignal:
            break
          x += 1
        data[dataIndex] = x
      else:
        data[dataIndex] = 0
      dataIndex += 1

  dataIndex += 1

  var offset = cuint(sizeof(QByteArrayData) * strings.len)
  for i in 0 ..< indices.len:
    indices[i].offset = offset
    offset -= usizeof(QByteArrayData)
    offset += indices[i].size + 1

  var
    stringdata = newSeq[byte](strings.len * sizeof(QByteArrayData) + stringtmp.len)
    pos = 0

  for i in 0 ..< indices.len:
    assert(sizeof(QByteArrayData) == 24)

    proc toBytes(v: SomeInteger): array[sizeof(v), byte] =
      # VM can't do casts :/
      for i in 0 ..< sizeof(result):
        result[i] = byte((v shr (i * 8)) and 0xff)

    stringdata[pos ..< pos + 3] = toBytes(cast[cuint](indices[i].refcount))
    pos += 4

    stringdata[pos ..< pos + 3] = toBytes(cast[cuint](indices[i].size))
    pos += 4

    stringdata[pos ..< pos + 3] = toBytes(cast[cuint](indices[i].alloc))
    pos += 4

    pos += 4 # Alignment

    stringdata[pos ..< pos + 7] = toBytes(cast[uint](indices[i].offset))
    pos += 8

  let pstrings = sizeof(QByteArrayData) * strings.len

  for i, c in stringtmp:
    stringdata[pstrings + i] = byte(stringtmp[i])

  (data, stringdata)

proc createMetaObject*(
    superclassMetaObject: gen_qobjectdefs_types.QMetaObject,
    data: openArray[cuint],
    stringdata: seq[byte],
): gen_qobjectdefs.QMetaObject =
  let
    superdata = superclassMetaObject.h
    dataBytes = data.len * sizeof(cuint)
    blob = cast[ptr UncheckedArray[byte]](c_malloc(csize_t(dataBytes + stringdata.len)))

  copyMem(addr blob[0], addr data[0], dataBytes)
  copyMem(addr blob[dataBytes], addr stringdata[0], stringdata.len())

  var metaObjectData = QMetaObjectData(
    superdata: superdata,
    data: cast[ptr cuint](addr blob[0]),
    stringdata: addr blob[dataBytes],
  )

  let tmp = gen_qobjectdefs.QMetaObject.create()
  copyMem(tmp.h, addr metaObjectData, sizeof(QMetaObjectData))
  tmp

proc genMetaObject*(
    superclassMetaObject: gen_qobjectdefs_types.QMetaObject,
    className: string,
    signals, slots: openArray[MethodDef],
    props: openArray[PropertyDef],
): gen_qobjectdefs_types.QMetaObject =
  let (data, stringdata) = genMetaObjectData(className, signals, slots, props)
  createMetaObject(superclassMetaObject, data, stringdata)
