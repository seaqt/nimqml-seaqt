{.push raises: [].}

import tables

type
  NimQObject = pointer
  NimQAbstractItemModel = pointer
  NimQAbstractListModel = pointer
  NimQAbstractTableModel = pointer
  DosQMetaObject = distinct pointer
  DosQObject = distinct pointer
  DosQObjectWrapper = distinct pointer
  DosQVariant = distinct pointer
  DosQQmlContext = distinct pointer
  DosQQmlApplicationEngine = distinct pointer
  DosQVariantArray = UncheckedArray[DosQVariant]
  DosQMetaType = cint
  DosQMetaTypeArray = UncheckedArray[DosQMetaType]
  DosQUrl = distinct pointer
  DosQQuickView = distinct pointer
  DosQHashIntByteArray = distinct pointer
  DosQModelIndex = distinct pointer
  DosQAbstractItemModel = distinct pointer
  DosQAbstractTableModel = distinct pointer
  DosQAbstractListModel = distinct pointer
  DosQMetaObjectConnection = distinct pointer

  DosParameterDefinition = object
    name: cstring
    metaType: cint

  DosSignalDefinition = object
    name: cstring
    parametersCount: cint
    parameters: pointer

  DosSignalDefinitions = object
    count: cint
    definitions: pointer

  DosSlotDefinition = object
    name: cstring
    returnMetaType: cint
    parametersCount: cint
    parameters: pointer

  DosSlotDefinitions = object
    count: cint
    definitions: pointer

  DosPropertyDefinition = object
    name: cstring
    propertyMetaType: cint
    readSlot: cstring
    writeSlot: cstring
    notifySignal: cstring

  DosPropertyDefinitions = object
    count: cint
    definitions: pointer

  DosCreateCallback = proc(id: cint, wrapper: DosQObjectWrapper, nimQObject: var NimQObject, dosQObject: var DosQObject) {.cdecl.}
  DosDeleteCallback = proc(id: cint, nimQObject: NimQObject) {.cdecl.}

  DosQmlRegisterType = object
    major: cint
    minor: cint
    uri: cstring
    qml: cstring
    staticMetaObject: DosQMetaObject
    createCallback: DosCreateCallback
    deleteCallback: DosDeleteCallback

  DosQObjectCallBack = proc(nimobject: NimQObject, slotName: DosQVariant, numArguments: cint, arguments: ptr DosQVariantArray) {.cdecl.}

  DosRowCountCallback = proc(nimmodel: NimQAbstractItemModel, rawIndex: DosQModelIndex, result: var cint) {.cdecl.}
  DosColumnCountCallback = proc(nimmodel: NimQAbstractItemModel, rawIndex: DosQModelIndex, result: var cint) {.cdecl.}
  DosDataCallback = proc(nimmodel: NimQAbstractItemModel, rawIndex: DosQModelIndex, role: cint, result: DosQVariant) {.cdecl.}
  DosSetDataCallback = proc(nimmodel: NimQAbstractItemModel, rawIndex: DosQModelIndex, value: DosQVariant, role: cint, result: var bool) {.cdecl.}
  DosRoleNamesCallback = proc(nimmodel: NimQAbstractItemModel): Table[cint, seq[byte]] {.cdecl.}
  DosFlagsCallback = proc(nimmodel: NimQAbstractItemModel, index: DosQModelIndex, result: var cint) {.cdecl.}
  DosHeaderDataCallback = proc(nimmodel: NimQAbstractItemModel, section: cint, orientation: cint, role: cint, result: DosQVariant) {.cdecl.}
  DosIndexCallback = proc(nimmodel: NimQAbstractItemModel, row: cint, column: cint, parent: DosQModelIndex, result: var DosQModelIndex) {.cdecl.}
  DosParentCallback = proc(nimmodel: NimQAbstractItemModel, child: DosQModelIndex, result: var DosQModelIndex) {.cdecl.}
  DosHasChildrenCallback = proc(nimmodel: NimQAbstractItemModel, parent: DosQModelIndex, result: var bool) {.cdecl.}
  DosCanFetchMoreCallback = proc(nimmodel: NimQAbstractItemModel, parent: DosQModelIndex, result: var bool) {.cdecl.}
  DosFetchMoreCallback = proc(nimmodel: NimQAbstractItemModel, parent: DosQModelIndex) {.cdecl.}

  DosQAbstractItemModelCallbacks = object
    rowCount: DosRowCountCallback
    columnCount: DosColumnCountCallback
    data: DosDataCallback
    setData: DosSetDataCallback
    roleNames: DosRoleNamesCallback
    flags: DosFlagsCallback
    headerData: DosHeaderDataCallback
    index: DosIndexCallback
    parent: DosParentCallback
    hasChildren: DosHasChildrenCallback
    canFetchMore: DosCanFetchMoreCallback
    fetchMore: DosFetchMoreCallback

  DosQObjectConnectLambdaCallback = proc(data: pointer, numArguments: cint, arguments: ptr DosQVariantArray) {.cdecl.}
  DosQMetaObjectInvokeMethodCallback = proc(data: pointer) {.cdecl.}

