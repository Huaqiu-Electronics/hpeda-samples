import QtQuick 2.15
import QtQuick 2.15 as Qq
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Framework.Ui.Dom 1.0

Item {
    id: chromeRoot
    property bool miniProgramChrome: true
    // hq_nav_bar_* 仅由根 QQmlContext 注入，勿在此声明同名 property，否则会遮蔽上下文导致首帧标题等恒为默认值。
    property string chromeNavTitle: miniProgramChrome ? hq_nav_bar_title : ""
    property color chromeNavFrontColor: miniProgramChrome ? hq_nav_bar_front_color : "#f5f5f5"
    property color chromeNavBackgroundColor: miniProgramChrome ? hq_nav_bar_background_color : "transparent"
    property bool chromeNavLoading: miniProgramChrome ? hq_nav_bar_loading : false
    property bool chromeNavCanBack: miniProgramChrome ? hq_nav_bar_stack_can_back : false
    property bool chromeNavShowHomeButton: miniProgramChrome ? hq_nav_bar_show_home_button : false
    property bool chromeNavHomeHidden: miniProgramChrome ? hq_nav_bar_home_hidden : true
    property int desiredTitleBarH: (typeof hq_mp_title_bar_height !== "undefined" && hq_mp_title_bar_height > 0) ? hq_mp_title_bar_height : 40
    property int mpNavBarH: miniProgramChrome ? desiredTitleBarH : 0
    // 页面 yaml window.width/height 经 hq_mp_window_width/height 注入；未声明（0）时回退默认 980×620。
    property int desiredW: (typeof hq_mp_window_width !== "undefined" && hq_mp_window_width > 0) ? hq_mp_window_width : 980
    property int desiredH: (typeof hq_mp_window_height !== "undefined" && hq_mp_window_height > 0) ? hq_mp_window_height : 620
    implicitWidth: desiredW
    implicitHeight: desiredH + mpNavBarH

    Rectangle {
        id: mpTitleBar
        visible: chromeRoot.miniProgramChrome
        height: mpNavBarH
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        color: chromeRoot.chromeNavBackgroundColor

        // 无边框壳的标题栏拖动：空白处按下交给系统移动；按钮各有 MouseArea 在上层不受影响。
        MouseArea {
            anchors.fill: parent
            onPressed: function() { $d.startChromeWindowDrag(); }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 6
            anchors.rightMargin: 6
            spacing: 4

            Item {
                visible: chromeRoot.miniProgramChrome && chromeRoot.chromeNavCanBack
                Layout.preferredWidth: visible ? 36 : 0
                Layout.fillHeight: true
                Qq.Text {
                    anchors.centerIn: parent
                    text: "\u2190"
                    color: chromeRoot.chromeNavFrontColor
                    font.pixelSize: 18
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: function() {
                        $d.postEvent("hq.mp.bar_action", "{\"action\":\"back\"}");
                    }
                }
            }

            Item {
                visible: chromeRoot.miniProgramChrome && chromeRoot.chromeNavShowHomeButton && !chromeRoot.chromeNavHomeHidden
                Layout.preferredWidth: visible ? 36 : 0
                Layout.fillHeight: true
                Qq.Text {
                    anchors.centerIn: parent
                    text: "\u2302"
                    color: chromeRoot.chromeNavFrontColor
                    font.pixelSize: 20
                    font.bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: function() {
                        $d.postEvent("hq.mp.bar_action", "{\"action\":\"home\"}");
                    }
                }
            }

            BusyIndicator {
                visible: chromeRoot.chromeNavLoading
                running: chromeRoot.chromeNavLoading
                Layout.preferredWidth: visible ? 22 : 0
                Layout.preferredHeight: 22
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Qq.Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: chromeRoot.chromeNavTitle
                    color: chromeRoot.chromeNavFrontColor
                    font.pixelSize: 14
                    elide: Text.ElideRight
                }
            }

            Item {
                Layout.preferredWidth: 30
                Layout.fillHeight: true
                Qq.Text {
                    anchors.centerIn: parent
                    text: "\u25a1"
                    color: chromeRoot.chromeNavFrontColor
                    font.pixelSize: 13
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: function() { $d.toggleChromeWindow(); }
                }
            }

            Item {
                Layout.preferredWidth: 30
                Layout.fillHeight: true
                Qq.Text {
                    anchors.centerIn: parent
                    text: "\u2715"
                    color: chromeRoot.chromeNavFrontColor
                    font.pixelSize: 12
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    // 关闭先经会话脚本决策（如 Hotkey 的 closeDialog 未保存确认），
                    // 由 hq.mp.bar_action 的 close 动作统一收口；不再直接 dismiss。
                    onClicked: function() { $d.postEvent("hq.mp.bar_action", "{\"action\":\"close\"}"); }
                }
            }
        }
    }

    Item {
        id: contentHost
        objectName: "pcb_plugin_modal_content_host"
        z: 100
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: chromeRoot.miniProgramChrome ? mpTitleBar.bottom : parent.top
Item {
  id: pcbHqMiniProgramRoot
  objectName: "pcb_miniprogram_container"
  readonly property bool __pcbMiniProgramContainer: true
  anchors.fill: parent
  property string __pcbRuntimePageBg: ""
  readonly property string __pcbHqPageBg: ($d.hqSyncRev, ((((typeof hq_s_hqss__vars__hq_upage_ubackground !== "undefined" ? hq_s_hqss__vars__hq_upage_ubackground : "") && String((typeof hq_s_hqss__vars__hq_upage_ubackground !== "undefined" ? hq_s_hqss__vars__hq_upage_ubackground : "")).indexOf("var(") !== 0) ? (typeof hq_s_hqss__vars__hq_upage_ubackground !== "undefined" ? hq_s_hqss__vars__hq_upage_ubackground : "") : ((typeof hq_s_hqss__vars__hq_ubg !== "undefined" ? hq_s_hqss__vars__hq_ubg : "") || "#ffffff"))))
  Rectangle {
    anchors.fill: parent
    color: pcbHqMiniProgramRoot.__pcbRuntimePageBg || pcbHqMiniProgramRoot.__pcbHqPageBg
    z: -1
  }
  ScrollView {
    id: pcbHqMiniProgramScroll
    anchors.fill: parent
    anchors.margins: (isNaN(parseFloat((typeof hq_s_hqss__vars__hqml_uspacing !== "undefined" ? hq_s_hqss__vars__hqml_uspacing : "") || "")) ? 0 : Math.max(0, parseFloat((typeof hq_s_hqss__vars__hqml_uspacing !== "undefined" ? hq_s_hqss__vars__hqml_uspacing : "") || "")))
    clip: true
    ScrollBar.vertical.policy: ScrollBar.AsNeeded
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    Column {
      id: pcbHqMiniProgramCol
      width: (pcbHqMiniProgramScroll && pcbHqMiniProgramScroll.width > 0) ? pcbHqMiniProgramScroll.width : implicitWidth
      spacing: (isNaN(parseFloat((typeof hq_s_hqss__vars__hqml_uspacing !== "undefined" ? hq_s_hqss__vars__hqml_uspacing : "") || "")) ? 10 : Math.max(0, parseFloat((typeof hq_s_hqss__vars__hqml_uspacing !== "undefined" ? hq_s_hqss__vars__hqml_uspacing : "") || "")))
          Column {
      readonly property string __hqmlNodeId: "0/0"
      readonly property string __hqmlTagName: "div"
            spacing: (isNaN(parseFloat((typeof hq_s_hqss__vars__hqml_uspacing !== "undefined" ? hq_s_hqss__vars__hqml_uspacing : "") || "")) ? 8 : Math.max(0, parseFloat((typeof hq_s_hqss__vars__hqml_uspacing !== "undefined" ? hq_s_hqss__vars__hqml_uspacing : "") || "")))
            width: (parent && parent.width > 0) ? parent.width : implicitWidth
                  Qq.Text {
                    readonly property string __hqmlNodeId: "0/0/0"
                    readonly property string __hqmlTagName: "p"
                    width: (parent && parent.width > 0) ? parent.width : implicitWidth
                    wrapMode: Qq.Text.WordWrap
                    textFormat: Qq.Text.PlainText
                    color: "#202020"
                    font.pixelSize: $e ? $e.fontsize : font.pixelSize
                    font.family: $e ? $e.font : font.family
                    font.bold: true
                    text: ($d.hqSyncRev, (((typeof hq_b_hero !== "undefined") ? String(!!hq_b_hero) : ((typeof hq_s_hero !== "undefined") ? String(hq_s_hero) : ""))))
                  }
                  Qq.Text {
                    readonly property string __hqmlNodeId: "0/0/1"
                    readonly property string __hqmlTagName: "p"
                    width: (parent && parent.width > 0) ? parent.width : implicitWidth
                    wrapMode: Qq.Text.WordWrap
                    textFormat: Qq.Text.PlainText
                    color: "#202020"
                    font.pixelSize: $e ? $e.fontsize : font.pixelSize
                    font.family: $e ? $e.font : font.family
                    text: ($d.hqSyncRev, (((typeof hq_b_blurb !== "undefined") ? String(!!hq_b_blurb) : ((typeof hq_s_blurb !== "undefined") ? String(hq_s_blurb) : ""))))
                  }
                            Rectangle {
                              radius: 6
                              color: "transparent"
                              width: (parent ? parent.width : implicitWidth)
                              height: (parent && parent.__pcbExplicitHeightHost === true) ? parent.height : implicitHeight
                              implicitHeight: __pcbBdrIn_4.implicitHeight
                              Item {
                                id: __pcbBdrIn_4
                                anchors.fill: parent
                                implicitHeight: childrenRect.height
                                Item {
                                  width: (parent ? parent.width : implicitWidth)
                                  implicitHeight: 14 + 0 + __pcbBoxPad_4.implicitHeight
                                  Item {
                                    id: __pcbBoxPad_4
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.leftMargin: 0
                                    anchors.rightMargin: 0
                                    anchors.topMargin: 14
                                    anchors.bottomMargin: 0
                                    implicitHeight: 10 + 10 + __pcbBoxIn_4.implicitHeight
                                    Item {
                                      id: __pcbBoxIn_4
                                      anchors.fill: parent
                                      anchors.leftMargin: 10
                                      anchors.rightMargin: 10
                                      anchors.topMargin: 10
                                      anchors.bottomMargin: 10
                                      implicitHeight: childrenRect.height
                                      Column {
                              readonly property string __hqmlNodeId: "0/0/2"
                              readonly property string __hqmlTagName: "div"
                                        spacing: (isNaN(parseFloat((typeof hq_s_hqss__vars__hqml_uspacing !== "undefined" ? hq_s_hqss__vars__hqml_uspacing : "") || "")) ? 8 : Math.max(0, parseFloat((typeof hq_s_hqss__vars__hqml_uspacing !== "undefined" ? hq_s_hqss__vars__hqml_uspacing : "") || "")))
                                        width: (parent && parent.width > 0) ? parent.width : implicitWidth
                                                  Qq.Text {
                                                    readonly property string __hqmlNodeId: "0/0/2/0"
                                                    readonly property string __hqmlTagName: "p"
                                                    width: (parent && parent.width > 0) ? parent.width : implicitWidth
                                                    wrapMode: Qq.Text.WordWrap
                                                    textFormat: Qq.Text.PlainText
                                                    color: "#202020"
                                                    font.pixelSize: $e ? $e.fontsize : font.pixelSize
                                                    font.family: $e ? $e.font : font.family
                                                    font.bold: true
                                                    text: ($d.hqSyncRev, ("工程路径"))
                                                  }
                                                  Qq.Text {
                                                    readonly property string __hqmlNodeId: "0/0/2/1"
                                                    readonly property string __hqmlTagName: "p"
                                                    width: (parent && parent.width > 0) ? parent.width : implicitWidth
                                                    wrapMode: Qq.Text.WordWrap
                                                    textFormat: Qq.Text.PlainText
                                                    color: "#202020"
                                                    font.pixelSize: $e ? $e.fontsize : font.pixelSize
                                                    font.family: "monospace"
                                                    text: ($d.hqSyncRev, (((typeof hq_b_boardPath !== "undefined") ? String(!!hq_b_boardPath) : ((typeof hq_s_boardPath !== "undefined") ? String(hq_s_boardPath) : ""))))
                                                  }
                                                                Item {
                                                                  width: (parent ? parent.width : implicitWidth)
                                                                  implicitHeight: 10 + 0 + __pcbBoxPad_7.implicitHeight
                                                                  Item {
                                                                    id: __pcbBoxPad_7
                                                                    anchors.left: parent.left
                                                                    anchors.right: parent.right
                                                                    anchors.top: parent.top
                                                                    anchors.leftMargin: 0
                                                                    anchors.rightMargin: 0
                                                                    anchors.topMargin: 10
                                                                    anchors.bottomMargin: 0
                                                                    implicitHeight: 0 + 0 + __pcbBoxIn_7.implicitHeight
                                                                    Item {
                                                                      id: __pcbBoxIn_7
                                                                      anchors.fill: parent
                                                                      anchors.leftMargin: 0
                                                                      anchors.rightMargin: 0
                                                                      anchors.topMargin: 0
                                                                      anchors.bottomMargin: 0
                                                                      implicitHeight: childrenRect.height
                                                                      RowLayout {
                                                          readonly property string __hqmlNodeId: "0/0/2/2"
                                                          readonly property string __hqmlTagName: "div"
                                                                        spacing: 8
                                                                        width: (parent ? parent.width : implicitWidth)
                                                                                      Item {
                                                                                        Layout.fillHeight: true
                                                                                        Layout.fillWidth: false
                                                                                        implicitWidth: (children.length > 0 ? children[0].implicitWidth : 0)
                                                                                        implicitHeight: Math.max(childrenRect.height, children.length > 0 ? children[0].implicitHeight : 0)
                                                                                      Item {
                                                                                        readonly property string __hqmlNodeId: "0/0/2/2/0"
                                                                                        readonly property string __hqmlTagName: "button"
                                                                                        id: pcbHqBtn_8_0_0_2_2_0
                                                                                        enabled: true
                                                                                        opacity: enabled ? 1.0 : 0.55
                                                                                        implicitWidth: Math.ceil(__pcbHqTapLbl_1.contentWidth) + 12
                                                                                        width: (parent && parent.width > 0) ? parent.width : implicitWidth
                                                                                        implicitHeight: Math.max(1, __pcbHqTapLbl_1.implicitHeight + 16)
                                                                                        height: (parent && parent.__pcbExplicitHeightHost === true) ? parent.height : implicitHeight
                                                                                        readonly property string __pcbHqBtnFg: "#ffffff"
                                                                                        readonly property string __pcbHqBtnBg: "#1d4ed8"
                                                                                        Rectangle {
                                                                                          z: -1
                                                                                          anchors.fill: parent
                                                                                          radius: 6
                                                                                          color: parent.__pcbHqBtnBg
                                                                                        }
                                                                                        Text {
                                                                                          id: __pcbHqTapLbl_1
                                                                                          text: ($d.hqSyncRev, ("Browse…"))
                                                                                          x: 6
                                                                                          y: 8
                                                                                          width: Math.max(0, parent.width - 12)
                                                                                          height: Math.max(0, parent.height - 16)
                                                                                          font.family: $e ? $e.font : font.family
                                                                                          font.pixelSize: $e ? $e.fontsize : font.pixelSize
                                                                                          color: parent.__pcbHqBtnFg
                                                                                          horizontalAlignment: Text.AlignHCenter
                                                                                          verticalAlignment: Text.AlignVCenter
                                                                                          wrapMode: Text.NoWrap
                                                                                          elide: Text.ElideRight
                                                                                        }
                                                                                        Rectangle {
                                                                                          anchors.fill: parent
                                                                                          color: "transparent"
                                                                                          z: 2
                                                                                          TapHandler {
                                                                                            gesturePolicy: TapHandler.DragThreshold
                                                                                            onTapped: function() { $d.postEvent("hq.event", JSON.stringify({ handler: "browseBoard" })); }
                                                                                          }
                                                                                          HoverHandler {
                                                                                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchScreen | PointerDevice.TouchPad
                                                                                            cursorShape: Qt.PointingHandCursor
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                      }
                                                                                      Item {
                                                                                        Layout.fillHeight: true
                                                                                        Layout.fillWidth: false
                                                                                        implicitWidth: (children.length > 0 ? children[0].implicitWidth : 0)
                                                                                        implicitHeight: Math.max(childrenRect.height, children.length > 0 ? children[0].implicitHeight : 0)
                                                                                      Item {
                                                                                        readonly property string __hqmlNodeId: "0/0/2/2/1"
                                                                                        readonly property string __hqmlTagName: "button"
                                                                                        id: pcbHqBtn_9_0_0_2_2_1
                                                                                        enabled: true
                                                                                        opacity: enabled ? 1.0 : 0.55
                                                                                        implicitWidth: Math.ceil(__pcbHqTapLbl_2.contentWidth) + 12
                                                                                        width: (parent && parent.width > 0) ? parent.width : implicitWidth
                                                                                        implicitHeight: Math.max(1, __pcbHqTapLbl_2.implicitHeight + 16)
                                                                                        height: (parent && parent.__pcbExplicitHeightHost === true) ? parent.height : implicitHeight
                                                                                        readonly property string __pcbHqBtnFg: "#ffffff"
                                                                                        readonly property string __pcbHqBtnBg: "#64748b"
                                                                                        Rectangle {
                                                                                          z: -1
                                                                                          anchors.fill: parent
                                                                                          radius: 6
                                                                                          color: parent.__pcbHqBtnBg
                                                                                        }
                                                                                        Text {
                                                                                          id: __pcbHqTapLbl_2
                                                                                          text: ($d.hqSyncRev, ("Clear"))
                                                                                          x: 6
                                                                                          y: 8
                                                                                          width: Math.max(0, parent.width - 12)
                                                                                          height: Math.max(0, parent.height - 16)
                                                                                          font.family: $e ? $e.font : font.family
                                                                                          font.pixelSize: $e ? $e.fontsize : font.pixelSize
                                                                                          color: parent.__pcbHqBtnFg
                                                                                          horizontalAlignment: Text.AlignHCenter
                                                                                          verticalAlignment: Text.AlignVCenter
                                                                                          wrapMode: Text.NoWrap
                                                                                          elide: Text.ElideRight
                                                                                        }
                                                                                        Rectangle {
                                                                                          anchors.fill: parent
                                                                                          color: "transparent"
                                                                                          z: 2
                                                                                          TapHandler {
                                                                                            gesturePolicy: TapHandler.DragThreshold
                                                                                            onTapped: function() { $d.postEvent("hq.event", JSON.stringify({ handler: "clearPath" })); }
                                                                                          }
                                                                                          HoverHandler {
                                                                                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchScreen | PointerDevice.TouchPad
                                                                                            cursorShape: Qt.PointingHandCursor
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                      }
                                                                                      Item {
                                                                                        Layout.fillWidth: true
                                                                                        Layout.minimumWidth: 0
                                                                                        Layout.horizontalStretchFactor: 1
                                                                                      }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            Rectangle {
                              radius: 6
                              color: "transparent"
                              width: (parent ? parent.width : implicitWidth)
                              height: (parent && parent.__pcbExplicitHeightHost === true) ? parent.height : implicitHeight
                              implicitHeight: __pcbBdrIn_10.implicitHeight
                              Item {
                                id: __pcbBdrIn_10
                                anchors.fill: parent
                                implicitHeight: childrenRect.height
                                Item {
                                  width: (parent ? parent.width : implicitWidth)
                                  implicitHeight: 14 + 0 + __pcbBoxPad_10.implicitHeight
                                  Item {
                                    id: __pcbBoxPad_10
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.leftMargin: 0
                                    anchors.rightMargin: 0
                                    anchors.topMargin: 14
                                    anchors.bottomMargin: 0
                                    implicitHeight: 10 + 10 + __pcbBoxIn_10.implicitHeight
                                    Item {
                                      id: __pcbBoxIn_10
                                      anchors.fill: parent
                                      anchors.leftMargin: 10
                                      anchors.rightMargin: 10
                                      anchors.topMargin: 10
                                      anchors.bottomMargin: 10
                                      implicitHeight: childrenRect.height
                                      Column {
                              readonly property string __hqmlNodeId: "0/0/3"
                              readonly property string __hqmlTagName: "div"
                                        spacing: (isNaN(parseFloat((typeof hq_s_hqss__vars__hqml_uspacing !== "undefined" ? hq_s_hqss__vars__hqml_uspacing : "") || "")) ? 8 : Math.max(0, parseFloat((typeof hq_s_hqss__vars__hqml_uspacing !== "undefined" ? hq_s_hqss__vars__hqml_uspacing : "") || "")))
                                        width: (parent && parent.width > 0) ? parent.width : implicitWidth
                                                                Item {
                                                                  width: (parent ? parent.width : implicitWidth)
                                                                  implicitHeight: 10 + 0 + __pcbBoxPad_11.implicitHeight
                                                                  Item {
                                                                    id: __pcbBoxPad_11
                                                                    anchors.left: parent.left
                                                                    anchors.right: parent.right
                                                                    anchors.top: parent.top
                                                                    anchors.leftMargin: 0
                                                                    anchors.rightMargin: 0
                                                                    anchors.topMargin: 10
                                                                    anchors.bottomMargin: 0
                                                                    implicitHeight: 0 + 0 + __pcbBoxIn_11.implicitHeight
                                                                    Item {
                                                                      id: __pcbBoxIn_11
                                                                      anchors.fill: parent
                                                                      anchors.leftMargin: 0
                                                                      anchors.rightMargin: 0
                                                                      anchors.topMargin: 0
                                                                      anchors.bottomMargin: 0
                                                                      implicitHeight: childrenRect.height
                                                                      RowLayout {
                                                          readonly property string __hqmlNodeId: "0/0/3/0"
                                                          readonly property string __hqmlTagName: "div"
                                                                        spacing: 8
                                                                        width: (parent ? parent.width : implicitWidth)
                                                                                      Item {
                                                                                        Layout.fillHeight: true
                                                                                        Layout.fillWidth: false
                                                                                        implicitWidth: (children.length > 0 ? children[0].implicitWidth : 0)
                                                                                        implicitHeight: Math.max(childrenRect.height, children.length > 0 ? children[0].implicitHeight : 0)
                                                                                      Item {
                                                                                        readonly property string __hqmlNodeId: "0/0/3/0/0"
                                                                                        readonly property string __hqmlTagName: "button"
                                                                                        id: pcbHqBtn_12_0_0_3_0_0
                                                                                        enabled: true
                                                                                        opacity: enabled ? 1.0 : 0.55
                                                                                        implicitWidth: Math.ceil(__pcbHqTapLbl_3.contentWidth) + 12
                                                                                        width: (parent && parent.width > 0) ? parent.width : implicitWidth
                                                                                        implicitHeight: Math.max(1, __pcbHqTapLbl_3.implicitHeight + 16)
                                                                                        height: (parent && parent.__pcbExplicitHeightHost === true) ? parent.height : implicitHeight
                                                                                        readonly property string __pcbHqBtnFg: "#ffffff"
                                                                                        readonly property string __pcbHqBtnBg: "#1d4ed8"
                                                                                        Rectangle {
                                                                                          z: -1
                                                                                          anchors.fill: parent
                                                                                          radius: 6
                                                                                          color: parent.__pcbHqBtnBg
                                                                                        }
                                                                                        Text {
                                                                                          id: __pcbHqTapLbl_3
                                                                                          text: ($d.hqSyncRev, ("Open"))
                                                                                          x: 6
                                                                                          y: 8
                                                                                          width: Math.max(0, parent.width - 12)
                                                                                          height: Math.max(0, parent.height - 16)
                                                                                          font.family: $e ? $e.font : font.family
                                                                                          font.pixelSize: $e ? $e.fontsize : font.pixelSize
                                                                                          color: parent.__pcbHqBtnFg
                                                                                          horizontalAlignment: Text.AlignHCenter
                                                                                          verticalAlignment: Text.AlignVCenter
                                                                                          wrapMode: Text.NoWrap
                                                                                          elide: Text.ElideRight
                                                                                        }
                                                                                        Rectangle {
                                                                                          anchors.fill: parent
                                                                                          color: "transparent"
                                                                                          z: 2
                                                                                          TapHandler {
                                                                                            gesturePolicy: TapHandler.DragThreshold
                                                                                            onTapped: function() { $d.postEvent("hq.event", JSON.stringify({ handler: "confirmOpen" })); }
                                                                                          }
                                                                                          HoverHandler {
                                                                                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchScreen | PointerDevice.TouchPad
                                                                                            cursorShape: Qt.PointingHandCursor
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                      }
                                                                                      Item {
                                                                                        Layout.fillHeight: true
                                                                                        Layout.fillWidth: false
                                                                                        implicitWidth: (children.length > 0 ? children[0].implicitWidth : 0)
                                                                                        implicitHeight: Math.max(childrenRect.height, children.length > 0 ? children[0].implicitHeight : 0)
                                                                                      Item {
                                                                                        readonly property string __hqmlNodeId: "0/0/3/0/1"
                                                                                        readonly property string __hqmlTagName: "button"
                                                                                        id: pcbHqBtn_13_0_0_3_0_1
                                                                                        enabled: true
                                                                                        opacity: enabled ? 1.0 : 0.55
                                                                                        implicitWidth: Math.ceil(__pcbHqTapLbl_4.contentWidth) + 12
                                                                                        width: (parent && parent.width > 0) ? parent.width : implicitWidth
                                                                                        implicitHeight: Math.max(1, __pcbHqTapLbl_4.implicitHeight + 16)
                                                                                        height: (parent && parent.__pcbExplicitHeightHost === true) ? parent.height : implicitHeight
                                                                                        readonly property string __pcbHqBtnFg: "#ffffff"
                                                                                        readonly property string __pcbHqBtnBg: "#64748b"
                                                                                        Rectangle {
                                                                                          z: -1
                                                                                          anchors.fill: parent
                                                                                          radius: 6
                                                                                          color: parent.__pcbHqBtnBg
                                                                                        }
                                                                                        Text {
                                                                                          id: __pcbHqTapLbl_4
                                                                                          text: ($d.hqSyncRev, ("Cancel"))
                                                                                          x: 6
                                                                                          y: 8
                                                                                          width: Math.max(0, parent.width - 12)
                                                                                          height: Math.max(0, parent.height - 16)
                                                                                          font.family: $e ? $e.font : font.family
                                                                                          font.pixelSize: $e ? $e.fontsize : font.pixelSize
                                                                                          color: parent.__pcbHqBtnFg
                                                                                          horizontalAlignment: Text.AlignHCenter
                                                                                          verticalAlignment: Text.AlignVCenter
                                                                                          wrapMode: Text.NoWrap
                                                                                          elide: Text.ElideRight
                                                                                        }
                                                                                        Rectangle {
                                                                                          anchors.fill: parent
                                                                                          color: "transparent"
                                                                                          z: 2
                                                                                          TapHandler {
                                                                                            gesturePolicy: TapHandler.DragThreshold
                                                                                            onTapped: function() { $d.postEvent("hq.event", JSON.stringify({ handler: "cancelClose" })); }
                                                                                          }
                                                                                          HoverHandler {
                                                                                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchScreen | PointerDevice.TouchPad
                                                                                            cursorShape: Qt.PointingHandCursor
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                      }
                                                                                      Item {
                                                                                        Layout.fillWidth: true
                                                                                        Layout.minimumWidth: 0
                                                                                        Layout.horizontalStretchFactor: 1
                                                                                      }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                  Qq.Text {
                                                    readonly property string __hqmlNodeId: "0/0/3/1"
                                                    readonly property string __hqmlTagName: "p"
                                                    width: (parent && parent.width > 0) ? parent.width : implicitWidth
                                                    wrapMode: Qq.Text.WordWrap
                                                    textFormat: Qq.Text.PlainText
                                                    color: "#202020"
                                                    font.pixelSize: $e ? $e.fontsize : font.pixelSize
                                                    font.family: $e ? $e.font : font.family
                                                    text: ($d.hqSyncRev, (((typeof hq_b_status !== "undefined") ? String(!!hq_b_status) : ((typeof hq_s_status !== "undefined") ? String(hq_s_status) : ""))))
                                                  }
                                      }
                                    }
                                  }
                                }
                              }
                            }
          }

    }
  }
}
    }

    Item {
        id: mpBlockerHost
        anchors.fill: contentHost
        z: 2000
        clip: true
        visible: hq_mp_modal_visible || hq_mp_sheet_visible || (hq_mp_loading_visible && hq_mp_loading_mask) || (hq_mp_toast_visible && hq_mp_toast_mask)
        enabled: visible
        Rectangle {
            anchors.fill: parent
            visible: hq_mp_toast_mask && hq_mp_toast_visible
            color: "#80000000"
        }
        Rectangle {
            anchors.fill: parent
            visible: hq_mp_loading_visible && hq_mp_loading_mask
            color: "#66000000"
        }
        ColumnLayout {
            anchors.centerIn: parent
            visible: hq_mp_loading_visible && hq_mp_loading_mask
            spacing: 10
            BusyIndicator {
                running: hq_mp_loading_visible && hq_mp_loading_mask
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
            }
            Qq.Text {
                text: hq_mp_loading_title
                color: "#ffffff"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
            }
        }
        Item {
            anchors.fill: parent
            visible: hq_mp_modal_visible
            Rectangle {
                anchors.fill: parent
                color: "#99000000"
            }
            Rectangle {
                anchors.centerIn: parent
                width: Math.min(420, parent.width - 32)
                implicitHeight: modalBody.implicitHeight + 32
                color: "#f5f5f5"
                radius: 8
                ColumnLayout {
                    id: modalBody
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10
                    Qq.Text {
                        text: hq_mp_modal_title
                        font.pixelSize: 16
                        font.bold: true
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                    Qq.Text {
                        text: hq_mp_modal_content
                        font.pixelSize: 14
                        wrapMode: Text.Wrap
                        color: "#333333"
                        Layout.fillWidth: true
                    }
                    RowLayout {
                        Layout.alignment: Qt.AlignRight
                        spacing: 8
                        Button {
                            visible: hq_mp_modal_show_cancel
                            text: hq_mp_modal_cancel_text
                            onClicked: function() {
                                $d.postEvent("hq.mp.interaction", JSON.stringify({kind:"modal", action:"cancel", sid: hq_mp_modal_session_id}));
                            }
                        }
                        Button {
                            text: hq_mp_modal_confirm_text
                            onClicked: function() {
                                $d.postEvent("hq.mp.interaction", JSON.stringify({kind:"modal", action:"confirm", sid: hq_mp_modal_session_id}));
                            }
                        }
                    }
                }
            }
        }
        Item {
            anchors.fill: parent
            visible: hq_mp_sheet_visible
            Rectangle {
                anchors.fill: parent
                color: "#99000000"
                MouseArea {
                    anchors.fill: parent
                    onClicked: function() {
                        $d.postEvent("hq.mp.interaction", JSON.stringify({kind:"sheet", cancel:true, sid: hq_mp_sheet_session_id}));
                    }
                }
            }
            Column {
                id: sheetCol
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                width: parent.width
                spacing: 0
                z: 1
                Repeater {
                    model: JSON.parse(hq_mp_sheet_items_json || "[]")
                    delegate: Rectangle {
                        width: sheetCol.width
                        height: 48
                        color: sheetMouse.pressed ? "#e0e0e0" : "#fafafa"
                        border.width: 1
                        border.color: "#dddddd"
                        Qq.Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 15
                        }
                        MouseArea {
                            id: sheetMouse
                            anchors.fill: parent
                            onClicked: function() {
                                $d.postEvent("hq.mp.interaction", JSON.stringify({kind:"sheet", tapIndex: index, sid: hq_mp_sheet_session_id}));
                            }
                        }
                    }
                }
                Rectangle {
                    width: sheetCol.width
                    height: 48
                    color: cancelMouse.pressed ? "#e8e8e8" : "#f0f0f0"
                    border.width: 1
                    border.color: "#dddddd"
                    Qq.Text {
                        anchors.centerIn: parent
                        text: hq_mp_sheet_cancel_text
                        font.pixelSize: 15
                    }
                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        onClicked: function() {
                            $d.postEvent("hq.mp.interaction", JSON.stringify({kind:"sheet", cancel:true, sid: hq_mp_sheet_session_id}));
                        }
                    }
                }
            }
        }
    }
    ColumnLayout {
        anchors.centerIn: contentHost
        visible: hq_mp_loading_visible && !hq_mp_loading_mask
        enabled: false
        z: 2000
        spacing: 10
        BusyIndicator {
            running: hq_mp_loading_visible && !hq_mp_loading_mask
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
        }
        Qq.Text {
            text: hq_mp_loading_title
            color: "#ffffff"
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }
    }
    Rectangle {
        visible: hq_mp_toast_visible
        enabled: false
        z: 2001
        color: "#cc333333"
        radius: 8
        anchors.horizontalCenter: contentHost.horizontalCenter
        anchors.bottom: contentHost.bottom
        anchors.bottomMargin: 48
        width: Math.min(contentHost.width - 32, 420)
        height: mpToastRow.implicitHeight + 16
        RowLayout {
            id: mpToastRow
            anchors.centerIn: parent
            spacing: 8
            BusyIndicator {
                visible: hq_mp_toast_icon === "loading"
                running: visible
                Layout.preferredWidth: visible ? 22 : 0
                Layout.preferredHeight: 22
            }
            Qq.Text {
                visible: hq_mp_toast_icon !== "loading" && hq_mp_toast_icon !== "none" && hq_mp_toast_icon !== ""
                text: hq_mp_toast_icon === "success" ? "\u2713" : (hq_mp_toast_icon === "error" ? "\u2717" : "")
                color: "#e8e8e8"
                font.pixelSize: 16
            }
            Qq.Text {
                id: mpToastText
                text: hq_mp_toast_title
                color: "#ffffff"
                font.pixelSize: 14
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
        }
    }

    Rectangle {
        id: chromeBtn
        width: 28
        height: 22
        radius: 4
        anchors.top: parent.top
        anchors.right: closeBtn.left
        anchors.margins: 10
        anchors.rightMargin: 8
        color: "#000000"
        opacity: 0.25
        border.width: 1
        border.color: "#ffffff"
        visible: !chromeRoot.miniProgramChrome

        Qq.Text {
            anchors.centerIn: parent
            text: "▢"
            color: "#ffffff"
            font.pixelSize: 14
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: chromeBtn.opacity = 0.45
            onExited: chromeBtn.opacity = 0.25
            onClicked: function() { $d.toggleChromeWindow(); }
        }
    }

    Rectangle {
        id: closeBtn
        width: 28
        height: 22
        radius: 4
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        color: "#000000"
        opacity: 0.25
        border.width: 1
        border.color: "#ffffff"
        visible: !chromeRoot.miniProgramChrome

        Qq.Text {
            anchors.centerIn: parent
            text: "✕"
            color: "#ffffff"
            font.pixelSize: 14
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: closeBtn.opacity = 0.45
            onExited: closeBtn.opacity = 0.25
            onClicked: function() { $d.dismissChrome(); }
        }
    }
}
