// File: Models/BibleModels.swift
import Foundation

enum BibleTestament: String, Codable, CaseIterable, Identifiable {
    case old = "old_testament"
    case new = "new_testament"

    var id: String { rawValue }
}

struct BibleTranslation: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let languageCode: String
    let abbreviation: String
    let licenseSummary: String
    let isDownloaded: Bool
}

struct BibleBook: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let testament: BibleTestament
    let order: Int
    let chapters: [BibleChapter]
}

struct BibleChapter: Identifiable, Codable, Hashable {
    let id: String
    let bookID: String
    let bookName: String
    let number: Int
    let verses: [BibleVerse]
}

struct BibleVerse: Identifiable, Codable, Hashable {
    let id: String
    let translationID: String
    let bookID: String
    let bookName: String
    let chapter: Int
    let number: Int
    let text: String

    var reference: String {
        "\(bookName) \(chapter):\(number)"
    }
}

struct VerseReference: Identifiable, Codable, Hashable {
    let translationID: String
    let bookID: String
    let bookName: String
    let chapter: Int
    let verse: Int?

    var id: String {
        "\(translationID)-\(bookID)-\(chapter)-\(verse ?? 0)"
    }

    var displayText: String {
        if let verse {
            return "\(bookName) \(chapter):\(verse)"
        }
        return "\(bookName) \(chapter)"
    }
}

struct BibleSearchResult: Identifiable, Hashable {
    let id: String
    let verse: BibleVerse
    let translation: BibleTranslation
    let relevance: Double
}

struct BibleImportFile: Codable {
    let translation: BibleTranslation
    let books: [BibleBook]
}