include ../../seaqt/private/notherside

# Conversion
proc resetToNil[T](x: var T) = reset(x)

proc isNil(x: DosQMetaObject): bool = x.pointer.isNil
proc isNil(x: DosQVariant): bool = x.pointer.isNil
proc isNil(x: DosQObject): bool = x.pointer.isNil
proc isNil(x: DosQQmlApplicationEngine): bool = x.pointer.isNil
proc isNil(x: DosQUrl): bool = x.pointer.isNil
proc isNil(x: DosQQuickView): bool = x.pointer.isNil
proc isNil(x: DosQHashIntByteArray): bool = x.pointer.isNil
proc isNil(x: DosQModelIndex): bool = x.pointer.isNil
proc isNil(x: DosQMetaObjectConnection): bool = x.pointer.isNil

# CharArray
proc dos_chararray_delete(str: cstring) =
  nos_chararray_delete(str)

# # QCoreApplication
proc dos_qcoreapplication_application_dir_path(): string =
  gen_qcoreapplication.QCoreApplication.applicationDirPath()

# # QApplication
var qapp: gen_qapplication.Qapplication

proc dos_qapplication_create() =
  qapp = gen_qapplication.QApplication.create()

proc dos_qapplication_exec() =
  discard gen_qapplication.QApplication.exec()

proc dos_qapplication_quit() =
  gen_qapplication.QApplication.quit()

proc dos_qapplication_delete() =
  delete(move(qapp))

# QGuiApplication
proc dos_qguiapplication_create() =
  debugEcho "dos_qguiapplication_create() "

proc dos_qguiapplication_exec() =
  discard gen_qguiapplication.QGuiApplication.exec()

proc dos_qguiapplication_quit() =
  gen_qcoreapplication.QCoreApplication.quit()

proc dos_qguiapplication_delete() =
  debugEcho "dos_qguiapplication_delete() "

# QQmlContext
proc dos_qqmlcontext_setcontextproperty(
    context: DosQQmlContext, propertyName: cstring, propertyValue: DosQVariant
) =
  context.setContextProperty($propertyName, propertyValue)

# QQmlApplicationEngine
proc dos_qqmlapplicationengine_create(): DosQQmlApplicationEngine =
  gen_qqmlapplicationEngine.QQmlApplicationEngine.create().take()

proc dos_qqmlapplicationengine_load(
    engine: DosQQmlApplicationEngine, filename: cstring
) =
  engine.load($filename)

proc dos_qqmlapplicationengine_load_url(
    engine: DosQQmlApplicationEngine, url: DosQUrl
) =
  engine.load(url)

