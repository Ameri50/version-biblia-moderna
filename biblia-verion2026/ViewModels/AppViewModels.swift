// File: ViewModels/AppViewModels.swift
import Foundation
import SwiftData

@MainActor
final class AppEnvironment: ObservableObject {
    let bibleRepository: BibleRepositoryProtocol
    let searchService: BibleSearchServiceProtocol
    let aiService: AIServiceProtocol

    @Published var selectedTranslationID: String
    @Published var appLanguageCode = "es"
    @Published var selectedBookID = "john"
    @Published var selectedChapter = 3
    @Published var fontSize: Double = 19
    @Published var lineSpacing: Double = 7
    @Published var showVerseNumbers = true
    @Published var aiEnabled = true
    @Published var colorSchemePreference = "system"

    init(
        bibleRepository: BibleRepositoryProtocol = DemoBibleRepository.shared,
        searchService: BibleSearchServiceProtocol? = nil,
        aiService: AIServiceProtocol = AIServiceFactory.makeService()
    ) {
        self.bibleRepository = bibleRepository
        self.searchService = searchService ?? BibleSearchService(repository: bibleRepository)
        self.aiService = aiService
        self.selectedTranslationID = bibleRepository.translations.first?.id ?? "demo-es"
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
final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [BibleSearchResult] = []

    func submit(using environment: AppEnvironment, modelContext: ModelContext?) {
        results = environment.searchService.search(query, translationID: environment.selectedTranslationID)
        if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            modelContext?.insert(SearchHistoryEntry(query: query))
        }
    }
}

@MainActor
final class AIViewModel: ObservableObject {
    @Published var input = ""
    @Published var messages: [ChatMessage] = [
        ChatMessage(role: .assistant, text: "Haz una pregunta sobre la Biblia. Las respuestas usaran primero los pasajes locales disponibles.")
    ]
    @Published var isLoading = false
    @Published var errorMessage: String?

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
