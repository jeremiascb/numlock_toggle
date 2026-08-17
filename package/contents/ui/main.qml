pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.private.keyboardindicator as KeyboardIndicator

PlasmoidItem {
    id: root

    readonly property bool inPanel: [
        PlasmaCore.Types.TopEdge,
        PlasmaCore.Types.RightEdge,
        PlasmaCore.Types.BottomEdge,
        PlasmaCore.Types.LeftEdge,
    ].includes(Plasmoid.location)

    // Portable path resolution for KDE Store installation & local development
    readonly property string helperPath: Qt.resolvedUrl("../scripts/numlock_helper.py").toString().replace(/^file:\/\//, "")
    readonly property string sddmScriptPath: Qt.resolvedUrl("../scripts/sync_sddm.sh").toString().replace(/^file:\/\//, "")

    // KeyState listener for root Plasmoid
    KeyboardIndicator.KeyState {
        id: numLockState
        key: Qt.Key_NumLock
    }

    readonly property bool numLockActive: numLockState.locked

    Plasmoid.icon: numLockActive ? "input-dialpad" : "input-keyboard"

    compactRepresentation: CompactRepresentation {
        plasmoidItem: root
    }

    fullRepresentation: FullRepresentation {
        plasmoidItem: root
    }

    // Executable Data Engine for external scripts and SDDM sync
    Plasma5Support.DataSource {
        id: executableSource
        engine: "executable"
        connectedSources: []

        onNewData: (sourceName, data) => {
            disconnectSource(sourceName)
        }

        function runCommand(cmd) {
            connectSource(cmd)
        }
    }

    // Toggle NumLock via uinput hardware simulation
    function toggleNumLock() {
        executableSource.runCommand("python3 " + root.helperPath + " --toggle")
    }

    // Force NumLock ON
    function forceNumLockOn() {
        if (!numLockActive) {
            toggleNumLock()
        }
        let notifyFlag = Plasmoid.configuration.showNotification ? " --notify" : ""
        executableSource.runCommand("python3 " + root.helperPath + " --enable" + notifyFlag)
    }

    // Force NumLock OFF
    function forceNumLockOff() {
        if (numLockActive) {
            toggleNumLock()
        }
        executableSource.runCommand("python3 " + root.helperPath + " --disable")
    }

    // Trigger SDDM Sync in terminal / GUI
    function runSddmSync() {
        executableSource.runCommand("konsole -e bash -c 'pkexec " + root.sddmScriptPath + " ; echo \"Pressione Enter para fechar...\"; read'")
    }

    // Startup check
    Timer {
        id: startupTimer
        interval: 800
        running: true
        repeat: false
        onTriggered: {
            if (Plasmoid.configuration.forceNumLockOnStartup && !numLockActive) {
                root.forceNumLockOn()
            }
        }
    }
}
