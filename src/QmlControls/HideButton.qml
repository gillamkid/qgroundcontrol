import QtQuick
import QtQuick.Controls

import QGroundControl
import QGroundControl.Controls

Item {
    id: root

    readonly property int side_RIGHT:    0
    readonly property int side_BOTTOM:   1
    readonly property int side_LEFT:     2
    readonly property int side_TOP:      3

    required property int side

    property bool expanded: true
    readonly property real ratioOpen: icon.ratioOpen

    implicitWidth: ScreenTools.defaultFontPixelWidth * 2 * widthRatio
    implicitHeight: ScreenTools.defaultFontPixelWidth * 2 * heightRatio

    opacity: 0.66

    property real widthRatio:   root.side == side_LEFT || root.side == side_RIGHT ? 2 : 3
    property real heightRatio:  root.side == side_LEFT || root.side == side_RIGHT ? 3 : 2

    // Hit box for MinimizeButton
    QGCButton {
        id: button
        onClicked: root.expanded = !root.expanded
        anchors.fill: parent
        opacity: 0
    }

    // Visuals for MinimizeButton
    Rectangle {
        opacity: 0.66 + .24 * ratioMovedForHover

        property real ratioMovedForHover: button.hovered ? 1 : 0
        Behavior on ratioMovedForHover { NumberAnimation { duration: 150 } }
        
        height:                     ScreenTools.defaultFontPixelWidth * 2/3 * heightRatio
        width:                      ScreenTools.defaultFontPixelWidth * 2/3 * widthRatio
        color:                      qgcPal.window
        radius:                     ScreenTools.defaultFontPixelWidth / 4

        anchors.verticalCenter:     root.side == side_LEFT || root.side == side_RIGHT ? parent.verticalCenter : undefined
        anchors.horizontalCenter:   root.side == side_TOP || root.side == side_BOTTOM ? parent.horizontalCenter : undefined
        anchors.left:               root.side == side_LEFT   ? parent.left   : undefined
        anchors.right:              root.side == side_RIGHT  ? parent.right  : undefined
        anchors.top:                root.side == side_TOP    ? parent.top    : undefined
        anchors.bottom:             root.side == side_BOTTOM ? parent.bottom : undefined

        anchors.leftMargin:         width/2 + (parent.width/2 - width) * ratioMovedForHover
        anchors.rightMargin:        anchors.leftMargin
        anchors.topMargin:          height/2 + (parent.height/2 - height) * ratioMovedForHover
        anchors.bottomMargin:       anchors.topMargin

        Rectangle {
            anchors.fill:   parent
            color:          qgcPal.text
            opacity:        button.pressed ? 0.2 : 0
            radius:         parent.radius
        }
        
        QGCColoredImage {
            id:                 icon

            property real ratioOpen: expanded ? 1 : 0
            Behavior on ratioOpen { NumberAnimation { duration: 150 } }

            source:             "qrc:/InstrumentValueIcons/cheveron-left.svg"
            fillMode:           Image.PreserveAspectFit
            anchors.centerIn:   parent
            sourceSize.height:  height
            height:             parent.height
            width:              height
            color:              qgcPal.text
            rotation:           (90 * root.side) + 180 * root.ratioOpen
        }
    }
}
