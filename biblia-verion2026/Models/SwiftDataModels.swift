// File: Models/SwiftDataModels.swift
import Foundation
import SwiftData

// MARK: - Versículo Favorito
@Model
final class FavoriteVerse {
    @Attribute(.unique) var id: String
    var reference: String // "Juan 3:16"
    var bookName: String
    var content: String
    var dateAdded: Date
    
    init(id: String, reference: String, bookName: String, content: String, dateAdded: Date = Date()) {
        self.id = id
        self.reference = reference
        self.bookName = bookName
        self.content = content
        self.dateAdded = dateAdded
    }
}

// MARK: - Nota Bíblica
@Model
final class BibleNote {
    @Attribute(.unique) var id: String
    var reference: String
    var bookName: String
    var noteContent: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String, reference: String, bookName: String, noteContent: String, createdAt: Date = Date()) {
        self.id = id
        self.reference = reference
        self.bookName = bookName
        self.noteContent = noteContent
        self.createdAt = createdAt
        self.updatedAt = Date()
    }
}

// MARK: - Versículo Resaltado
@Model
final class VerseHighlight {
    @Attribute(.unique) var id: String
    var reference: String
    var bookName: String
    var content: String
    var colorHex: String // "#FF9500" para naranja, etc.
    var dateAdded: Date
    
    init(id: String, reference: String, bookName: String, content: String, colorHex: String, dateAdded: Date = Date()) {
        self.id = id
        self.reference = reference
        self.bookName = bookName
        self.content = content
        self.colorHex = colorHex
        self.dateAdded = dateAdded
    }
}

// MARK: - Entrada de Historial de Lectura
@Model
final class ReadingHistoryEntry {
    @Attribute(.unique) var id: String
    var chapterReference: String // "Génesis 1"
    var bookName: String
    var date: Date
    
    init(id: String, chapterReference: String, bookName: String, date: Date = Date()) {
        self.id = id
        self.chapterReference = chapterReference
        self.bookName = bookName
        self.date = date
    }
}

// MARK: - Entrada de Historial de Búsqueda
@Model
final class SearchHistoryEntry {
    @Attribute(.unique) var id: String
    var query: String
    var resultsCount: Int
    var timestamp: Date
    
    init(id: String, query: String, resultsCount: Int, timestamp: Date = Date()) {
        self.id = id
        self.query = query
        self.resultsCount = resultsCount
        self.timestamp = timestamp
    }
}

// MARK: - Pregunta IA Historial
@Model
final class AIQuestionHistoryEntry {
    var id: UUID
    var question: String
    var askedAt: Date

    init(question: String, askedAt: Date = .now) {
        self.id = UUID()
        self.question = question
        self.askedAt = askedAt
    }
}

// MARK: - Preferencia de la App
@Model
final class AppPreference {
    @Attribute(.unique) var key: String
    var value: String
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}
