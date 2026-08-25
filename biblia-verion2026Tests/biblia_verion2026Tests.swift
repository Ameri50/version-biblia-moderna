// File: biblia-verion2026Tests/biblia_verion2026Tests.swift
import Testing
@testable import biblia_verion2026

struct biblia_verion2026Tests {
    @Test func searchFindsReference() async throws {
        let repository = DemoBibleRepository()
        let search = BibleSearchService(repository: repository)
        let results = search.search("Juan 3:16", translationID: repository.translations.first?.id)
        #expect(results.first?.verse.reference == "Juan 3:16")
    }

    @Test func searchFindsWord() async throws {
        let repository = DemoBibleRepository()
        let search = BibleSearchService(repository: repository)
        let results = search.search("amor", translationID: repository.translations.first?.id)
        #expect(results.contains { $0.verse.reference == "Juan 3:16" })
    }

    @Test func promptIncludesContextAndQuestion() async throws {
        let prompt = GeminiPromptBuilder.buildPrompt(userPrompt: "Que dice?", context: "Juan 3:16: Texto", languageCode: "es")
        #expect(prompt.contains("Juan 3:16"))
        #expect(prompt.contains("Que dice?"))
    }

    @Test func mockAIServiceReturnsResponse() async throws {
        let service = MockAIService(response: "Respuesta con referencias")
        let response = try await service.generateResponse(prompt: "Pregunta", context: "Contexto")
        #expect(response == "Respuesta con referencias")
    }
}

private final class MockAIService: AIServiceProtocol {
    let response: String

    init(response: String) {
        self.response = response
    }

    func generateResponse(prompt: String, context: String?) async throws -> String {
        response
    }
}
