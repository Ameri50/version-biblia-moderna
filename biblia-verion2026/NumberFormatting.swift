import Foundation
import SwiftUI

// MARK: - Extensión para formatear números según idioma
extension Double {
    /// Formatea un número como porcentaje según el idioma actual
    func formatAsPercentage() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        
        // Detectar idioma actual
        let currentLanguage = LanguageManager.shared.currentLanguage
        
        if currentLanguage == "es" {
            formatter.locale = Locale(identifier: "es_ES")
        } else if currentLanguage == "en" {
            formatter.locale = Locale(identifier: "en_US")
        }
        
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    
    /// Formatea un número normal según el idioma actual
    func formatAsNumber() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        let currentLanguage = LanguageManager.shared.currentLanguage
        
        if currentLanguage == "es" {
            formatter.locale = Locale(identifier: "es_ES")
        } else if currentLanguage == "en" {
            formatter.locale = Locale(identifier: "en_US")
        }
        
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    
    /// Formatea un número como moneda
    func formatAsCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        let currentLanguage = LanguageManager.shared.currentLanguage
        
        if currentLanguage == "es" {
            formatter.locale = Locale(identifier: "es_ES")
            formatter.currencyCode = "EUR" // Puedes cambiar a "USD", "MXN", etc.
        } else if currentLanguage == "en" {
            formatter.locale = Locale(identifier: "en_US")
            formatter.currencyCode = "USD"
        }
        
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - Extensión para Int
extension Int {
    func formatAsNumber() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        let currentLanguage = LanguageManager.shared.currentLanguage
        
        if currentLanguage == "es" {
            formatter.locale = Locale(identifier: "es_ES")
        } else if currentLanguage == "en" {
            formatter.locale = Locale(identifier: "en_US")
        }
        
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - Ejemplo de uso en SwiftUI
/*
 Ejemplos de cómo usar en tu código:
 
 Text(0.50.formatAsPercentage())  // 50% o 50,0% según idioma
 Text(1234.56.formatAsNumber())   // 1,234.56 o 1.234,56 según idioma
 Text(99.99.formatAsCurrency())   // $99.99 o 99,99€ según idioma
 Text(42.formatAsNumber())        // 42 en cualquier idioma
 */
