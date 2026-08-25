// File: Models/UserDataModels.swift
import Foundation
import SwiftData

@Model
final class FavoriteVerse {
    @Attribute(.unique) var verseID: String
    var translationID: String
    var bookName: String
    var chapter: Int
    var verse: Int
    var text: String
    var createdAt: Date

    init(verse: BibleVerse, createdAt: Date = .now) {
        self.verseID = verse.id
        self.translationID = verse.translationID
        self.bookName = verse.bookName
        self.chapter = verse.chapter
        self.verse = verse.number
        self.text = verse.text
        self.createdAt = createdAt
    }

    var reference: String { "\(bookName) \(chapter):\(verse)" }
}

@Model
final class BibleNote {
    var id: UUID
    var verseID: String
    var translationID: String
    var reference: String
    var text: String
    var createdAt: Date
    var updatedAt: Date

    init(verseID: String, translationID: String, reference: String, text: String, createdAt: Date = .now) {
        self.id = UUID()
        self.verseID = verseID
        self.translationID = translationID
        self.reference = reference
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = createdAt
    }
}

@Model
final class VerseHighlight {
    @Attribute(.unique) var verseID: String
    var colorName: String
    var createdAt: Date

    init(verseID: String, colorName: String, createdAt: Date = .now) {
        self.verseID = verseID
        self.colorName = colorName
        self.createdAt = createdAt
    }
}

@Model
final class ReadingHistoryEntry {
    var id: UUID
    var translationID: String
    var bookID: String
    var bookName: String
    var chapter: Int
    var readAt: Date

    init(translationID: String, bookID: String, bookName: String, chapter: Int, readAt: Date = .now) {
        self.id = UUID()
        self.translationID = translationID
        self.bookID = bookID
        self.bookName = bookName
        self.chapter = chapter
        self.readAt = readAt
    }

    var reference: String { "\(bookName) \(chapter)" }
}

@Model
final class SearchHistoryEntry {
    var id: UUID
    var query: String
    var searchedAt: Date

    init(query: String, searchedAt: Date = .now) {
        self.id = UUID()
        self.query = query
        self.searchedAt = searchedAt
    }
}

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

@Model
final class AppPreference {
    @Attribute(.unique) var key: String
    var value: String

    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

struct ChatMessage: Identifiable, Hashable {
    enum Role: String, Hashable {
        case user
        case assistant
        case system
    }

    let id: UUID
    let role: Role
    let text: String
    let references: [VerseReference]
    let createdAt: Date

    init(id: UUID = UUID(), role: Role, text: String, references: [VerseReference] = [], createdAt: Date = .now) {
        self.id = id
        self.role = role
        self.text = text
        self.references = references
        self.createdAt = createdAt
    }
}
