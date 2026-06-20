import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.plasma5support 2.0 as P5Support

PlasmoidItem {
    id: root

    Layout.minimumWidth: 32
    Layout.minimumHeight: 32

    property bool isActive: false

    P5Support.DataSource {
        id: runner
        engine: "executable"
        connectedSources: []
        onNewData: function(data) {
            var out = data["stdout"] || "";
            var exitCode = data["exit code"];
            if (exitCode == 0) {
                isActive = (out.indexOf("active") >= 0);
            }
            disconnectSource(data["sourceName"]);
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: runner.connectSource("systemctl --user is-active sunshine 2>/dev/null || echo inactive")
    }

    MouseArea {
        anchors.fill: parent
        onClicked: runner.connectSource("xdg-open http://localhost:47989 2>/dev/null")
    }

    Item {
        anchors.centerIn: parent
        width: 22
        height: 22

        Rectangle {
            anchors.fill: parent
            color: isActive ? "#3d8ee9" : "#666"
            radius: 4
        }

        Text {
            anchors.centerIn: parent
            text: isActive ? "\u25B6" : "\u25A0"
            color: "white"
            font.pixelSize: 14
        }
    }
}
