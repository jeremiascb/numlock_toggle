import QtQuick
import QtQuick.Controls as QQC2
import "Translations.js" as Translations

QQC2.ComboBox {
    id: selector

    property string language: "en"

    model: Translations.languageNames
    currentIndex: Translations.languageCodes.indexOf(Translations.normalizeLanguage(selector.language))
    onActivated: index => selector.language = Translations.languageCodes[index]
}
