import QtQuick
import Quickshell
import qs.Common
import qs.Services

Item {
    id: root
    property var pluginService: null
    property string trigger: "="
    
    property string lastQuery: ""
    property string currentResult: ""

    signal itemsChanged()

    // Bridge asynchronous results back to the UI via global variables
    Connections {
        target: PluginService
        function onGlobalVarChanged(pluginId, varName) {
            if (pluginId === "qalculate" && varName === "result") {
                const res = PluginService.getGlobalVar("qalculate", "result", "")
                if (res) {
                    root.currentResult = res
                    root.itemsChanged()
                }
            }
        }
    }

    Component.onCompleted: {
        if (pluginService) {
            trigger = pluginService.loadPluginData("qalculate", "trigger", "=")
        }
    }

    function getItems(query) {
        if (!query || query.trim().length === 0) {
            root.currentResult = ""
            root.lastQuery = ""
            return []
        }

        const trimmedQuery = query.trim()

        if (trimmedQuery !== root.lastQuery) {
            root.lastQuery = trimmedQuery
            
            Proc.runCommand(
                "qalculate.calc",
                ["qalc", "-terse", trimmedQuery],
                (output, exitCode) => {
                    if (exitCode === 0 && output) {
                        const res = output.trim()
                        if (res.length > 0) {
                            PluginService.setGlobalVar("qalculate", "result", res)
                        }
                    }
                },
                200 // debounce
            )
        }

        if (root.currentResult) {
            return [{
                name: root.currentResult,
                icon: "calculate",
                comment: trimmedQuery + " = " + root.currentResult,
                action: "copy:" + root.currentResult,
                categories: ["Qalculate"]
            }]
        }
        
        return [{
            name: "Calculating...",
            icon: "calculate",
            comment: trimmedQuery,
            action: "noop",
            categories: ["Qalculate"]
        }]
    }

    function executeItem(item) {
        if (!item || !item.action) return
        
        if (item.action.startsWith("copy:")) {
            const text = item.action.substring(5)
            Quickshell.execDetached(["dms", "cl", "copy", text])
            if (typeof ToastService !== "undefined") {
                ToastService.showInfo("Qalculate", "Copied to clipboard")
            }
        }
    }

    onTriggerChanged: {
        if (pluginService) {
            pluginService.savePluginData("qalculate", "trigger", trigger)
        }
    }
}