proc dos_qqmlapplicationengine_load_data(engine: DosQQmlApplicationEngine, data: cstring) = engine.loadData(cast[seq[byte]]($data))
proc dos_qqmlapplicationengine_add_import_path(engine: DosQQmlApplicationEngine, path: cstring) = engine.addImportPath($path)
proc dos_qqmlapplicationengine_context(engine: DosQQmlApplicationEngine): DosQQmlContext = engine.rootContext().borrow()
proc dos_qqmlapplicationengine_delete(engine: DosQQmlApplicationEngine) = gen_qqmlapplicationengine.delete(gen_qqmlapplicationengine_types.QQmlApplicationEngine(engine))

# QVariant
proc dos_qvariant_create(): DosQVariant =
  gen_qvariant.QVariant.create().take()

proc dos_qvariant_create_int(value: cint): DosQVariant =
  gen_qvariant.QVariant.create2(value).take()

proc dos_qvariant_create_int(value: clonglong): DosQVariant =
  gen_qvariant.QVariant.create(value).take()

proc dos_qvariant_create_bool(value: bool): DosQVariant =
  gen_qvariant.QVariant.create(value).take()

proc dos_qvariant_create_string(value: cstring): DosQVariant =
  gen_qvariant.QVariant.create(value).take()

proc dos_qvariant_create_qobject(value: DosQObject): DosQVariant =
  gen_qvariant.QVariant.fromValue(value).take()

proc dos_qvariant_create_qvariant(value: DosQVariant): DosQVariant =
  gen_qvariant.QVariant.create(value).take()

proc dos_qvariant_create_float(value: cfloat): DosQVariant =
  gen_qvariant.QVariant.create(value).take()

proc dos_qvariant_create_double(value: cdouble): DosQVariant =
  gen_qvariant.QVariant.create(value).take()

proc dos_qvariant_delete(variant: DosQVariant) =
  variant.delete()

proc dos_qvariant_isnull(variant: DosQVariant): bool =
  variant.isNull()

proc dos_qvariant_toInt(variant: DosQVariant): cint =
  variant.toInt()

proc dos_qvariant_toBool(variant: DosQVariant): bool =
  variant.toBool()

proc dos_qvariant_toString(variant: DosQVariant): string =
  variant.toString()

proc dos_qvariant_toDouble(variant: DosQVariant): cdouble =
  variant.toDouble()

proc dos_qvariant_toFloat(variant: DosQVariant): cfloat =
  variant.toFloat()

proc dos_qvariant_setInt(variant: DosQVariant, value: cint) =
  variant.operatorAssign(gen_qvariant.QVariant.create2(value))

proc dos_qvariant_setBool(variant: DosQVariant, value: bool) =
  variant.operatorAssign(gen_qvariant.QVariant.create(value))

proc dos_qvariant_setString(variant: DosQVariant, value: cstring) =
  variant.operatorAssign(gen_qvariant.QVariant.create(value))

proc dos_qvariant_assign(leftValue: DosQVariant, rightValue: DosQVariant) =
  leftValue.operatorAssign(rightValue)

proc dos_qvariant_setFloat(variant: DosQVariant, value: cfloat) =
  variant.operatorAssign(dos_qvariant_create_float(value))

proc dos_qvariant_setDouble(variant: DosQVariant, value: cdouble) =
  variant.operatorAssign(dos_qvariant_create_double(value))

proc dos_qvariant_setQObject(variant: DosQVariant, value: DosQObject) =
  variant.operatorAssign(dos_qvariant_create_qobject(value))

# QMetaObject
proc dos_qmetaobject_create(superclassMetaObject: DosQMetaObject,
                            className: cstring,
                            signalDefinitions: ptr DosSignalDefinitions,
                            slotDefinitions: ptr DosSlotDefinitions,
                            propertyDefinitions: ptr DosPropertyDefinitions): DosQMetaObject =
  nos_qmetaobject_create(superclassMetaObject, className, signalDefinitions, slotDefinitions, propertyDefinitions)
proc dos_qmetaobject_delete(vptr: DosQMetaObject) =
  vptr.delete()

# QObject
proc dos_qobject_qmetaobject(): DosQMetaObject =
  var signalDefs: DosSignalDefinitions
  var slotDefs: DosSlotDefinitions
  var propDefs: DosPropertyDefinitions

  dos_qmetaobject_create(
    gen_qobject.QObject.staticMetaObject().borrow(),
    "DosQObject",
    addr signalDefs,
    addr slotDefs,
    addr propDefs,
  )
