// File: ViewModels/AppViewModels.swift
import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class AppEnvironment {
    let bibleRepository: BibleRepositoryProtocol
    let searchService: BibleSearchServiceProtocol
    let aiService: AIServiceProtocol

    var selectedTranslationID: String
    var appLanguageCode = "es"
    var selectedBookID = "john"
    var selectedChapter = 3
    var fontSize: Double = 19
    var lineSpacing: Double = 7
    var showVerseNumbers = true
    var aiEnabled = true
    var colorSchemePreference = "system"

    init(
        bibleRepository: BibleRepositoryProtocol? = nil,
        searchService: BibleSearchServiceProtocol? = nil,
        aiService: AIServiceProtocol? = nil
    ) {
        let resolvedRepository = bibleRepository ?? BibleRepositoryFactory.makeDefault()
        self.bibleRepository = resolvedRepository
        self.searchService = searchService ?? BibleSearchService(repository: resolvedRepository)
        self.aiService = aiService ?? AIServiceFactory.makeService()
        self.selectedTranslationID = resolvedRepository.translations.first?.id ?? "demo-es"
    }

    var currentTranslation: BibleTranslation? {
        bibleRepository.translations.first { $0.id == selectedTranslationID }
    }

    var books: [BibleBook] {
        bibleRepository.books(for: selectedTranslationID)
    }

    var currentChapter: BibleChapter? {
        bibleRepository.chapter(translationID: selectedTranslationID, bookID: selectedBookID, chapter: selectedChapter)
    }

    func open(_ reference: VerseReference) {
        selectedTranslationID = reference.translationID
        selectedBookID = reference.bookID
        selectedChapter = reference.chapter
    }
}

@MainActor
@Observable
final class SearchViewModel {
    var query = ""
    var results: [BibleSearchResult] = []

    func submit(using environment: AppEnvironment, modelContext: ModelContext?) {
        let found = environment.searchService.search(query, translationID: environment.selectedTranslationID)
        results = found
        if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let entry = SearchHistoryEntry(id: UUID().uuidString, query: query, resultsCount: found.count)
            modelContext?.insert(entry)
        }
    }
}

@MainActor
@Observable
final class AIViewModel {
    var input = ""
    var messages: [ChatMessage] = [
        ChatMessage(role: .assistant, text: "Haz una pregunta sobre la Biblia. Las respuestas usaran primero los pasajes locales disponibles.")
    ]
    var isLoading = false
    var errorMessage: String?

    func ask(using environment: AppEnvironment, modelContext: ModelContext?) async {
        let question = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, !isLoading else { return }
        input = ""
        messages.append(ChatMessage(role: .user, text: question))
        modelContext?.insert(AIQuestionHistoryEntry(question: question))

        guard environment.aiEnabled else {
            messages.append(ChatMessage(role: .assistant, text: "La IA esta desactivada en Ajustes. Puedes seguir leyendo y buscando la Biblia sin Internet."))
            return
        }

        let localResults = environment.searchService.search(question, translationID: environment.selectedTranslationID).prefix(6)
        let context = localResults.map { "\($0.verse.reference): \($0.verse.text)" }.joined(separator: "\n")
        let references = localResults.map {
            VerseReference(translationID: $0.verse.translationID, bookID: $0.verse.bookID, bookName: $0.verse.bookName, chapter: $0.verse.chapter, verse: $0.verse.number)
        }

        isLoading = true
        defer { isLoading = false }
        do {
            let answer = try await environment.aiService.generateResponse(prompt: question, context: context)
            messages.append(ChatMessage(role: .assistant, text: answer, references: references))
        } catch {
            errorMessage = error.localizedDescription
            messages.append(ChatMessage(role: .assistant, text: error.localizedDescription, references: references))
        }
    }

    func askAbout(_ verse: BibleVerse) {
        input = "Estoy leyendo \(verse.reference). Explicame este versiculo."
    }
}
