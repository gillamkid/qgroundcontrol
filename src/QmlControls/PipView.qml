import QtQuick
import QtQuick.Window

import QGroundControl
import QGroundControl.Controls

Item {
    id:         _root
    width:      _pipSize
    height:     _pipSize * (9/16)
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
    property real   _pipSize:           parent.width * 0.2
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

    // MouseArea to drag in order to resize the PiP area
    CornerButtonMouseArea {
        id:             pipResize
        corner:         corner_TOP_RIGHT
        visible:        !ScreenTools.isMobile

        preventStealing:    true
        cursorShape:        Qt.PointingHandCursor

        property real initialX:     0
        property real initialWidth: 0

        onPressed: (mouse) => {
            pipResize.initialX = mouse.x
            pipResize.initialWidth = _root.width
        }

        // Remove the anchor so the our mouse coordinates stay in the same original place for drag tracking
        anchors.top: pressed ? undefined : parent.top
        anchors.right: pressed ? undefined : parent.right

        // Drag
        onPositionChanged: (mouse) => {
            if (pipResize.pressed) {
                var parentWidth = _root.parent.width
                var newWidth = pipResize.initialWidth + mouse.x - pipResize.initialX
                if (newWidth < parentWidth * _maxSize && newWidth > parentWidth * _minSize) {
                    _pipSize = newWidth
                }
            }
        }
    }
    CornerButton {
        mouseArea:      pipResize
        source:         "/qmlimages/pipResize.svg"
    }

    // Check min/max constraints on pip size when when parent is resized
    Connections {
        target: _root.parent

        function onWidthChanged() {
            if (!_componentComplete) {
                // Wait until first time setup is done
                return
            }
            var parentWidth = _root.parent.width
            if (_root.width > parentWidth * _maxSize) {
                _pipSize = parentWidth * _maxSize
            } else if (_root.width < parentWidth * _minSize) {
                _pipSize = parentWidth * _minSize
            }
        }
    }

    // Pip to Window
    CornerButtonMouseArea {
        id:             popupPIP
        corner:         corner_TOP_LEFT 
        visible:        !ScreenTools.isMobile
        onClicked:      _pipOrWindowItem.pipState.state = _pipOrWindowItem.pipState.windowState
    }
    CornerButton {
        mouseArea:      popupPIP
        source:         "/qmlimages/PiP.svg"
    }

    CornerButtonMouseArea {
        id:             hidePIP
        corner:         corner_BOTTOM_LEFT 
        onClicked:      _root._setPipIsExpanded(false)
    }
    CornerButton {
        mouseArea:      hidePIP
        source:         "/qmlimages/pipHide.svg"
    }

    component CornerButtonMouseArea: MouseArea {

        required property int corner


        height:         ScreenTools.defaultFontPixelWidth * 6
        width:          ScreenTools.defaultFontPixelWidth * 6

        property bool hovered: pipMouseArea.containsMouse 
            && ( ((corner == corner_TOP_LEFT || corner == corner_BOTTOM_LEFT) && pipMouseArea.mouseX <= width) 
                || ((corner == corner_TOP_RIGHT || corner == corner_BOTTOM_RIGHT) && pipMouseArea.mouseX >= x ) )
            && ( ((corner == corner_BOTTOM_RIGHT || corner == corner_BOTTOM_LEFT) && pipMouseArea.mouseY >= y)
                || ((corner == corner_TOP_RIGHT || corner == corner_TOP_LEFT) &&pipMouseArea.mouseY <= height) )

        
        anchors.top:    (corner == corner_TOP_LEFT || corner == corner_TOP_RIGHT) ? parent.top : undefined
        anchors.bottom: (corner == corner_BOTTOM_LEFT || corner == corner_BOTTOM_RIGHT) ? parent.bottom : undefined
        anchors.left:   (corner == corner_TOP_LEFT || corner == corner_BOTTOM_LEFT) ? parent.left : undefined
        anchors.right:  (corner == corner_TOP_RIGHT || corner == corner_BOTTOM_RIGHT) ? parent.right : undefined
    }

    readonly property int corner_TOP_LEFT:      1
    readonly property int corner_TOP_RIGHT:     2
    readonly property int corner_BOTTOM_LEFT:   3
    readonly property int corner_BOTTOM_RIGHT:  4

    component CornerButton: Item {
        required property var mouseArea
        property alias source:    image.source

        id:             cornerButton
        visible:        mouseArea.visible && _isExpanded && (ScreenTools.isMobile || pipMouseArea.containsMouse)
        width:          mouseArea.width
        height:         mouseArea.height
        anchors.top:    mouseArea.corner == corner_TOP_LEFT || mouseArea.corner == corner_TOP_RIGHT ? parent.top : undefined
        anchors.bottom: mouseArea.corner == corner_BOTTOM_LEFT || mouseArea.corner == corner_BOTTOM_RIGHT ? parent.bottom : undefined
        anchors.left:   mouseArea.corner == corner_TOP_LEFT || mouseArea.corner == corner_BOTTOM_LEFT ? parent.left : undefined
        anchors.right:  mouseArea.corner == corner_TOP_RIGHT || mouseArea.corner == corner_BOTTOM_RIGHT ? parent.right : undefined

        Item {
            z:              -1
            clip:           true
            opacity:        mouseArea.pressed ? 0.55 : mouseArea.hovered ? 0.33 :  0

            anchors.top:    mouseArea.corner == corner_TOP_LEFT || mouseArea.corner == corner_TOP_RIGHT ? parent.top : undefined
            anchors.bottom: mouseArea.corner == corner_BOTTOM_LEFT || mouseArea.corner == corner_BOTTOM_RIGHT ? parent.bottom : undefined
            anchors.left:   mouseArea.corner == corner_TOP_LEFT || mouseArea.corner == corner_BOTTOM_LEFT ? parent.left : undefined
            anchors.right:  mouseArea.corner == corner_TOP_RIGHT || mouseArea.corner == corner_BOTTOM_RIGHT ? parent.right : undefined
            width:          parent.width + highlightRect.border.width
            height:         width

            Rectangle {
                id:             highlightRect
                color:          "black"
                width:          parent.width * 2
                height:         width
                x:              mouseArea.corner == corner_TOP_LEFT || mouseArea.corner == corner_BOTTOM_LEFT  ? -width / 2 : 0
                y:              mouseArea.corner == corner_TOP_LEFT || mouseArea.corner == corner_TOP_RIGHT  ? -height / 2 : 0
                radius:         ScreenTools.defaultFontPixelWidth
                border.width:    ScreenTools.defaultFontPixelWidth / 2
                border.color:    "#66FFFFFF"
            }

            //  Rectangle {
            //     color:          "black"
            //     width:          parent.width
            //     height:         width
            //     // x:              mouseArea.corner == corner_TOP_LEFT || mouseArea.corner == corner_BOTTOM_LEFT  ? -width / 2 : 0
            //     // y:              mouseArea.corner == corner_TOP_LEFT || mouseArea.corner == corner_TOP_RIGHT  ? -height / 2 : 0
            //     radius:         width / 2 //* .8
            //     //border.width:    ScreenTools.defaultFontPixelWidth / 2
            //     //border.color:    "#66FFFFFF"
            // }
        }

        Image {
            id:                 image
            mipmap:             true
            fillMode:           Image.PreserveAspectFit
            anchors.top:        mouseArea.corner == corner_TOP_LEFT || mouseArea.corner == corner_TOP_RIGHT ? parent.top : undefined
            anchors.bottom:     mouseArea.corner == corner_BOTTOM_LEFT || mouseArea.corner == corner_BOTTOM_RIGHT ? parent.bottom : undefined
            anchors.left:       mouseArea.corner == corner_TOP_LEFT || mouseArea.corner == corner_BOTTOM_LEFT ? parent.left : undefined
            anchors.right:      mouseArea.corner == corner_TOP_RIGHT || mouseArea.corner == corner_BOTTOM_RIGHT ? parent.right : undefined
            anchors.margins:   ScreenTools.defaultFontPixelWidth
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
