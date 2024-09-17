/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.ScreenTools
import QGroundControl.Vehicle
import QGroundControl.Controls
import QGroundControl.Palette

Item {
    id:             control
    implicitWidth:  mainLayout.width + (_toolsMargin * 2)
    implicitHeight: mainLayout.height + (_toolsMargin * 2)

    property real extraWidth: 0 ///< Extra width to add to the background rectangle

    Rectangle {
        id:         backgroundRect
        width:      control.width + extraWidth
        height:     control.height
        color:      qgcPal.window
        radius:     ScreenTools.defaultFontPixelWidth / 2
        opacity:    0.75
    }

    QGCMouseArea {
        id:                     mouseArea
        anchors.fill:           parent
        visible:                ScreenTools.isMobile && !valueArea.settingsUnlocked
        onClicked:              valueArea.settingsUnlocked = true
    }

    //DeadMouseArea { anchors.fill: parent }

    ColumnLayout {
        id:                 mainLayout
        anchors.margins:    _toolsMargin
        anchors.bottom:     parent.bottom
        anchors.left:       parent.left

        QGCButton {
            visible:                hoverHandler.hovered && !valueArea.settingsUnlocked
            iconSource:             "/res/pencil.svg"
            Layout.preferredWidth:  height
            Layout.topMargin:       -_toolsMargin*2
            Layout.leftMargin:      -_toolsMargin*2
            Layout.bottomMargin:    -_toolsMargin*2
            backgroundColor:        "transparent"
            showBorder:             false
            textColor:              qgcPal.text
            leftPadding:            topPadding
            scale:                  .75
            onClicked:              valueArea.settingsUnlocked = true
        }

        QGCButton {
            visible:                valueArea.settingsUnlocked
            iconSource:             "/res/pencil-finished.svg"
            text:                   qsTr("Close")
            onClicked:              valueArea.settingsUnlocked = false
        }

        HorizontalFactValueGrid {
            id:                     valueArea
            userSettingsGroup:      telemetryBarUserSettingsGroup
            defaultSettingsGroup:   telemetryBarDefaultSettingsGroup
        }
    }

    HoverHandler {
        id: hoverHandler
        enabled: !ScreenTools.isMobile
    }
}
