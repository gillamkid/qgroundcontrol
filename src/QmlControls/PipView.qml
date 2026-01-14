import QtQuick
import QtQuick.Window

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

    CornerButton {
        id:                 pipResizeButton
        source:             "/qmlimages/pipResize.svg"
        anchors.top:        parent.top
        anchors.left:       pressed ? undefined : parent.left
        anchors.leftMargin: (desiredVideoSize.width - width) < drag.maximumX ? desiredVideoSize.width - width : drag.maximumX

        drag.target:        pipResizeButton
        drag.axis:          Drag.XAxis
        drag.minimumX:      ScreenTools.defaultFontPixelWidth * 6 * 2
        drag.maximumX:      _root.parent.width/2 - pipResizeButton.width
        Drag.active:        drag.active
        cursorShape:        pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
    }

    // MouseArea to drag in order to resize the PiP area


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

    // invisible: when main window is resized, this is a placemarker of the desired video size. updated every time the corner drag is done
    Rectangle {
        id:             desiredVideoSize
        color:          "red"
        opacity:        .5
        height:         width * (9/16)
        anchors.left:   parent.left
        anchors.bottom: parent.bottom
        anchors.right:  pipResizeButton.pressed ? pipResizeButton.right : undefined
        anchors.top:    pipResizeButton.pressed ? pipResizeButton.top : undefined
        width:          mainWindow.width/3
    }

    // When doing the drag, if the mouse leaves the Mouse area handling the drag the ClosedHandCursor
    // dissappears. This makes so that doesn't happen 
    MouseArea {
        x: -5000
        y: -5000
        width: 10000
        height: 10000

        visible: pipResizeButton.pressed
        cursorShape:       Qt.ClosedHandCursor
    }
}
