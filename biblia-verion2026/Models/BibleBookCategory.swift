// File: Models/BibleBookCategory.swift
import SwiftUI

enum BibleBookCategory: String, CaseIterable, Identifiable {
    case pentateuco
    case historicos
    case poeticos
    case profetasMayores
    case profetasMenores
    case evangelios
    case historiaNT
    case cartasPablo
    case hebreos
    case cartasGenerales
    case profecia

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pentateuco: return "Pentateuco"
        case .historicos: return "Libros historicos"
        case .poeticos: return "Poeticos y sapienciales"
        case .profetasMayores: return "Profetas mayores"
        case .profetasMenores: return "Profetas menores"
        case .evangelios: return "Evangelios"
        case .historiaNT: return "Historia"
        case .cartasPablo: return "Cartas de Pablo"
        case .hebreos: return "Hebreos"
        case .cartasGenerales: return "Cartas generales"
        case .profecia: return "Profecia"
        }
    }

    var testament: BibleTestament {
        switch self {
        case .pentateuco, .historicos, .poeticos, .profetasMayores, .profetasMenores:
            return .old
        case .evangelios, .historiaNT, .cartasPablo, .hebreos, .cartasGenerales, .profecia:
            return .new
        }
    }

    var emoji: String {
        switch self {
        case .pentateuco, .evangelios: return "🟢"
        case .historicos, .historiaNT: return "🟡"
        case .poeticos, .cartasPablo: return "🔵"
        case .profetasMayores, .hebreos: return "🟣"
        case .profetasMenores, .cartasGenerales: return "🟠"
        case .profecia: return "🔴"
        }
    }

    var color: Color {
        switch self {
        case .pentateuco, .evangelios: return .green
        case .historicos, .historiaNT: return .yellow
        case .poeticos, .cartasPablo: return .blue
        case .profetasMayores, .hebreos: return .purple
        case .profetasMenores, .cartasGenerales: return .orange
        case .profecia: return .red
        }
    }

    /// El orden en que se deben mostrar las secciones en el selector.
    static let displayOrder: [BibleBookCategory] = [
        .pentateuco, .historicos, .poeticos, .profetasMayores, .profetasMenores,
        .evangelios, .historiaNT, .cartasPablo, .hebreos, .cartasGenerales, .profecia
    ]

    /// Clasifica un libro segun su numero de orden canonico (1...66, RV1909 / canon protestante estandar).
    /// Genesis=1 ... Apocalipsis=66, el mismo orden que usa BibleResourceInstaller (01.content.json...66.content.json).
    static func forOrder(_ order: Int) -> BibleBookCategory {
        switch order {
        case 1...5: return .pentateuco
        case 6...17: return .historicos
        case 18...22: return .poeticos
        case 23...27: return .profetasMayores
        case 28...39: return .profetasMenores
        case 40...43: return .evangelios
        case 44: return .historiaNT
        case 45...57: return .cartasPablo
        case 58: return .hebreos
        case 59...65: return .cartasGenerales
        default: return .profecia // 66 (Apocalipsis) y cualquier valor fuera de rango
        }
    }
}

extension BibleBook {
    var category: BibleBookCategory { BibleBookCategory.forOrder(order) }
}
