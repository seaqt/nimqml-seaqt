# seaqt
# Emulation layer of https://github.com/filcuc/dotherside using
# https://github.com/seaqt/nim-seaqt

import
  seaqt/[
    qabstractitemdelegate, qabstractitemmodel, qapplication, qcoreapplication,
    qguiapplication, qmetatype, qmetaobject, qobject, qmetamethod, qresource, qurl,
    qvariant, qqmlapplicationengine, qqmlcomponent, qqmlcontext, qquickview,
  ],
  ./metaobjectgen

{.compile: "notherside.cpp".}

template take*(
    v: gen_qabstractitemmodel_types.QAbstractItemModel
): DosQAbstractItemModel =
  var vv = v
  vv.owned = false
  DosQAbstractItemModel(vv.h)

proc borrow*(
    v: gen_qabstractitemmodel_types.QAbstractItemModel
): DosQAbstractItemModel =
  DosQAbstractItemModel(v.h)

converter toQAbstractItemModel*(
    v: DosQAbstractItemModel
): gen_qabstractitemmodel_types.QAbstractItemModel =
  gen_QAbstractItemModel_types.QAbstractItemModel(h: pointer(v))

template take*(
    v: gen_qabstractitemmodel_types.QAbstractListModel
): DosQAbstractListModel =
  var vv = v
  vv.owned = false
  DosQAbstractListModel(vv.h)

proc borrow*(
    v: gen_qabstractitemmodel_types.QAbstractListModel
): DosQAbstractListModel =
  DosQAbstractListModel(v.h)

converter toQAbstractListModel*(
    v: DosQAbstractListModel
): gen_qabstractitemmodel_types.QAbstractListModel =
  gen_QAbstractItemModel_types.QAbstractListModel(h: pointer(v))

template take*(
    v: gen_qabstractitemmodel_types.QAbstractTableModel
): DosQAbstractTableModel =
  var vv = v
  vv.owned = false
  DosQAbstractTableModel(vv.h)

proc borrow*(
    v: gen_qabstractitemmodel_types.QAbstractTableModel
): DosQAbstractTableModel =
  DosQAbstractTableModel(v.h)

converter toQAbstractTableModel*(
    v: DosQAbstractTableModel
): gen_qabstractitemmodel_types.QAbstractTableModel =
  gen_QAbstractItemModel_types.QAbstractTableModel(h: pointer(v))

template take*(
    v: gen_qqmlapplicationengine_types.QQmlApplicationEngine
): DosQQmlApplicationEngine =
  var vv = v
  vv.owned = false
  DosQQmlApplicationEngine(vv.h)

proc borrow*(
    v: gen_qqmlapplicationengine_types.QQmlApplicationEngine
): DosQQmlApplicationEngine =
  DosQQmlApplicationEngine(v.h)

converter toQQmlApplicationEngine*(
    v: DosQQmlApplicationEngine
): gen_qqmlapplicationengine_types.QQmlApplicationEngine =
  gen_qqmlapplicationengine_types.QQmlApplicationEngine(h: pointer(v))

template take*(v: gen_qqmlcontext_types.QQmlContext): DosQQmlContext =
  var vv = v
  vv.owned = false
  DosQQmlContext(vv.h)

proc borrow*(v: gen_qqmlcontext_types.QQmlContext): DosQQmlContext =
  DosQQmlContext(v.h)

converter toQQmlContext*(v: DosQQmlContext): gen_qqmlcontext_types.QQmlContext =
  gen_qqmlcontext_types.QQmlContext(h: pointer(v))

converter toQQmlEngine*(v: DosQQmlApplicationEngine): gen_qQmlEngine_types.QQmlEngine =
  gen_qQmlEngine_types.QQmlEngine(h: pointer(v))

template take*(v: gen_qobjectdefs_types.QMetaObject): DosQMetaObject =
  var vv = v
  vv.owned = false
  DosQMetaObject(vv.h)

proc borrow*(v: gen_qobjectdefs_types.QMetaObject): DosQMetaObject =
  DosQMetaObject(v.h)

