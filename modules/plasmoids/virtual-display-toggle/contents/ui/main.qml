import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmoidItem {
    id: root

    Layout.minimumWidth: PlasmaCore.Units.iconSizes.medium
    Layout.minimumHeight: PlasmaCore.Units.iconSizes.medium

    property bool isActive: false

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

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: runner.connectSource("systemctl --user is-active virtual-display 2>/dev/null || echo inactive")
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (isActive) {
                runner.connectSource("systemctl --user stop virtual-display");
            } else {
                runner.connectSource("systemctl --user start virtual-display");
            }
        }
    }

    PlasmaCore.IconItem {
        anchors.centerIn: parent
        width: PlasmaCore.Units.iconSizes.medium
        height: PlasmaCore.Units.iconSizes.medium
        source: isActive ? "video-display" : "monitor"
    }
}
