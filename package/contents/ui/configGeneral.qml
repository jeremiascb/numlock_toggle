import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.components as PlasmaComponents3

KCM.SimpleKCM {
    id: configPage

    property alias cfg_forceNumLockOnLock: forceOnLockCheckBox.checked
    property alias cfg_forceNumLockOnStartup: forceOnStartupCheckBox.checked
    property alias cfg_showNotification: showNotifyCheckBox.checked
    property alias cfg_showCapsLock: showCapsCheckBox.checked
    property alias cfg_showScrollLock: showScrollCheckBox.checked

    Kirigami.FormLayout {
        anchors.fill: parent

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Comportamento do Num Lock")
        }

        PlasmaComponents3.CheckBox {
            id: forceOnLockCheckBox
            Kirigami.FormData.label: i18n("Tela de Bloqueio:")
            text: i18n("Ativar automaticamente o Num Lock quando a tela for bloqueada")
        }

        PlasmaComponents3.CheckBox {
            id: forceOnStartupCheckBox
            Kirigami.FormData.label: i18n("Inicialização:")
            text: i18n("Garantir o Num Lock ativado ao iniciar a sessão do Plasma")
        }

        PlasmaComponents3.CheckBox {
            id: showNotifyCheckBox
            Kirigami.FormData.label: i18n("Notificações:")
            text: i18n("Exibir notificação popup ao forçar a ativação do Num Lock")
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Aparência e Painel")
        }

        PlasmaComponents3.CheckBox {
            id: showCapsCheckBox
            Kirigami.FormData.label: i18n("Outras teclas:")
            text: i18n("Mostrar indicador de Caps Lock no painel quando ativo")
        }

        PlasmaComponents3.CheckBox {
            id: showScrollCheckBox
            text: i18n("Mostrar indicador de Scroll Lock no painel quando ativo")
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Tela de Login Inicial (SDDM)")
        }

        PlasmaComponents3.Label {
            text: i18n("Para que o teclado numérico funcione antes mesmo de fazer login na máquina, execute o script de sincronização do SDDM.")
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            color: Kirigami.Theme.disabledTextColor
        }

        PlasmaComponents3.Button {
            text: i18n("Configurar SDDM Agora (requer sudo)")
            icon.name: "preferences-system-login"
            onClicked: {
                if (plasmoid.rootItem) {
                    plasmoid.rootItem.runSddmSync()
                }
            }
        }
    }
}