converter toQMetaObject*(v: DosQMetaObject): gen_qobjectdefs_types.QMetaObject =
  gen_qobjectdefs_types.QMetaObject(h: pointer(v))

template take*(
    v: gen_qobjectdefs_types.QMetaObjectConnection
): DosQMetaObjectConnection =
  var vv = v
  vv.owned = false
  DosQMetaObjectConnection(vv.h)

proc borrow*(v: gen_qobjectdefs_types.QMetaObjectConnection): DosQMetaObjectConnection =
  DosQMetaObjectConnection(v.h)

converter toQMetaObjectConnection*(
    v: DosQMetaObjectConnection
): gen_qobjectdefs_types.QMetaObjectConnection =
  gen_qobjectdefs_types.QMetaObjectConnection(h: pointer(v))

template take*(v: gen_qabstractitemmodel_types.QModelIndex): DosQModelIndex =
  var vv = v
  vv.owned = false
  DosQModelIndex(vv.h)

proc borrow*(v: gen_qabstractitemmodel_types.QModelIndex): DosQModelIndex =
  DosQModelIndex(v.h)

converter toQModelIndex*(v: DosQModelIndex): gen_qabstractitemmodel_types.QModelIndex =
  gen_qabstractitemmodel_types.QModelIndex(h: pointer(v))

template take*(v: gen_qobject_types.QObject): DosQObject =
  var vv = v
  vv.owned = false
  DosQObject(vv.h)

proc borrow*(v: gen_qobject_types.QObject): DosQObject =
  DosQObject(v.h)

converter toQObject*(v: DosQObject): gen_qobject_types.QObject =
  gen_qobject_types.QObject(h: pointer(v))

template take*(v: gen_qurl_types.QUrl): DosQUrl =
  var vv = v
  vv.owned = false
  DosQUrl(vv.h)

proc borrow*(v: gen_qurl_types.QUrl): DosQUrl =
  DosQUrl(v.h)

converter toQQrl*(v: DosQUrl): gen_qurl_types.QUrl =
  gen_qurl_types.QUrl(h: pointer(v))

template take*(v: gen_qvariant_types.QVariant): DosQVariant =
  var vv = v
  vv.owned = false
  DosQVariant(vv.h)

proc borrow*(v: gen_qvariant_types.QVariant): DosQVariant =
  DosQVariant(v.h)

converter toQVariant*(v: DosQVariant): gen_qvariant.QVariant =
  gen_qvariant_types.QVariant(h: pointer(v))

from system/ansi_c import c_calloc, c_free

# TODO Get rid of this - but it requires changing the dos_* interface significantly
import std/tables
# https://github.com/nim-lang/Nim/issues/24770
var classProps {.threadvar.}: TableRef[string, QMetaMethod]

proc classLookup(mo: gen_qobjectdefs_types.QMetaObject, id: cint, read: bool): string =
  repr(mo.h) & $id & $read

proc findProp(
    mo: gen_qobjectdefs_types.QMetaObject, id: cint, read: bool
): QMetaMethod =
  try:
    QMetaMethod(h: classProps[classLookup(mo, id, read)].h, owned: false)
  except CatchableError as exc:
    raiseAssert exc.msg

template noExceptions(body: untyped): untyped =
  try:
    body
  except Defect as e:
    raise e
  except Exception as e:
    raiseAssert(e.msg & "\n" & e.getStackTrace())

