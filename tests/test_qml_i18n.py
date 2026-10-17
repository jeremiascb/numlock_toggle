import os
from pathlib import Path
import unittest

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
os.environ.setdefault("QT_QUICK_CONTROLS_STYLE", "Basic")

try:
    from PySide6.QtCore import QObject, QUrl
    from PySide6.QtGui import QGuiApplication
    from PySide6.QtQml import QQmlComponent, QQmlEngine, QQmlPropertyMap
except ImportError:
    QGuiApplication = None


@unittest.skipIf(QGuiApplication is None, "PySide6 is required for QML integration tests")
class QmlLanguageTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.app = QGuiApplication.instance() or QGuiApplication([])

    def test_selection_is_saved_and_updates_bound_interface_text(self):
        engine = QQmlEngine()
        configuration = QQmlPropertyMap()
        configuration.insert("language", "pt_BR")
        engine.rootContext().setContextProperty("configuration", configuration)
        component = QQmlComponent(engine)
        directory = Path(__file__).resolve().parents[1] / "package/contents/ui"
        source = b'''
import QtQuick
import "Translations.js" as Translations
Item {
    id: root
    property alias cfg_language: selector.language
    readonly property string language: Translations.normalizeLanguage(configuration.language)
    readonly property string panelText: Translations.tr(root.language, "Configura\\u00e7\\u00f5es")
    LanguageSelector {
        id: selector
        objectName: "selector"
        language: configuration.language
    }
}
'''
        component.setData(source, QUrl.fromLocalFile(str(directory / "LanguageTest.qml")))
        self.assertFalse(component.isError(), str(component.errors()))
        root = component.create()
        self.assertIsNotNone(root, str(component.errors()))
        selector = root.findChild(QObject, "selector")
        for index, language, label in ((0, "en", "Settings"), (1, "pt_PT", "Definições"),
                                       (2, "pt_BR", "Configurações"), (3, "es", "Configuración")):
            with self.subTest(language=language):
                selector.activated.emit(index)
                self.assertEqual(root.property("cfg_language"), language)
                # Plasma's Apply action copies cfg_language into its property map.
                configuration.insert("language", root.property("cfg_language"))
                self.assertEqual(root.property("panelText"), label)
                self.assertEqual(selector.property("currentIndex"), index)
        root.deleteLater()

    def test_default_is_english(self):
        engine = QQmlEngine()
        component = QQmlComponent(engine, QUrl.fromLocalFile(str(
            Path(__file__).resolve().parents[1] / "package/contents/ui/LanguageSelector.qml"
        )))
        selector = component.create()
        self.assertIsNotNone(selector, str(component.errors()))
        self.assertEqual(selector.property("language"), "en")
        self.assertEqual(selector.property("currentIndex"), 0)
        selector.deleteLater()


if __name__ == "__main__":
    unittest.main()
