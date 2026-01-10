import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView

Item {
    id:                     root
    property real spacing:  0
    width:                  telemetry.width + instrumentPanel.width + spacing
    height:                 Math.max(telemetry.height, instrumentPanel.height)

    HideButton {
        id:                     telemHideButton
        side:                   side_BOTTOM
        anchors.left:           telemetry.left
        anchors.bottom:         telemetry.top

        HideButtonValue {
            id: telemetryMarginCalc
            valueWhenMinimized: -telemetry.height
            valueWhenExpanded:  0
        }
    }

    TelemetryValuesBar {
        id:                     telemetry
        anchors.bottom:         parent.bottom
        anchors.bottomMargin:   telemetryMarginCalc.value
        extraWidth:             instrumentPanel.extraValuesWidth * instrumentHideButton.ratioOpen * telemHideButton.ratioOpen
        settingsGroup:          factValueGrid.telemetryBarSettingsGroup
        specificVehicleForCard: null // Tracks active vehicle
    }

    FlyViewInstrumentPanel {
        id:                 instrumentPanel
        x:                  telemetry.width + root.spacing + instrumentPanelXCalc.value
        anchors.bottom:     parent.bottom
        visible:            QGroundControl.corePlugin.options.flyView.showInstrumentPanel && _showSingleVehicleUI

        HideButton {
            id:         instrumentHideButton
            side:       side_LEFT
            visible:    instrumentPanel.visible
            property real compassRadius: {
                if(instrumentPanel.innerControl) {
                    if(QGroundControl.settingsManager.flyViewSettings.instrumentQmlFile2.value.includes("IntegratedCompassAttitude")) {
                        return instrumentPanel.innerControl.compassRadius
                    }
                    if(QGroundControl.settingsManager.flyViewSettings.instrumentQmlFile2.value.includes("HorizontalCompassAttitude")) {
                        return instrumentPanel.height/2
                    }
                    if(QGroundControl.settingsManager.flyViewSettings.instrumentQmlFile2.value.includes("VerticalCompassAttitude")) {
                        return instrumentPanel.width/2
                    }
                }
                return 0
            }
            property real compassCenterX: compassRadius
            property real compassCenterY: {
                if(instrumentPanel.innerControl) {
                    if(QGroundControl.settingsManager.flyViewSettings.instrumentQmlFile2.value.includes("IntegratedCompassAttitude")) {
                        return instrumentPanel.innerControl.attitudeSize
                                + instrumentPanel.innerControl.attitudeSpacing
                                + instrumentPanel.innerControl.compassRadius
                    }
                }
                return compassRadius
            }
            x:          visible && instrumentPanel.innerControl
                            ? compassCenterX
                                + (compassRadius + width/2) // desired button center compass center distance
                                * Math.cos(rotation * Math.PI / 180)
                                - width/2
                            : 0
            y:          visible && instrumentPanel.innerControl
                            ? compassCenterY
                                    + (compassRadius + width/2) // desired button center compass center distance 
                                    * Math.sin(rotation * Math.PI / 180)
                                - height/2
                            : 0
            rotation:   180 + 45 * ratioOpen

            HideButtonValue {
                id:                 instrumentPanelXCalc
                valueWhenMinimized: instrumentPanel.width - _toolsMargin
                valueWhenExpanded:  0
            }
        }
    }
}