proc nos_qmetaobject_create(
    superclassMetaObject: gen_qobjectdefs_types.QMetaObject,
    className: cstring,
    signalDefinitions: ptr DosSignalDefinitions,
    slotDefinitions: ptr DosSlotDefinitions,
    propertyDefinitions: ptr DosPropertyDefinitions,
): DosQMetaObject =
  template params(
      s: DosSignalDefinition | DosSlotDefinition
  ): openArray[DosParameterDefinition] =
    var p = cast[ptr UncheckedArray[DosParameterDefinition]](s.parameters)
    p.toOpenArray(0, s.parametersCount.int - 1)

  let
    signalDefs =
      cast[ptr UncheckedArray[DosSignalDefinition]](signalDefinitions.definitions)
    slotDefs = cast[ptr UncheckedArray[DosSlotDefinition]](slotDefinitions.definitions)
    propertyDefs =
      cast[ptr UncheckedArray[DosPropertyDefinition]](propertyDefinitions.definitions)

    signals = mapIt(
      signalDefs.toOpenArray(0, signalDefinitions.count.int - 1),
      MethodDef.signalDef(
        $it.name, it.params.mapIt(ParamDef(name: $it.name, metaType: it.metaType))
      ),
    )
    slots = mapIt(
      slotDefs.toOpenArray(0, slotDefinitions.count.int - 1),
      MethodDef.slotDef(
        $it.name,
        it.returnMetaType,
        it.params.mapIt(ParamDef(name: $it.name, metaType: it.metaType)),
      ),
    )
    props = mapIt(
      propertyDefs.toOpenArray(0, propertyDefinitions.count.int - 1),
      PropertyDef(
        name: $it.name,
        metaType: it.propertyMetaType,
        readSlot: $it.readSlot,
        writeSlot: $it.writeSlot,
        notifySignal: $it.notifySignal,
      ),
    )

  var tmp = genMetaObject(superclassMetaObject, $className, signals, slots, props)
  if classProps.isNil():
    new(classProps)

  block:
    for i in 0 ..< propertyDefinitions.count:
      let prop = propertyDefs[i]
      if prop.readSlot != nil:
        for j in 0 ..< slotDefinitions.count:
          if slotDefs[j].name == prop.readSlot:
            classProps[classLookup(tmp, i, true)] = tmp.methodX(
              superclassMetaObject.methodCount() + j + signalDefinitions.count
            )

      if prop.writeSlot != nil:
        for j in 0 ..< slotDefinitions.count:
          if slotDefs[j].name == prop.writeSlot:
            classProps[classLookup(tmp, i, false)] = tmp.methodX(
              superclassMetaObject.methodCount() + j + signalDefinitions.count
            )

  tmp.take()

