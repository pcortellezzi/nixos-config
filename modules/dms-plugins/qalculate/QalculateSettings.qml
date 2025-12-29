import QtQuick
import QtQuick.Controls
import qs.Widgets

FocusScope {
    id: root
    property var pluginService: null

    implicitHeight: settingsColumn.implicitHeight
    height: implicitHeight

    Column {
        id: settingsColumn
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        Text {
            text: "Qalculate Settings"
            font.pixelSize: 18
            font.weight: Font.Bold
            color: "#FFFFFF"
        }

        Text {
            text: "Calculate math expressions, unit conversions, and more using qalc."
            font.pixelSize: 14
            color: "#CCFFFFFF"
            wrapMode: Text.WordWrap
            width: parent.width - 32
        }

        Rectangle {
            width: parent.width - 32
            height: 1
            color: "#30FFFFFF"
        }

        Column {
            spacing: 12
            width: parent.width - 32

            Text {
                text: "Trigger Configuration"
                font.pixelSize: 16
                font.weight: Font.Medium
                color: "#FFFFFF"
            }

            Row {
                spacing: 12
                CheckBox {
                    id: noTriggerToggle
                    text: "No trigger (always active)"
                    checked: loadSettings("noTrigger", false)
                    onCheckedChanged: {
                        saveSettings("noTrigger", checked)
                        if (checked) saveSettings("trigger", "")
                        else saveSettings("trigger", triggerField.text || "=")
                    }
                    contentItem: Text {
                        text: noTriggerToggle.text
                        color: "#FFFFFF"
                        leftPadding: noTriggerToggle.indicator.width + 8
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Row {
                spacing: 12
                visible: !noTriggerToggle.checked
                Text {
                    text: "Trigger:"
                    color: "#FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                }
                DankTextField {
                    id: triggerField
                    width: 100
                    height: 40
                    text: loadSettings("trigger", "=")
                    placeholderText: "="
                    backgroundColor: "#30FFFFFF"
                    textColor: "#FFFFFF"
                    onTextEdited: {
                        saveSettings("trigger", text.trim() || "=")
                        saveSettings("noTrigger", text.trim() === "")
                    }
                }
            }
        }
    }

    function saveSettings(key, value) {
        if (pluginService) pluginService.savePluginData("qalculate", key, value)
    }

    function loadSettings(key, defaultValue) {
        if (pluginService) return pluginService.loadPluginData("qalculate", key, defaultValue)
        return defaultValue
    }
}
