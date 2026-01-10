import QtQuick

Item {
    property var hideButton: parent
    required property real valueWhenMinimized
    required property real valueWhenExpanded

    readonly property real value: valueWhenExpanded * hideButton.ratioOpen + valueWhenMinimized * (1-hideButton.ratioOpen)
}
