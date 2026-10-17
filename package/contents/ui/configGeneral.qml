import QtQuick
import "Translations.js" as Translations
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.components as PlasmaComponents3

KCM.SimpleKCM {
    id: configPage

    property alias cfg_language: languageComboBox.language

    property alias cfg_forceNumLockOnLock: forceOnLockCheckBox.checked
    property alias cfg_forceNumLockOnStartup: forceOnStartupCheckBox.checked
    property alias cfg_showNotification: showNotifyCheckBox.checked
    property alias cfg_showCapsLock: showCapsCheckBox.checked
    property alias cfg_showScrollLock: showScrollCheckBox.checked

    Plasma5Support.DataSource {
        id: executableSource
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => disconnectSource(sourceName)
    }

    Kirigami.FormLayout {
        anchors.fill: parent

        LanguageSelector {
            id: languageComboBox
            objectName: "languageComboBox"
            Kirigami.FormData.label: Translations.tr(configPage.cfg_language, "Idioma:")
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: Translations.tr(configPage.cfg_language, "Comportamento do Num Lock")
        }

        PlasmaComponents3.CheckBox {
            id: forceOnLockCheckBox
            Kirigami.FormData.label: Translations.tr(configPage.cfg_language, "Tela de Bloqueio:")
            text: Translations.tr(configPage.cfg_language, "Ativar automaticamente o Num Lock quando a tela for bloqueada")
        }

        PlasmaComponents3.CheckBox {
            id: forceOnStartupCheckBox
            Kirigami.FormData.label: Translations.tr(configPage.cfg_language, "Inicialização:")
            text: Translations.tr(configPage.cfg_language, "Garantir o Num Lock ativado ao iniciar a sessão do Plasma")
        }

        PlasmaComponents3.CheckBox {
            id: showNotifyCheckBox
            Kirigami.FormData.label: Translations.tr(configPage.cfg_language, "Notificações:")
            text: Translations.tr(configPage.cfg_language, "Exibir notificação popup ao forçar a ativação do Num Lock")
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: Translations.tr(configPage.cfg_language, "Aparência e Painel")
        }

        PlasmaComponents3.CheckBox {
            id: showCapsCheckBox
            Kirigami.FormData.label: Translations.tr(configPage.cfg_language, "Outras teclas:")
            text: Translations.tr(configPage.cfg_language, "Mostrar indicador de Caps Lock no painel quando ativo")
        }

        PlasmaComponents3.CheckBox {
            id: showScrollCheckBox
            text: Translations.tr(configPage.cfg_language, "Mostrar indicador de Scroll Lock no painel quando ativo")
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: Translations.tr(configPage.cfg_language, "Tela de Login Inicial (SDDM)")
        }

        PlasmaComponents3.Label {
            text: Translations.tr(configPage.cfg_language, "Para que o teclado numérico funcione antes mesmo de fazer login na máquina, execute o script de sincronização do SDDM.")
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            color: Kirigami.Theme.disabledTextColor
        }

        PlasmaComponents3.Button {
            text: Translations.tr(configPage.cfg_language, "Configurar SDDM Agora (requer sudo)")
            icon.name: "preferences-system-login"
            onClicked: {
                const scriptPath = Qt.resolvedUrl("../scripts/sync_sddm.sh").toString().replace(/^file:\/\//, "")
                executableSource.connectSource(Translations.sddmCommand(scriptPath, configPage.cfg_language))
            }
        }
    }
}
