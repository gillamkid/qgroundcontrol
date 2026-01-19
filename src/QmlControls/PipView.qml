import QtQuick
import QtQuick.Window
import QtQuick.Shapes

import QGroundControl
import QGroundControl.Controls

Item {
    id:         _root
    width:      pipResizeButton.x + pipResizeButton.width
    height:     width * (9/16)
    visible:    item2 && item2.pipState !== item2.pipState.window && show

    property var    item1:                  null    // Required
    property var    item2:                  null    // Optional, may come and go
    property string item1IsFullSettingsKey          // Settings key to save whether item1 was saved in full mode
    property bool   show:                   true

    readonly property string _pipExpandedSettingsKey: "IsPIPVisible"

    property var    _fullItem
    property var    _pipOrWindowItem
    property alias  _windowContentItem: window.contentItem
    property alias  _pipContentItem:    pipContent
    property bool   _isExpanded:        true
    property real   _maxSize:           0.75                // Percentage of parent control size
    property real   _minSize:           0.10
    property bool   _componentComplete: false

    property real minVideoWidth: ScreenTools.defaultFontPixelWidth * 6 * 3
    property real maxVideoWidth: _root.parent.width/2 - pipResizeButton.width

    Component.onCompleted: {
        _initForItems()
        _componentComplete = true
    }

    onItem2Changed: _initForItems()

    function showWindow() {
        window.width = _root.width
        window.height = _root.height
        window.show()
    }

    function _initForItems() {
        var item1IsFull = QGroundControl.loadBoolGlobalSetting(item1IsFullSettingsKey, true)
        if (item1 && item2) {
            item1.pipState.state = item1IsFull ? item1.pipState.fullState : item1.pipState.pipState
            item2.pipState.state = item1IsFull ? item2.pipState.pipState : item2.pipState.fullState
            _fullItem = item1IsFull ? item1 : item2
            _pipOrWindowItem = item1IsFull ? item2 : item1
        } else {
            item1.pipState.state = item1.pipState.fullState
            _fullItem = item1
            _pipOrWindowItem = null
        }
        _setPipIsExpanded(QGroundControl.loadBoolGlobalSetting(_pipExpandedSettingsKey, true))
    }

    function _swapPip() {
        var item1IsFull = false
        if (item1.pipState.state === item1.pipState.fullState) {
            item1.pipState.state = item1.pipState.pipState
            item2.pipState.state = item2.pipState.fullState
            _fullItem = item2
            _pipOrWindowItem = item1
            item1IsFull = false
        } else {
            item1.pipState.state = item1.pipState.fullState
            item2.pipState.state = item2.pipState.pipState
            _fullItem = item1
            _pipOrWindowItem = item2
            item1IsFull = true
        }
        QGroundControl.saveBoolGlobalSetting(item1IsFullSettingsKey, item1IsFull)
    }

    function _setPipIsExpanded(isExpanded) {
        QGroundControl.saveBoolGlobalSetting(_pipExpandedSettingsKey, isExpanded)
        _isExpanded = isExpanded
    }

    Window {
        id:         window
        visible:    false
        onClosing: {
            var item = contentItem.children[0]
            if (item) {
                item.pipState.windowAboutToClose()
                item.pipState.state = item.pipState.pipState
            }
        }
    }

    Item {
        id:             pipContent
        anchors.fill:   parent
        visible:        _isExpanded
        clip:           true
    }

    MouseArea {
        id:             pipMouseArea
        anchors.fill:   parent
        enabled:        _isExpanded
        preventStealing: true
        hoverEnabled:   true
        onClicked:      _swapPip()
    }

    property real dashOffsetValue: 0
    NumberAnimation on dashOffsetValue {
        from: 0
        to: 14
        duration: 800
        loops: Animation.Infinite
        running: true
    }
    CornerButton {
        id:                 pipResizeButton
        source:             "/qmlimages/pipResize.svg"
        anchors.top:        parent.top

        // MouseArea to drag in order to resize the PiP area
        drag.target:        pipResizeButton
        drag.axis:          Drag.XAxis
        drag.minimumX:      minVideoWidth - pipResizeButton.width
        drag.maximumX:      maxVideoWidth - pipResizeButton.height
        Drag.active:        drag.active
        anchors.left:       pressed ? undefined : parent.left
        anchors.leftMargin: preferredVideoSize.width < maxVideoWidth
                                ? (preferredVideoSize.width - width) : drag.maximumX
        cursorShape:        pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        
        // When doing the drag, if the mouse leaves pipResizeButton the ClosedHandCursor
        // dissappears. This makes so that doesn't happen 
        MouseArea {
            id:             dragInProgressOverlay
            parent:         Overlay.overlay
            anchors.fill:   parent
            visible:        pipResizeButton.pressed
            cursorShape:    Qt.ClosedHandCursor

            Item {
                id: shapeContainer
                x: _root.anchors.leftMargin + _root.minVideoWidth
                y: dragInProgressOverlay.height - _root.anchors.bottomMargin +- height - _root.minVideoWidth * 9/16
                width: maxVideoWidth - minVideoWidth
                height: width * 9/16

                Item {
                    id: videoCorner
                    x: _root.width - _root.minVideoWidth
                    y: shapeContainer.height - x * 9/16
                }

                Line2 { 
                    x: 1
                    y: 1
                    color: "#cc000000"
                 }
                Line2 { 
                    x: -1
                    y: -1
                    color: "#ccFFFFFF"
                 }
            
                component Line2: Shape {
                    id: shape
                    property color color: "white"
                    width: parent.width
                    height: parent.height

                    ShapePath {
                        strokeWidth: 2
                        strokeColor: shape.color
                        fillColor: "transparent"

                        strokeStyle: ShapePath.DashLine
                        dashPattern: [8, 6]
                        dashOffset: dashOffsetValue

                        PathMove { 
                            x: 0
                            y: shapeContainer.height
                        }
                        PathLine { 
                            x: videoCorner.x
                            y: videoCorner.y
                        }

                    }
                }

                Line { 
                    x: 1
                    y: 1
                    color: "#cc000000"
                 }
                Line { 
                    x: -1
                    y: -1
                    color: "#ccFFFFFF"
                 }

                component Line: Shape {
                    id: shape
                    property color color: "white"
                    width: parent.width
                    height: parent.height

                    ShapePath {
                        strokeWidth: 2
                        strokeColor: shape.color
                        fillColor: "transparent"

                        strokeStyle: ShapePath.DashLine
                        dashPattern: [8, 6]
                        dashOffset: dashOffsetValue

                        PathMove { 
                            x: shapeContainer.width
                            y: 0
                        }
                        PathLine { 
                            x: videoCorner.x
                            y: videoCorner.y
                        }

                    }
                }

                Rectangle {
                    width: ScreenTools.defaultFontPixelWidth * 2
                    border.width: 2
                    border.color: "black"
                    height: width
                    radius: width
                    anchors.centerIn: videoCorner
                }

                Rectangle {
                    width: ScreenTools.defaultFontPixelWidth * 2
                    height: 2
                    anchors.verticalCenter: parent.bottom
                    anchors.horizontalCenter: parent.left
                    rotation: 45
                }

                Rectangle {
                    width: ScreenTools.defaultFontPixelWidth * 2
                    height: 2
                    anchors.verticalCenter: parent.top
                    anchors.horizontalCenter: parent.right
                    rotation: 45
                }
            }
        }
    }
    // updated every time the corner drag is done. allows the operator to resize the window
    // and have the video remain the last inputted size whenever possible.
    Item {
        id:             preferredVideoSize
        anchors.left:   parent.left
        anchors.right:  pipResizeButton.pressed ? pipResizeButton.right : undefined
        width:          mainWindow.width/3 // initialWidth of Video
    }

    // Pip to Window
    CornerButton {
        id:             popupPIP
        anchors.left:   parent.left
        anchors.top:    parent.top
        source:         "/qmlimages/PiP.svg"
        isVisible:      !ScreenTools.isMobile
        onClicked:      _pipOrWindowItem.pipState.state = _pipOrWindowItem.pipState.windowState
    }

    CornerButton {
        id:             hidePIP
        anchors.left:   parent.left
        anchors.bottom: parent.bottom
        source:         "/qmlimages/pipHide.svg"
        onClicked:      _root._setPipIsExpanded(false)
    }

    component CornerButton: MouseArea {
        id: cornerButton

        property alias source: image.source

        // if a MouseArea is above this CornerButton (such as a drag handler)
        // that mouse area is responsible for letting this CornerButton
        // know when it is pressed (so visual indicating the button is pressed
        // can be shown
        property bool isPressed: pressed

        // allows logic determining visiblity to be appended instead of overridden
        property bool isVisible: true

        visible:        isVisible && _isExpanded && (ScreenTools.isMobile || pipMouseArea.containsMouse || popupPIP.containsMouse || hidePIP.containsMouse || pipResizeButton.containsMouse || pipResizeButton.pressed)
        opacity:        pipResizeButton.pressed ? 0 : 1
        width:          ScreenTools.defaultFontPixelWidth * 6
        height:         width

        hoverEnabled: !ScreenTools.isMobile

        property bool anchorTop: anchors.top == parent.top
        property bool anchorBottom: anchors.bottom == parent.bottom
        property bool anchorLeft: anchors.left == parent.left && anchors.leftMargin == 0
        property bool anchorRight: anchors.leftMargin || anchors.right == parent.right

        Item {
            z:              -1
            clip:           true
            opacity:        isPressed ? 0.55 : containsMouse ? 0.33 :  0

            anchors.top:    anchorTop ? parent.top : undefined
            anchors.bottom: anchorBottom ? parent.bottom : undefined
            anchors.left:   anchorLeft ? parent.left : undefined
            anchors.right:  anchorRight ? parent.right : undefined
            width:          parent.width + highlightRect.border.width
            height:         width

            Rectangle {
                id:             highlightRect
                color:          "black"
                width:          parent.width * 2
                height:         width
                x:              anchorLeft ? -width / 2 : 0
                y:              anchorTop ? -height / 2 : 0
                radius:         ScreenTools.defaultFontPixelWidth
                border.width:   ScreenTools.defaultFontPixelWidth / 2
                border.color:   "#66FFFFFF"
            }
        }

        Image {
            id:                 image
            mipmap:             true
            fillMode:           Image.PreserveAspectFit
            anchors.centerIn:   parent
            height:             ScreenTools.defaultFontPixelWidth * 4
            width:              height
            sourceSize.height:  height
        }
    }

    Rectangle {
        id:                     showPip
        anchors.left :          parent.left
        anchors.bottom:         parent.bottom
        height:                 ScreenTools.defaultFontPixelHeight * 2
        width:                  ScreenTools.defaultFontPixelHeight * 2
        radius:                 ScreenTools.defaultFontPixelHeight / 3
        visible:                !_isExpanded
        color:                  qgcPal.window
        opacity:                0.66

        QGCColoredImage {
            width:              parent.width  * 0.75
            height:             parent.height * 0.75
            sourceSize.height:  height
            source:             "qrc:/InstrumentValueIcons/cheveron-right.svg"
            color:              qgcPal.text
            mipmap:             true
            fillMode:           Image.PreserveAspectFit
            anchors.verticalCenter:     parent.verticalCenter
            anchors.horizontalCenter:   parent.horizontalCenter
        }
        MouseArea {
            anchors.fill:   parent
            onClicked:      _root._setPipIsExpanded(true)
        }
    }    
}
