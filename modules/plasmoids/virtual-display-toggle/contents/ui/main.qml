import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3

PlasmoidItem {
    id: root

    Layout.minimumWidth: PlasmaCore.Units.iconSizes.medium
    Layout.minimumHeight: PlasmaCore.Units.iconSizes.medium
    Layout.preferredWidth: PlasmaCore.Units.iconSizes.medium
    Layout.preferredHeight: PlasmaCore.Units.iconSizes.medium

    toolTipMainText: i18n("Virtual Display")
    toolTipSubText: isActive ? i18n("Active - Click to disable") : i18n("Inactive - Click to enable")

    PlasmaCore.DataSource {
        id: runner
        engine: "executable"
        connectedSources: []
        onNewData: {
            var out = data["stdout"] || "";
            if (data["exit code"] == 0 && out.indexOf("active") >= 0) {
                isActive = true;
            } else {
                isActive = false;
            }
            disconnectSource(sourceName);
        }
    }

    property bool isActive: false

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: runner.connectSource("systemctl --user is-active virtual-display 2>/dev/null || echo inactive")
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (isActive) {
                runner.connectSource("systemctl --user stop virtual-display");
            } else {
                runner.connectSource("systemctl --user start virtual-display");
            }
        }
    }

    PlasmaCore.IconItem {
        id: iconItem
        anchors.centerIn: parent
        width: PlasmaCore.Units.iconSizes.medium
        height: PlasmaCore.Units.iconSizes.medium
        source: isActive ? "video-display" : "monitor"
        active: mouseArea.containsMouse || root.expanded
        colorGroup: PlasmaCore.ColorScope.colorGroup
    }

    Rectangle {
        anchors.fill: parent
        color: isActive ? PlasmaCore.Theme.highlightColor : "transparent"
        opacity: isActive ? 0.3 : 0
        radius: PlasmaCore.Units.smallSpacing
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
}