proc dos_qobject_create(nimobject: NimQObject, metaObject: DosQMetaObject, dosQObjectCallback: DosQObjectCallBack): DosQObject =
  let vtbl = new QObjectVtable
  gen_qobject.QObject.setupCallbacks(
    nimobject, metaObject, dosQObjectCallback, vtbl[], QObjectmetacall
  )

  gen_qobject.QObject.create(vtbl = vtbl).take()

proc dos_qobject_objectName(qobject: DosQObject): cstring =
  debugEcho "dos_qobject_objectName(qobject: DosQObject): cstring "

proc dos_qobject_setObjectName(qobject: DosQObject, name: cstring) =
  qobject.setObjectName($name)
proc dos_qobject_signal_emit(qobject: DosQObject, signalName: cstring, argumentsCount: cint, arguments: ptr DosQVariantArray) =
  let mo = qobject.metaObject()

  for i in 0 ..< mo.methodCount:
    let meth = mo.methodX(cint(i))
    if meth.parameterCount() == argumentsCount and signalName.toOpenArrayByte(0, len(signalName) - 1) == meth.name:

      var argv = newSeq[pointer](argumentsCount + 1)
      for i in 0 ..< argumentsCount:
        argv[i + 1] = arguments[i].constData()
      gen_qobjectdefs.QMetaObject.activate(qobject, cint i, addr argv[0])
      break

proc dos_qobject_connect_static(
    sender: DosQObject,
    senderFunc: cstring,
    receiver: DosQObject,
    receiverFunc: cstring,
    connectionType: cint,
): DosQMetaObjectConnection =
  receiver.connect(sender, senderFunc, receiverFunc).take()

proc dos_qobject_connect_lambda_static(
    sender: DosQObject,
    senderFunc: cstring,
    callback: DosQObjectConnectLambdaCallback,
    data: pointer,
    connectionType: cint,
): DosQMetaObjectConnection =
  nos_qobject_connect_lambda_with_context_static(sender, senderFunc, sender, callback, data, connectionType)
proc dos_qobject_connect_lambda_with_context_static(
    sender: DosQObject,
    senderFunc: cstring,
    context: DosQObject,
    callback: DosQObjectConnectLambdaCallback,
    data: pointer,
    connectionType: cint,
): DosQMetaObjectConnection =
  nos_qobject_connect_lambda_with_context_static(sender, senderFunc, context, callback, data, connectionType)

proc dos_qobject_disconnect_static(
    sender: DosQObject, senderFunc: cstring, receiver: DosQObject, receiverFunc: cstring
) =
  debugEcho "dos_qobject_disconnect_static"

proc dos_qobject_disconnect_with_connection_static(connection: DosQMetaObjectConnection) =
  discard QObject.disconnect(connection)

proc dos_qobject_delete(qobject: DosQObject) =
  qobject.delete()

proc dos_qobject_deleteLater(qobject: DosQObject) =
  qobject.deleteLater()

# QMetaObject::Connection
proc dos_qmetaobject_connection_delete(connection: DosQMetaObjectConnection) =
  connection.delete()

proc dos_qmetaobject_invoke_method(
    context: DosQObject,
    callback: DosQMetaObjectInvokeMethodCallback,
    callbackData: pointer,
    connectionType: cint,
): bool =
  debugEcho "dos_qmetaobject_invoke_method"

# QAbstractItemModel
proc dos_qabstractitemmodel_qmetaobject(): DosQMetaObject =
  var signalDefs: DosSignalDefinitions
  var slotDefs: DosSlotDefinitions
  var propDefs: DosPropertyDefinitions

  dos_qmetaobject_create(
    gen_qabstractitemmodel.QAbstractItemModel.staticMetaObject().borrow,
    "DosQAbstractItemModel",
    addr signalDefs,
    addr slotDefs,
    addr propDefs,
  )

