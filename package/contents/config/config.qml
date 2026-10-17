import QtQuick
import org.kde.plasma.plasmoid
import "../ui/Translations.js" as Translations
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: Translations.tr(Plasmoid.configuration.language, "Geral")
        icon: "preferences-desktop-keyboard"
        source: "configGeneral.qml"
    }
}
