pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.private.keyboardindicator as KeyboardIndicator

Item {
    id: compactRoot

    property PlasmoidItem plasmoidItem: null

    // Direct real-time KeyState listener
    KeyboardIndicator.KeyState {
        id: numLockState
        key: Qt.Key_NumLock
    }

    KeyboardIndicator.KeyState {
        id: capsLockState
        key: Qt.Key_CapsLock
    }

    KeyboardIndicator.KeyState {
        id: scrollLockState
        key: Qt.Key_ScrollLock
    }

    readonly property bool numLockOn: numLockState.locked
    readonly property bool capsLockOn: capsLockState.locked
    readonly property bool scrollLockOn: scrollLockState.locked

    Layout.minimumWidth: Kirigami.Units.iconSizes.smallMedium
    Layout.minimumHeight: Kirigami.Units.iconSizes.smallMedium
    Layout.preferredWidth: height
    Layout.preferredHeight: parent ? parent.height : Kirigami.Units.gridUnit * 2

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                if (compactRoot.plasmoidItem) {
                    compactRoot.plasmoidItem.expanded = !compactRoot.plasmoidItem.expanded
                } else {
                    plasmoid.expanded = !plasmoid.expanded
                }
            } else if (mouse.button === Qt.MiddleButton) {
                numLockState.lock(!numLockState.locked)
                if (compactRoot.plasmoidItem) {
                    compactRoot.plasmoidItem.toggleNumLock()
                }
            }
        }
    }

    QQC2.ToolTip.visible: mouseArea.containsMouse
    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
    QQC2.ToolTip.text: {
        let txt = i18n("Num Lock: %1", compactRoot.numLockOn ? i18n("ATIVADO") : i18n("DESATIVADO"))
        if (Plasmoid.configuration.showCapsLock) {
            txt += "\n" + i18n("Caps Lock: %1", compactRoot.capsLockOn ? i18n("ATIVADO") : i18n("DESATIVADO"))
        }
        txt += "\n" + i18n("(Clique esquerdo: Menu | Clique do meio: Alternar)")
        return txt
    }

    // Modern Sleek Keycap Container
    Item {
        id: iconContainer
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * 0.88
        height: width

        // Keycap Background
        Rectangle {
            id: keycap
            anchors.fill: parent
            radius: Math.max(4, width * 0.22)
            color: {
                if (mouseArea.pressed) {
                    return Kirigami.Theme.focusColor
                }
                if (mouseArea.containsMouse) {
                    return compactRoot.numLockOn ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.35)
                                                 : Qt.rgba(1, 1, 1, 0.15)
                }
                return compactRoot.numLockOn ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.22)
                                             : Qt.rgba(0, 0, 0, 0.3)
            }
            border.width: compactRoot.numLockOn ? 1.5 : 1.0
            border.color: {
                if (compactRoot.numLockOn) {
                    return Kirigami.Theme.highlightColor
                }
                return mouseArea.containsMouse ? Kirigami.Theme.textColor : Qt.rgba(1, 1, 1, 0.25)
            }

            Behavior on color {
                ColorAnimation { duration: 120 }
            }
            Behavior on border.color {
                ColorAnimation { duration: 120 }
            }

            // Dialpad / Numeric Grid Sub-icon + "1" Text
            RowLayout {
                anchors.centerIn: parent
                spacing: Math.max(2, keycap.width * 0.06)

                // 3x2 Matrix of mini-dots representing numeric keypad
                GridLayout {
                    columns: 2
                    rowSpacing: Math.max(1.5, keycap.width * 0.04)
                    columnSpacing: Math.max(1.5, keycap.width * 0.04)

                    Repeater {
                        model: 6
                        Rectangle {
                            width: Math.max(2, keycap.width * 0.08)
                            height: width
                            radius: width / 2
                            color: compactRoot.numLockOn ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                            opacity: compactRoot.numLockOn ? 0.95 : 0.4
                        }
                    }
                }

                // NUM / 1 Text Label
                Text {
                    text: "1"
                    font.bold: true
                    font.pixelSize: Math.max(10, keycap.width * 0.46)
                    color: compactRoot.numLockOn ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor
                    opacity: compactRoot.numLockOn ? 1.0 : 0.5
                }
            }

            // Glowing Active LED in top-right corner
            Rectangle {
                id: ledIndicator
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: Math.max(2, parent.width * 0.08)
                anchors.rightMargin: Math.max(2, parent.width * 0.08)
                width: Math.max(4, parent.width * 0.20)
                height: width
                radius: width / 2

                color: compactRoot.numLockOn ? "#2ecc71" : "#505559"
                border.width: 0.5
                border.color: compactRoot.numLockOn ? "#ffffff" : "transparent"

                // Glow ring when active
                Rectangle {
                    visible: compactRoot.numLockOn
                    anchors.centerIn: parent
                    width: parent.width * 2.0
                    height: width
                    radius: width / 2
                    color: "#2ecc71"
                    opacity: 0.35
                    z: -1
                }
            }

            // Optional CapsLock Warning Dot in top-left corner
            Rectangle {
                visible: Plasmoid.configuration.showCapsLock && compactRoot.capsLockOn
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: Math.max(2, parent.width * 0.08)
                anchors.leftMargin: Math.max(2, parent.width * 0.08)
                width: Math.max(3, parent.width * 0.15)
                height: width
                radius: width / 2
                color: "#e67e22"
            }
        }
    }
}