# QUrl
proc dos_qurl_create(url: cstring, parsingMode: cint): DosQUrl =
  QUrl.create($url, parsingMode).take()

proc dos_qurl_delete(vptr: DosQUrl) =
  vptr.delete()

proc dos_qurl_to_string(vptr: DosQUrl): string =
  vptr.toString()

# QQuickView
proc dos_qquickview_create(): DosQQuickView =
  debugEcho "dos_qquickview_create(): DosQQuickView "

proc dos_qquickview_delete(view: DosQQuickView) =
  debugEcho "dos_qquickview_delete(view: DosQQuickView) "

proc dos_qquickview_show(view: DosQQuickView) =
  debugEcho "dos_qquickview_show(view: DosQQuickView) "

proc dos_qquickview_source(view: DosQQuickView): cstring =
  debugEcho "dos_qquickview_source(view: DosQQuickView): cstring "

proc dos_qquickview_set_source(view: DosQQuickView, filename: cstring) =
  debugEcho "dos_qquickview_set_source(view: DosQQuickView, filename: cstring) "

# QHash<int, QByteArra>
proc dos_qhash_int_qbytearray_create(): DosQHashIntByteArray =
  debugEcho "dos_qhash_int_qbytearray_create(): DosQHashIntByteArray "

proc dos_qhash_int_qbytearray_delete(qHash: DosQHashIntByteArray) =
  debugEcho "dos_qhash_int_qbytearray_delete(qHash: DosQHashIntByteArray) "

proc dos_qhash_int_qbytearray_insert(
    qHash: DosQHashIntByteArray, key: int, value: cstring
) =
  debugEcho "dos_qhash_int_qbytearray_insert(qHash: DosQHashIntByteArray, key: int, value: cstring) "

proc dos_qhash_int_qbytearray_value(qHash: DosQHashIntByteArray, key: int): cstring =
  debugEcho "dos_qhash_int_qbytearray_value(qHash: DosQHashIntByteArray, key: int): cstring "

# QModelIndex
proc dos_qmodelindex_create(): DosQModelIndex =
  gen_qabstractitemdelegate.QModelIndex.create().take()

proc dos_qmodelindex_create_qmodelindex(other: DosQModelIndex): DosQModelIndex =
  gen_qabstractitemdelegate.QModelIndex.create(other).take()

proc dos_qmodelindex_delete(modelIndex: DosQModelIndex) =
  modelIndex.delete()

proc dos_qmodelindex_row(modelIndex: DosQModelIndex): cint =
  modelIndex.row()

proc dos_qmodelindex_column(modelIndex: DosQModelIndex): cint =
  modelIndex.column()

proc dos_qmodelindex_isValid(modelIndex: DosQModelIndex): bool =
  modelIndex.isValid()

proc dos_qmodelindex_data(modelIndex: DosQModelIndex, role: cint): DosQVariant =
  modelIndex.data(role).borrow()

proc dos_qmodelindex_parent(modelIndex: DosQModelIndex): DosQModelIndex =
  modelIndex.parent().borrow()

proc dos_qmodelindex_child(
    modelIndex: DosQModelIndex, row: cint, column: cint
): DosQModelIndex =
  modelIndex.child(row, column).borrow()

proc dos_qmodelindex_sibling(
    modelIndex: DosQModelIndex, row: cint, column: cint
): DosQModelIndex =
  modelIndex.sibling(row, column).borrow()

proc dos_qmodelindex_assign(leftSide: var DosQModelIndex, rightSide: DosQModelIndex) =
  if not isNil(pointer(leftSide)): leftSide.delete()
  leftSide = gen_qabstractitemmodel.QModelIndex.create(rightSide).take()

proc dos_qmodelindex_internalPointer(modelIndex: DosQModelIndex): pointer =
  modelIndex.internalPointer()

