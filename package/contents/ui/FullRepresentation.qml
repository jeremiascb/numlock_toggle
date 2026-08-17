pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid
import org.kde.plasma.private.keyboardindicator as KeyboardIndicator

PlasmaExtras.Representation {
    id: fullRoot

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

    Layout.minimumWidth: Kirigami.Units.gridUnit * 18
    Layout.minimumHeight: Kirigami.Units.gridUnit * 17
    Layout.preferredWidth: Kirigami.Units.gridUnit * 21
    Layout.preferredHeight: Kirigami.Units.gridUnit * 18

    header: PlasmaExtras.PlasmoidHeading {
        RowLayout {
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: "input-dialpad"
                Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                Layout.preferredHeight: Layout.preferredWidth
                color: fullRoot.numLockOn ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.highlightColor
            }

            PlasmaComponents3.Label {
                text: i18n("Num Lock Auto Locker")
                font.bold: true
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            PlasmaComponents3.ToolButton {
                icon.name: "configure"
                text: i18n("Configurações")
                display: PlasmaComponents3.AbstractButton.IconOnly
                onClicked: plasmoid.action("configure").trigger()
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: Kirigami.Units.mediumSpacing

        // Main NumLock Card with Balanced Margins & Padding
        Kirigami.Card {
            Layout.fillWidth: true

            contentItem: RowLayout {
                spacing: Kirigami.Units.mediumSpacing

                Kirigami.Icon {
                    source: "input-dialpad"
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Layout.preferredWidth
                    Layout.alignment: Qt.AlignVCenter
                    color: fullRoot.numLockOn ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.disabledTextColor
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: Kirigami.Units.smallSpacing * 0.4

                    PlasmaComponents3.Label {
                        text: i18n("Teclado Numérico (Num Lock)")
                        font.bold: true
                        font.pixelSize: Kirigami.Units.gridUnit * 0.82
                        Layout.fillWidth: true
                    }

                    PlasmaComponents3.Label {
                        text: fullRoot.numLockOn ? i18n("Ativado e pronto para uso") : i18n("Desativado")
                        color: fullRoot.numLockOn ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.disabledTextColor
                        font.pixelSize: Kirigami.Units.gridUnit * 0.72
                        Layout.fillWidth: true
                    }
                }

                PlasmaComponents3.Switch {
                    id: numLockSwitch
                    checked: fullRoot.numLockOn
                    Layout.alignment: Qt.AlignVCenter
                    onToggled: {
                        if (fullRoot.plasmoidItem) {
                            fullRoot.plasmoidItem.toggleNumLock()
                        }
                    }
                }
            }
        }

        // Secondary Keys Status (Caps Lock & Scroll Lock)
        Kirigami.Card {
            Layout.fillWidth: true

            contentItem: ColumnLayout {
                spacing: Kirigami.Units.smallSpacing

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.Icon {
                        source: "arrow-up"
                        Layout.preferredWidth: Kirigami.Units.iconSizes.small
                        Layout.preferredHeight: Layout.preferredWidth
                        color: fullRoot.capsLockOn ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                    }
                    PlasmaComponents3.Label {
                        text: i18n("Caps Lock (Maiúsculas):")
                        font.pixelSize: Kirigami.Units.gridUnit * 0.75
                        Layout.fillWidth: true
                    }
                    PlasmaComponents3.Label {
                        text: fullRoot.capsLockOn ? i18n("LIGADO") : i18n("DESLIGADO")
                        font.bold: true
                        font.pixelSize: Kirigami.Units.gridUnit * 0.72
                        color: fullRoot.capsLockOn ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                    }
                }

                QQC2.MenuSeparator {
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.Icon {
                        source: "format-list-ordered"
                        Layout.preferredWidth: Kirigami.Units.iconSizes.small
                        Layout.preferredHeight: Layout.preferredWidth
                        color: fullRoot.scrollLockOn ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                    }
                    PlasmaComponents3.Label {
                        text: i18n("Scroll Lock:")
                        font.pixelSize: Kirigami.Units.gridUnit * 0.75
                        Layout.fillWidth: true
                    }
                    PlasmaComponents3.Label {
                        text: fullRoot.scrollLockOn ? i18n("LIGADO") : i18n("DESLIGADO")
                        font.bold: true
                        font.pixelSize: Kirigami.Units.gridUnit * 0.72
                        color: fullRoot.scrollLockOn ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                    }
                }
            }
        }

        // Screen Lock Automation Status with Clean Spacing
        Kirigami.Card {
            Layout.fillWidth: true

            contentItem: ColumnLayout {
                spacing: Kirigami.Units.smallSpacing * 0.75

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.Icon {
                        source: "system-lock-screen"
                        Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                        Layout.preferredHeight: Layout.preferredWidth
                        color: Kirigami.Theme.highlightColor
                    }
                    PlasmaComponents3.Label {
                        text: i18n("Automação de Bloqueio")
                        font.bold: true
                        font.pixelSize: Kirigami.Units.gridUnit * 0.8
                        Layout.fillWidth: true
                    }
                }

                QQC2.MenuSeparator {
                    Layout.fillWidth: true
                }

                PlasmaComponents3.CheckBox {
                    text: i18n("Forçar Num Lock ao bloquear a tela")
                    checked: Plasmoid.configuration.forceNumLockOnLock
                    Layout.fillWidth: true
                    onToggled: {
                        Plasmoid.configuration.forceNumLockOnLock = checked
                    }
                }

                PlasmaComponents3.CheckBox {
                    text: i18n("Forçar Num Lock na inicialização da sessão")
                    checked: Plasmoid.configuration.forceNumLockOnStartup
                    Layout.fillWidth: true
                    onToggled: {
                        Plasmoid.configuration.forceNumLockOnStartup = checked
                    }
                }
            }
        }

        // Footer Action
        PlasmaComponents3.Button {
            text: i18n("Sincronizar com SDDM (Login)")
            icon.name: "preferences-system-login"
            Layout.fillWidth: true
            onClicked: {
                if (fullRoot.plasmoidItem) {
                    fullRoot.plasmoidItem.runSddmSync()
                }
            }
        }
    }
}
