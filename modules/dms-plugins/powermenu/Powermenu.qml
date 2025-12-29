import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services

Item {
    id: root

    property var pluginService: null
    property string trigger: "power"

    Component.onCompleted: {
        console.log("Powermenu: Plugin loaded")
        if (pluginService) {
            trigger = pluginService.loadPluginData("powermenu", "trigger", "power")
        }
    }

    function getItems(query) {
        // Simple filtering
        const actions = [
            {
                name: "Lock",
                icon: "material:lock",
                comment: "Lock the screen",
                action: "lock",
                categories: ["Powermenu"]
            },
            {
                name: "Logout",
                icon: "material:logout",
                comment: "Exit user session",
                action: "logout",
                categories: ["Powermenu"]
            },
            {
                name: "Reboot",
                icon: "material:restart_alt",
                comment: "Restart the computer",
                action: "reboot",
                categories: ["Powermenu"]
            },
            {
                name: "Poweroff",
                icon: "material:power_settings_new",
                comment: "Turn off the computer",
                action: "poweroff",
                categories: ["Powermenu"]
            }
        ];

        if (!query) return actions;
        
        const lowerQuery = query.toLowerCase();
        return actions.filter(item => item.name.toLowerCase().includes(lowerQuery));
    }

    function executeItem(item) {
        if (!item || !item.action) return;

        console.log("Powermenu executing action:", item.action);
        showToast("Executing: " + item.name);

        switch (item.action) {
            case "lock":
                // Use DMS IPC for locking as suggested
                Quickshell.execDetached(["dms", "ipc", "call", "lock", "lock"]);
                break;
            case "logout":
                SessionService.logout();
                break;
            case "reboot":
                SessionService.reboot();
                break;
            case "poweroff":
                SessionService.poweroff();
                break;
        }
    }

    function showToast(message) {
        if (typeof ToastService !== "undefined") {
            ToastService.showInfo("Powermenu", message)
        } else {
            console.log("Powermenu Toast:", message)
        }
    }

    onTriggerChanged: {
        if (pluginService) {
            pluginService.savePluginData("powermenu", "trigger", trigger)
        }
    }
}
