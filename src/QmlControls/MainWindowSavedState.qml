import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtCore

import QGroundControl
import QGroundControl.Controls

Item {
    property Window window

    property bool _enabled: !ScreenTools.isMobile && !ScreenTools.fakeMobile && QGroundControl.corePlugin.options.enableSaveMainWindowPosition
    property alias s: s

    Settings {
        id:         s
        category:   "MainWindowState"

        property int x
        property int y
        property int width
        property int height
        property int visibility
    }

    Component.onCompleted: {
        if (!ScreenTools.fakeMobile && !ScreenTools.isMobile 
                && QGroundControl.corePlugin.options.enableSaveMainWindowPosition
                && s.width && s.height) {
            window.x = s.x;
            window.y = s.y;
        }
    }

    Connections {
        target:                         window
        function onXChanged()           { if(_enabled) saveSettingsTimer.restart() }
        function onYChanged()           { if(_enabled) saveSettingsTimer.restart() }
        function onWidthChanged()       { if(_enabled) saveSettingsTimer.restart() }
        function onHeightChanged()      { if(_enabled) saveSettingsTimer.restart() }
        function onVisibilityChanged()  { if(_enabled) saveSettingsTimer.restart() }
    }

    Timer {
        id:             saveSettingsTimer
        interval:       500
        repeat:         false
        onTriggered:    saveSettings()
    }

    function saveSettings() {
        if (_enabled) {
            switch(window.visibility) {
            case ApplicationWindow.Windowed:
                s.x = window.x;
                s.y = window.y;
                s.width = window.width;
                s.height = window.height;
                s.visibility = window.visibility;
                break;
            case ApplicationWindow.FullScreen:
                s.visibility = window.visibility;
                break;
            case ApplicationWindow.Maximized:
                s.visibility = window.visibility;
                break;
            }
        }
    }
}
