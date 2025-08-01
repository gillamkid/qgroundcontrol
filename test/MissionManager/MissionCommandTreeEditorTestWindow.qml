/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Window

import QGroundControl

import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.FlightDisplay
import QGroundControl.FlightMap


ApplicationWindow {
    id:         _root
    visible:    true
    visibility: Qt.WindowFullScreen
    color:      qgcPal.window

    property real editorWidth:  ScreenTools.defaultFontPixelWidth * 30

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    Timer {
        id:             timer
        interval:       100
        onTriggered: {
            var success = fullImage.grabToImage(function(result) { result.saveToFile(imagePath) })
            console.log(success)
        }
    }

    Component.onCompleted: timer.start()

    Flow {
        id:             fullImage
        anchors.fill:   parent

        Repeater {
            model: missionItems

            Column {
                QGCLabel { text: modelData.commandName; color: "black" }

                Loader {
                    id:             editorLoader
                    source:         modelData.editorQml

                    property var    missionItem:        modelData
                    property var    masterController:   planMasterController
                    property real   availableWidth:     editorWidth
                }
            }
        }
    }
}
