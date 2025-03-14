import ./metaobjectgen, seaqt/[qobject]

proc test() =
  let sigs =
    @[
      MethodDef.signalDef(
        "nameChanged", @[ParamDef(name: "firstName", metaType: QMetaTypeTypeEnum.QString)]
      )
    ]

  let slots =
    @[
      MethodDef.slotDef("name", QMetaTypeTypeEnum.QString, @[]),
      MethodDef.slotDef(
        "setName",
        QMetaTypeTypeEnum.Void,
        @[ParamDef(name: "name", metaType: QMetaTypeTypeEnum.QString)],
      ),
    ]
  let props =
    @[
      PropertyDef(
        name: "name", metaType: QMetaTypeTypeEnum.QString, readSlot: "name", writeSlot: "setName", notifySignal: "nameChanged"
      )
    ]

  let mo = genMetaObject(QObject.staticMetaObject, "Contact", sigs, slots, props)

  doAssert mo.className() == "Contact", $mo.className()
  doAssert mo.methodCount() - mo.methodOffset() == 3

  doAssert mo.indexOfSignal("nameChanged(QString)") >= 0
  doAssert mo.indexOfSlot("name()") >= 0
  doAssert mo.indexOfMethod("setName(QString)") >= 0
  doAssert mo.inherits(QObject.staticMetaObject)

test()
