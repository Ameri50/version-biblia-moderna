import Foundation
import SwiftUI
import Combine

class LanguageManager: ObservableObject {
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "AppLanguage")
            Bundle.setLanguage(currentLanguage)
            
            // Forzar actualización de la UI
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
            }
        }
    }
    
    static let shared = LanguageManager()
    
    init() {
        let saved = UserDefaults.standard.string(forKey: "AppLanguage") ?? "es"
        self.currentLanguage = saved
        Bundle.setLanguage(saved)
    }
    
    func setLanguage(_ language: String) {
        currentLanguage = language
    }
    
    func getLanguages() -> [String: String] {
        return ["es": "Español", "en": "English"]
    }
}

// MARK: - Extensión de Bundle para soporte de múltiples idiomas
extension Bundle {
    private static var language: String?
    
    static func setLanguage(_ language: String) {
        Bundle.language = language
    }
    
    static func localizedString(forKey key: String, value: String? = nil, table tableName: String? = nil) -> String {
        let path = Bundle.main.path(forResource: Bundle.language ?? "es", ofType: "lproj")
        guard let bundlePath = path else {
            return Bundle.main.localizedString(forKey: key, value: value, table: tableName)
        }
        let bundle = Bundle(path: bundlePath) ?? Bundle.main
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

// MARK: - Función auxiliar para usar en toda la app (CON DICCIONARIO)
func NSLocalizedString(_ key: String, _ comment: String = "") -> String {
    let language = LanguageManager.shared.currentLanguage
    
    let translations: [String: [String: String]] = [
        "es": [
            // Tabs principales
            "tab.bible": "Biblia",
            "tab.search": "Buscar",
            "tab.favorites": "Favoritos",
            "tab.notes": "Notas",
            "tab.highlights": "Resaltados",
            "tab.ai": "IA",
            "tab.more": "Más",
            
            // Favoritos
            "favorites.title": "❤️ Favoritos",
            "favorites.subtitle": "versículos guardados",
            "favorites.empty.title": "Sin favoritos",
            "favorites.empty.subtitle": "Guarda tus versículos favoritos",
            
            // Notas
            "notes.title": "📝 Notas",
            "notes.subtitle": "notas creadas",
            "notes.empty.title": "Sin notas",
            "notes.empty.subtitle": "Crea notas sobre versículos",
            
            // Resaltados
            "highlights.title": "🟨 Resaltados",
            "highlights.subtitle": "versículos resaltados",
            "highlights.empty.title": "Sin resaltados",
            "highlights.empty.subtitle": "Resalta versículos importantes",
            
            // Más
            "more.title": "⚙️ Más",
            "more.subtitle": "Configuración y más",
            "more.settings": "Configuración",
            "more.settings.subtitle": "Ajustes de la aplicación",
            "more.history": "Historial de Lectura",
            "more.history.subtitle": "capítulos leídos",
            "more.search.history": "Historial de Búsqueda",
            "more.search.history.subtitle": "Tus búsquedas anteriores",
            "more.about": "Acerca de",
            "more.about.subtitle": "Biblia Reina Valera 1909 v1.0",
            
            // Configuración
            "settings.title": "Configuración",
            "settings.language": "Idioma",
            "settings.spanish": "Español",
            "settings.english": "English",
            
            // IA / Chat
            "ai.title": "Preguntar a IA",
            "ai.placeholder": "Pregunta sobre la Biblia...",
            "ai.thinking": "Pensando...",
            "ai.disabled": "La IA está desactivada en Ajustes.",
            "ai.error": "Lo siento, hubo un error al obtener la respuesta. Por favor, intenta de nuevo.",
            
            // General
            "history.no.results": "Sin historial",
            "search.no.results": "Sin búsquedas",
        ],
        "en": [
            // Main Tabs
            "tab.bible": "Bible",
            "tab.search": "Search",
            "tab.favorites": "Favorites",
            "tab.notes": "Notes",
            "tab.highlights": "Highlights",
            "tab.ai": "AI",
            "tab.more": "More",
            
            // Favorites
            "favorites.title": "❤️ Favorites",
            "favorites.subtitle": "saved verses",
            "favorites.empty.title": "No favorites",
            "favorites.empty.subtitle": "Save your favorite verses",
            
            // Notes
            "notes.title": "📝 Notes",
            "notes.subtitle": "notes created",
            "notes.empty.title": "No notes",
            "notes.empty.subtitle": "Create notes about verses",
            
            // Highlights
            "highlights.title": "🟨 Highlights",
            "highlights.subtitle": "highlighted verses",
            "highlights.empty.title": "No highlights",
            "highlights.empty.subtitle": "Highlight important verses",
            
            // More
            "more.title": "⚙️ More",
            "more.subtitle": "Settings and more",
            "more.settings": "Settings",
            "more.settings.subtitle": "Application settings",
            "more.history": "Reading History",
            "more.history.subtitle": "chapters read",
            "more.search.history": "Search History",
            "more.search.history.subtitle": "Your previous searches",
            "more.about": "About",
            "more.about.subtitle": "Bible Reina Valera 1909 v1.0",
            
            // Settings
            "settings.title": "Settings",
            "settings.language": "Language",
            "settings.spanish": "Spanish",
            "settings.english": "English",
            
            // AI / Chat
            "ai.title": "Ask AI",
            "ai.placeholder": "Ask about the Bible...",
            "ai.thinking": "Thinking...",
            "ai.disabled": "AI is disabled in Settings.",
            "ai.error": "Sorry, there was an error getting the response. Please try again.",
            
            // General
            "history.no.results": "No history",
            "search.no.results": "No searches",
        ]
    ]
    
    return translations[language]?[key] ?? key
}