# QAbstractItemModel
proc dos_qabstractitemmodel_create(modelPtr: NimQAbstractItemModel,
                                   metaObject: DosQMetaObject,
                                   qobjectCallback: DosQObjectCallBack,
                                   qaimCallbacks: DosQAbstractItemModelCallbacks): DosQAbstractItemModel =
  let vtbl = new QAbstractItemModelVTable
  gen_qabstractitemmodel.QAbstractItemModel.setupCallbacks(
    modelPtr, metaObject, qobjectCallback, vtbl[], QAbstractItemModelmetacall
  )
  gen_qabstractitemmodel.QAbstractItemModel.setupCallbacks(
    modelPtr, qaimCallbacks, vtbl[]
  )

  gen_qabstractitemmodel.QAbstractItemModel.create(vtbl).take()

proc dos_qabstractitemmodel_beginInsertRows(model: DosQAbstractItemModel,
                                            parentIndex: DosQModelIndex,
                                            first: cint,
                                            last: cint) =
  model.beginInsertRows(parentIndex, first, last)

proc dos_qabstractitemmodel_endInsertRows(model: DosQAbstractItemModel) =
  model.endInsertRows()

proc dos_qabstractitemmodel_beginRemoveRows(model: DosQAbstractItemModel,
                                            parentIndex: DosQModelIndex,
                                            first: cint,
                                            last: cint) =
  model.beginRemoveRows(parentIndex,first, last)

proc dos_qabstractitemmodel_endRemoveRows(model: DosQAbstractItemModel) =
  model.endRemoveRows()

proc dos_qabstractitemmodel_beginInsertColumns(model: DosQAbstractItemModel,
                                               parentIndex: DosQModelIndex,
                                               first: cint,
                                               last: cint) =
  model.beginInsertColumns(parentIndex, first, last)

proc dos_qabstractitemmodel_endInsertColumns(model: DosQAbstractItemModel) =
  model.endInsertColumns()

proc dos_qabstractitemmodel_beginRemoveColumns(model: DosQAbstractItemModel,
                                               parentIndex: DosQModelIndex,
                                               first: cint,
                                               last: cint) =
  model.beginRemoveColumns(parentIndex, first, last)

proc dos_qabstractitemmodel_endRemoveColumns(model: DosQAbstractItemModel) =
  model.endRemoveColumns()

proc dos_qabstractitemmodel_beginResetModel(model: DosQAbstractItemModel) =
  model.beginResetModel()

proc dos_qabstractitemmodel_endResetModel(model: DosQAbstractItemModel) =
  model.endResetModel()

proc dos_qabstractitemmodel_dataChanged(model: DosQAbstractItemModel,
                                        parentLeft: DosQModelIndex,
                                        bottomRight: DosQModelIndex,
                                        rolesArrayPtr: ptr cint,
                                        rolesArrayLength: cint) =
  model.dataChanged(parentLeft, bottomRight, @(cast[ptr UncheckedArray[cint]](rolesArrayPtr).toOpenArray(0, rolesArrayLength-1)) )

proc dos_qabstractitemmodel_createIndex(model: DosQAbstractItemModel, row: cint, column: cint, data: pointer): DosQModelIndex =
  model.createIndex(row, column, cast[uint](data)).take()

proc dos_qabstractitemmodel_hasChildren(model: DosQAbstractItemModel, parent: DosQModelIndex): bool =
  model.QAbstractItemModelhasChildren(parent)

proc dos_qabstractitemmodel_hasIndex(model: DosQAbstractItemModel, row: int, column: int, parent: DosQModelIndex): bool =
  model.hasIndex(cint row, cint column, parent)

proc dos_qabstractitemmodel_canFetchMore(model: DosQAbstractItemModel, parent: DosQModelIndex): bool =
  QAbstractItemModelcanFetchMore(model, parent)

proc dos_qabstractitemmodel_fetchMore(model: DosQAbstractItemModel, parent: DosQModelIndex) =
  QAbstractItemModelfetchMore(model, parent)

# QResource
proc dos_qresource_register(filename: cstring) =
  discard QResource.registerResource($filename)