template setupCallbacks[MC](
    T: type,
    nimobjectParam: NimQObject,
    metaObjectParam: DosQMetaObject,
    dosQObjectCallbackParam: DosQObjectCallBack,
    vtbl: auto,
    superMc: proc(self: MC, c: cint, index: cint, param3: pointer): cint {.
      raises: [], nimcall
    .},
) =
  func fromBytes(_: type string, v: openArray[byte]): string =
    if v.len > 0:
      result = newString(v.len)
      when nimvm:
        for i, c in v:
          result[i] = cast[char](c)
      else:
        copyMem(addr result[0], unsafeAddr v[0], v.len)

  vtbl.metacall = proc(
      self: T, c: cint, index: cint, param3: pointer
  ): cint {.closure, raises: [], gcsafe.} =
    let id = superMc(self, c, index, param3)
    if id < 0:
      return id

    let mo = metaObjectParam

    template callQObjectCallback(meth: QMetaMethod, offset: int) =
      let name = gen_qvariant.QVariant.create(cstring(string.fromBytes(meth.name())))
      var args = newSeq[gen_qvariant.QVariant](meth.parameterCount() + 1)
      args[0] = gen_qvariant.QVariant.create()

      for i in cint(0) ..< meth.parameterCount():
        args[i + 1] =
          when compiles(
            gen_qvariant.QVariant.create(meth.parameterType(i), argv[int(i + offset)])
          ):
            gen_qvariant.QVariant.create(meth.parameterType(i), argv[int(i + offset)])
          else:
            gen_qvariant.QVariant.create(
              meth.parameterMetaType(i), argv[int(i + offset)]
            )
      var dosArgs = args.mapIt(DosQVariant(it.borrow()))
      {.gcsafe.}:
        dosQObjectCallbackParam(
          nimobjectParam,
          name.borrow(),
          cint dosArgs.len,
          cast[ptr DosQVariantArray](addr dosArgs[0]),
        )
      if meth.returnType() != QMetaTypeTypeEnum.Void and dosArgs[0].isValid():
        discard QMetaType.construct(meth.returnType(), argv[0], args[0].constData())

    noExceptions:
      const propEnums =
        when declared(QueryPropertyDesignable):
          {
            QMetaObjectCallEnum.ResetProperty,
            QMetaObjectCallEnum.RegisterPropertyMetaType,
            QMetaObjectCallEnum.QueryPropertyDesignable,
            QMetaObjectCallEnum.QueryPropertyScriptable,
            QMetaObjectCallEnum.QueryPropertyStored,
            QMetaObjectCallEnum.QueryPropertyEditable,
            QMetaObjectCallEnum.QueryPropertyUser,
          }
        else:
          {
            QMetaObjectCallEnum.ResetProperty, QMetaObjectCallEnum.BindableProperty,
            QMetaObjectCallEnum.RegisterPropertyMetaType,
          }

      var argv {.inject.} = cast[ptr UncheckedArray[pointer]](param3)
      case c
      of QMetaObjectCallEnum.InvokeMetaMethod:
        if index < mo.methodCount():
          let meth = mo.methodX(index)
          callQObjectCallback(meth, 1)

        id - (mo.methodCount() - mo.methodOffset())
      of QMetaObjectCallEnum.RegisterMethodArgumentMetaType:
        id - (mo.methodCount() - mo.methodOffset())
      of QMetaObjectCallEnum.ReadProperty:
        if index < mo.propertyCount():
          let property = mo.property(index)
          if property.isValid() and property.isReadable():
            let meth = findProp(mo, id, true)
            callQObjectCallback(meth, 1)

        id - (mo.propertyCount() - mo.propertyOffset())
      of QMetaObjectCallEnum.WriteProperty:
        if index < mo.propertyCount():
          let property = mo.property(index)
          if property.isValid() and property.isWritable():
            let meth = findProp(mo, id, false)
            callQObjectCallback(meth, 0)

        id - (mo.propertyCount() - mo.propertyOffset())
      of propEnums:
        id - (mo.propertyCount() - mo.propertyOffset())
      else:
        id

  vtbl.metaObject = proc(
      self: T
  ): gen_qobjectdefs.QMetaObject {.closure, raises: [], gcsafe.} =
    metaObjectParam

