import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FactControls
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

    property real compassRadius: {
        if(instrumentPanel.innerControl) {
            if(QGroundControl.settingsManager.flyViewSettings.instrumentQmlFile2.value.includes("IntegratedCompassAttitude") && instrumentPanel.innerControl.compassRadius) {
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

    FlyViewInstrumentPanel {
        id:                 instrumentPanel
        x:                  telemetry.width + root.spacing + instrumentPanelXCalc.value
        anchors.bottom:     parent.bottom
        visible:            QGroundControl.corePlugin.options.flyView.showInstrumentPanel && _showSingleVehicleUI

        HideButton {
            id:         instrumentHideButton
            side:       side_LEFT
            visible:    instrumentPanel.visible
            x:          compassCenterX
                            + (compassRadius + width/2) // desired button center compass center distance
                            * Math.cos(rotation * Math.PI / 180)
                            - width/2
            y:          compassCenterY
                            + (compassRadius + width/2) // desired button center compass center distance 
                            * Math.sin(rotation * Math.PI / 180)
                            - height/2
            rotation:   180 + 45 * ratioOpen
            
            property real compassCenterX: compassRadius

            HideButtonValue {
                id:                 instrumentPanelXCalc
                valueWhenMinimized: instrumentPanel.width - _toolsMargin
                valueWhenExpanded:  0
            }
        }

        TinyButton {
            id:         dotsButton
            side:       side_LEFT
            visible:    instrumentPanel.visible
            source:     "qrc:/InstrumentValueIcons/dots-horizontal-double.svg"
            onClicked:  {
                            instrumentSelectorComboBox.visible = !instrumentSelectorComboBox.visible
                            if(instrumentSelectorComboBox.visible) {
                                instrumentSelectorComboBox.popup.open()
                            }
                        }
            x:          compassCenterX
                            + (compassRadius + width/2) // desired button center compass center distance
                            * Math.cos(rotation * Math.PI / 180)
                            - width/2
            y:          compassCenterY
                            + (compassRadius + width/2) // desired button center compass center distance 
                            * Math.sin(rotation * Math.PI / 180)
                            - height/2
            rotation:   -45

            property real compassCenterX: {
                if(instrumentPanel.innerControl) {
                    if(QGroundControl.settingsManager.flyViewSettings.instrumentQmlFile2.value.includes("HorizontalCompassAttitude")) {
                        return instrumentPanel.width - compassRadius
                    }
                }
                return compassRadius
            }
        }

        FactComboBox {
            id:                     instrumentSelectorComboBox
            visible:                false
            fact:                   QGroundControl.settingsManager.flyViewSettings.instrumentQmlFile2
            anchors.right:          dotsButton.left
            anchors.verticalCenter: dotsButton.verticalCenter
            onActivated:            visible = false
            sizeToContents:         true
        }
    }
}