# QDeclarative
proc dos_qdeclarative_qmlregistertype(value: ptr DosQmlRegisterType): cint =
  debugEcho "dos_qdeclarative_qmlregistertype(value: ptr DosQmlRegisterType): cint "

proc dos_qdeclarative_qmlregistersingletontype(value: ptr DosQmlRegisterType): cint =
  debugEcho "dos_qdeclarative_qmlregistersingletontype(value: ptr DosQmlRegisterType): cint "

# QAbstractListModel
proc dos_qabstractlistmodel_qmetaobject(): DosQMetaObject =
  var signalDefs: DosSignalDefinitions
  var slotDefs: DosSlotDefinitions
  var propDefs: DosPropertyDefinitions

  dos_qmetaobject_create(
    gen_qabstractitemmodel.QAbstractListModel.staticMetaObject().borrow(),
    "DosQAbstractListModel",
    addr signalDefs,
    addr slotDefs,
    addr propDefs,
  )

proc dos_qabstractlistmodel_create(modelPtr: NimQAbstractListModel,
                                   metaObject: DosQMetaObject,
                                   qobjectCallback: DosQObjectCallBack,
                                   qaimCallbacks: DosQAbstractItemModelCallbacks): DosQAbstractListModel =
  let vtbl = new QAbstractListModelVTable
  gen_qabstractitemmodel.QAbstractListModel.setupCallbacks(
    modelPtr, metaObject, qobjectCallback, vtbl[], QAbstractListModelmetacall
  )
  gen_qabstractitemmodel.QAbstractListModel.setupCallbacks(
    modelPtr, qaimCallbacks, vtbl[]
  )

  gen_qabstractitemmodel.QAbstractListModel.create(vtbl = vtbl).take()

proc dos_qabstractlistmodel_columnCount(modelPtr: DosQAbstractListModel, index: DosQModelIndex): cint =
  if index.isValid(): 1 else: 0

proc dos_qabstractlistmodel_parent(modelPtr: DosQAbstractListModel, index: DosQModelIndex): DosQModelIndex =
  QModelIndex.create().take()

proc dos_qabstractlistmodel_index(modelPtr: DosQAbstractListModel, row: cint, column: cint, parent: DosQModelIndex): DosQModelIndex =
  QAbstractListModel(modelPtr).QAbstractListModelindex(row, column, parent).take()

# QAbstractTableModel
proc dos_qabstracttablemodel_qmetaobject(): DosQMetaObject =
  var signalDefs: DosSignalDefinitions
  var slotDefs: DosSlotDefinitions
  var propDefs: DosPropertyDefinitions

  dos_qmetaobject_create(
    gen_qabstractitemmodel.QAbstractTableModel.staticMetaObject().borrow(),
    "DosQAbstractTableModel",
    addr signalDefs,
    addr slotDefs,
    addr propDefs,
  )

proc dos_qabstracttablemodel_create(modelPtr: NimQAbstractTableModel,
                                    metaObject: DosQMetaObject,
                                    qobjectCallback: DosQObjectCallBack,
                                    qaimCallbacks: DosQAbstractItemModelCallbacks): DosQAbstractTableModel=
  let vtbl = new QAbstractTableModelVTable
  gen_qabstractitemmodel.QAbstractTableModel.setupCallbacks(
    modelPtr, metaObject, qobjectCallback, vtbl[], QAbstractTableModelmetacall
  )
  gen_qabstractitemmodel.QAbstractTableModel.setupCallbacks(
    modelPtr, qaimCallbacks, vtbl[]
  )

  gen_qabstractitemmodel.QAbstractTableModel.create(vtbl = vtbl).take()

proc dos_qabstracttablemodel_parent(modelPtr: DosQAbstractTableModel, index: DosQModelIndex): DosQModelIndex =
  QModelIndex.create().take()

proc dos_qabstracttablemodel_index(modelPtr: DosQAbstractTableModel, row: cint, column: cint, parent: DosQModelIndex): DosQModelIndex =
  QAbstractTableModel(modelPtr).QAbstractTableModelindex(row, column, parent).take()

{.pop.}