template setupCallbacks(
    T: type,
    modelPtr: NimQAbstractListModel,
    qaimCallbacks: DosQAbstractItemModelCallbacks,
    vtbl:
      QAbstractItemModelVTable | QAbstractListModelVTable | QAbstractTableModelVtable,
) =
  if qaimCallbacks.rowCount != nil:
    vtbl.rowCount = proc(self: T, parent: QModelIndex): cint =
      noExceptions:
        var v: cint
        {.gcsafe.}:
          qaimCallbacks.rowCount(modelPtr, parent.borrow(), v)
        v

  when T is gen_qabstractitemmodel.QAbstractTableModel:
    if qaimCallbacks.columnCount != nil:
      vtbl.columnCount = proc(self: T, parent: QModelIndex): cint =
        noExceptions:
          var v: cint
          {.gcsafe.}:
            qaimCallbacks.columnCount(modelPtr, parent.borrow(), v)
          v

  if qaimCallbacks.data != nil:
    vtbl.data = proc(self: T, index: QModelIndex, role: cint): gen_qvariant.QVariant =
      noExceptions:
        var v = gen_qvariant.QVariant.create()
        {.gcsafe.}:
          qaimCallbacks.data(modelPtr, index.borrow(), role, v.borrow())
        v

  if qaimCallbacks.setData != nil:
    vtbl.setData = proc(
        self: T, index: QModelIndex, value: gen_qvariant.QVariant, role: cint
    ): bool =
      noExceptions:
        var v: bool
        {.gcsafe.}:
          qaimCallbacks.setData(modelPtr, index.borrow(), value.borrow(), role, v)
        v

  if qaimCallbacks.roleNames != nil:
    vtbl.roleNames = proc(self: T): tables.Table[cint, seq[byte]] =
      noExceptions:
        {.gcsafe.}:
          qaimCallbacks.roleNames(modelPtr)

  if qaimCallbacks.flags != nil:
    vtbl.flags = proc(self: T, index: QModelIndex): cint =
      noExceptions:
        var v: cint
        {.gcsafe.}:
          qaimCallbacks.flags(modelPtr, index.borrow(), v)
        v

  if qaimCallbacks.headerData != nil:
    vtbl.headerData = proc(
        self: T, section: cint, orientation: cint, role: cint
    ): gen_qvariant.QVariant =
      noExceptions:
        var v = gen_qvariant.QVariant.create()
        {.gcsafe.}:
          qaimCallbacks.headerData(modelPtr, section, orientation, role, v.borrow())
        v
  if qaimCallbacks.index != nil:
    vtbl.index =
      when T is QAbstractItemModel:
        proc(
            self: T, row: cint, column: cint, parent: QModelIndex
        ): QModelIndex {.closure.} =
          noExceptions:
            var v: DosQModelIndex
            {.gcsafe.}:
              qaimCallbacks.index(modelPtr, row, column, parent.borrow(), v)
            v
      else:
        proc(
            self: T, row: cint, column: cint, parent: QModelIndex
        ): QModelIndex {.closure.} =
          noExceptions:
            var v: DosQModelIndex
            {.gcsafe.}:
              qaimCallbacks.index(modelPtr, row, column, parent.borrow(), v)
            v

  when T isnot gen_qabstractitemmodel.QAbstractListModel and
      T isnot gen_qabstractitemmodel.QAbstractTableModel:
    if qaimCallbacks.parent != nil:
      vtbl.parent = proc(self: T, child: QModelIndex): QModelIndex =
        noExceptions:
          var v: DosQModelIndex
          {.gcsafe.}:
            qaimCallbacks.parent(modelPtr, child.borrow(), v)
          v

    if qaimCallbacks.hasChildren != nil:
      vtbl.hasChildren = proc(self: T, child: QModelIndex): bool =
        noExceptions:
          var v: bool
          {.gcsafe.}:
            qaimCallbacks.hasChildren(modelPtr, child.borrow(), v)
          v

  if qaimCallbacks.canFetchMore != nil:
    vtbl.canFetchMore = proc(self: T, parentX: QModelIndex): bool {.closure, gcsafe.} =
      noExceptions:
        var v: bool
        {.gcsafe.}:
          qaimCallbacks.canFetchMore(modelPtr, parentX.borrow(), v)
        v

  if qaimCallbacks.fetchMore != nil:
    vtbl.fetchMore = proc(self: T, parentX: QModelIndex) {.closure, gcsafe.} =
      noExceptions:
        {.gcsafe.}:
          qaimCallbacks.fetchMore(modelPtr, parentX.borrow())

proc nos_qobject_connect_lambda_with_context_static(
    sender: gen_qobject_types.QObject,
    senderFunc: cstring,
    context: gen_qobject_types.QObject,
    callback: DosQObjectConnectLambdaCallback,
    data: pointer,
    connectionType: cint,
): DosQMetaObjectConnection =
  let
    meta = sender.metaObject()
    meth = meta.methodX(meta.indexOfSignal(cast[cstring](cast[uint](senderFunc) + 1)))

  proc slot(argv: pointer) =
    let argv = cast[ptr UncheckedArray[pointer]](argv)
    var args = newSeq[DosQVariant](meth.parameterCount())
    for i in cint(0) ..< cint(args.len):
      args[i] =
        when compiles(
          gen_qvariant.QVariant.create(meth.parameterType(i), argv[int(i) + 1])
        ):
          gen_qvariant.QVariant.create(meth.parameterType(i), argv[int(i) + 1]).take()
        else:
          gen_qvariant.QVariant.create(meth.parameterMetaType(i), argv[int(i) + 1]).take()

    noExceptions:
      {.gcsafe.}:
        callback(data, cint args.len, cast[ptr DosQVariantArray](addr args[0]))

  DosQMetaObjectConnection(
    gen_qobject_types.QObject.connectRaw(
      sender, senderFunc, context, slot, connectionType, meta
    ).take()
  )

proc nos_chararray_delete(s: cstring) {.importc.}
