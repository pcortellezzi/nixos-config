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
            isActive = (out.indexOf("Virtual-1") >= 0);
            disconnectSource(data["sourceName"]);
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: runner.connectSource("kscreen-doctor -o 2>/dev/null | grep Virtual-1 || echo inactive")
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (isActive) {
                runner.connectSource("kscreen-doctor output.Virtual-1.disable 2>/dev/null");
            } else {
                runner.connectSource("kscreen-doctor output.Virtual-1.enable 2>/dev/null");
            }
        }
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
