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
            text: "Powermenu Settings"
            font.pixelSize: 18
            font.weight: Font.Bold
            color: "#FFFFFF"
        }

        Text {
            text: "Quickly access power management actions like Lock, Logout, Reboot, and Poweroff."
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

            Text {
                text: noTriggerToggle.checked ? "Power actions are always visible in the launcher." : "Type the trigger to access power actions."
                font.pixelSize: 12
                color: "#CCFFFFFF"
                wrapMode: Text.WordWrap
                width: parent.width
            }

            Row {
                spacing: 12

                CheckBox {
                    id: noTriggerToggle
                    text: "No trigger (always show)"
                    checked: loadSettings("noTrigger", false)

                    contentItem: Text {
                        text: noTriggerToggle.text
                        font.pixelSize: 14
                        color: "#FFFFFF"
                        leftPadding: noTriggerToggle.indicator.width + 8
                        verticalAlignment: Text.AlignVCenter
                    }

                    indicator: Rectangle {
                        implicitWidth: 20
                        implicitHeight: 20
                        radius: 4
                        border.color: noTriggerToggle.checked ? "#4CAF50" : "#60FFFFFF"
                        border.width: 2
                        color: noTriggerToggle.checked ? "#4CAF50" : "transparent"

                        Rectangle {
                            width: 12
                            height: 12
                            anchors.centerIn: parent
                            radius: 2
                            color: "#FFFFFF"
                            visible: noTriggerToggle.checked
                        }
                    }

                    onCheckedChanged: {
                        saveSettings("noTrigger", checked)
                        if (checked) {
                            saveSettings("trigger", "")
                        } else {
                            const currentTrigger = triggerField.text || "power"
                            saveSettings("trigger", currentTrigger)
                        }
                    }
                }
            }

            Row {
                spacing: 12
                anchors.left: parent.left
                anchors.right: parent.right
                visible: !noTriggerToggle.checked

                Text {
                    text: "Trigger:"
                    font.pixelSize: 14
                    color: "#FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                }

                DankTextField {
                    id: triggerField
                    width: 100
                    height: 40
                    text: loadSettings("trigger", "power")
                    placeholderText: "power"
                    backgroundColor: "#30FFFFFF"
                    textColor: "#FFFFFF"

                    onTextEdited: {
                        const newTrigger = text.trim()
                        saveSettings("trigger", newTrigger || "power")
                        saveSettings("noTrigger", newTrigger === "")
                    }
                }
            }
        }
    }

    function saveSettings(key, value) {
        if (pluginService) {
            pluginService.savePluginData("powermenu", key, value)
        }
    }

    function loadSettings(key, defaultValue) {
        if (pluginService) {
            return pluginService.loadPluginData("powermenu", key, defaultValue)
        }
        return defaultValue
    }
}
