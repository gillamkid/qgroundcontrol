import QtQuick
import QtQuick.Controls

import QGroundControl
import QGroundControl.Controls

TinyButton {
    id: root

    property bool expanded: true
    readonly property real ratioOpen: internal.ratioOpen

    onClicked: root.expanded = !root.expanded
    source: {
        if((side == side_LEFT && !expanded) || (side == side_RIGHT && expanded)) {
            return "qrc:/InstrumentValueIcons/cheveron-right.svg"
        } else if((side == side_RIGHT && !expanded) || (side == side_LEFT && expanded)) {
            return "qrc:/InstrumentValueIcons/cheveron-left.svg"
        } else if((side == side_TOP && !expanded) || (side == side_BOTTOM && expanded)) {
            return "qrc:/InstrumentValueIcons/cheveron-down.svg"
        } else {
            return "qrc:/InstrumentValueIcons/cheveron-up.svg"
        }
    }

    Item {
        id: internal
        property real ratioOpen: expanded ? 1 : 0
        Behavior on ratioOpen { NumberAnimation { duration: 150 } }
    }
}
