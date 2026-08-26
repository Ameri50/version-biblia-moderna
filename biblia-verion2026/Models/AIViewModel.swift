import SwiftData
import SwiftUI
import Foundation

@Observable
class AIViewModel {
    var messages: [ChatMessage] = []
    var input: String = ""
    var isLoading: Bool = false

    func ask(using appEnvironment: AppEnvironment, modelContext: ModelContext, language: String = "es") async {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = input
        input = ""
        
        let userChatMessage = ChatMessage(
            id: UUID(),
            text: userMessage,
            role: .user,
            references: []
        )
        messages.append(userChatMessage)
        
        isLoading = true
        
        do {
            let response = try await fetchAIResponse(
                userMessage: userMessage,
                language: language,
                apiKey: appEnvironment.openaiAPIKey
            )
            
            let aiMessage = ChatMessage(
                id: UUID(),
                text: response.text,
                role: .assistant,
                references: response.references
            )
            messages.append(aiMessage)
            
            let historyEntry = AIQuestionHistoryEntry(
                question: userMessage,
                answer: response.text,
                timestamp: Date()
            )
            modelContext.insert(historyEntry)
            try? modelContext.save()
            
        } catch {
            print("Error: \(error)")
            let errorMessage = ChatMessage(
                id: UUID(),
                text: "Error. Intenta de nuevo.",
                role: .assistant,
                references: []
            )
            messages.append(errorMessage)
        }
        
        isLoading = false
    }
    
    func askAbout(_ verse: BibleVerse) {
        let verseText = "\(verse.book) \(verse.chapter):\(verse.verse)"
        input = "¿Qué significa \(verseText)? \(verse.text)"
    }
    
    private func fetchAIResponse(
        userMessage: String,
        language: String,
        apiKey: String
    ) async throws -> (text: String, references: [BibleReference]) {
        let systemPrompt = "Eres un experto en la Biblia. Responde en \(language == "es" ? "español" : "inglés")."
        
        let messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": userMessage]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 1000
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw NSError(domain: "JSON Error", code: -1)
        }
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "API Error", code: -1)
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(OpenAIResponse.self, from: data)
        
        guard let content = result.choices.first?.message.content else {
            throw NSError(domain: "No content", code: -1)
        }
        
        let references = extractBibleReferences(from: content)
        return (text: content, references: references)
    }
    
    private func extractBibleReferences(from text: String) -> [BibleReference] {
        var references: [BibleReference] = []
        let pattern = "([A-ZÁÉÍÓÚa-záéíóú\\s]+)\\s(\\d+):(\\d+)"
        
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            let matches = regex.matches(in: text, range: range)
            
            for match in matches {
                if let bookRange = Range(match.range(at: 1), in: text),
                   let chapterRange = Range(match.range(at: 2), in: text),
                   let verseRange = Range(match.range(at: 3), in: text) {
                    
                    let book = String(text[bookRange]).trimmingCharacters(in: .whitespaces)
                    let reference = BibleReference(
                        book: book,
                        chapter: Int(String(text[chapterRange])) ?? 0,
                        verse: Int(String(text[verseRange])) ?? 0,
                        displayText: "\(book) \(text[chapterRange]):\(text[verseRange])"
                    )
                    references.append(reference)
                }
            }
        }
        
        return references
    }
}

// MARK: - Modelos
struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let role: ChatRole
    let references: [BibleReference]
}

enum ChatRole {
    case user
    case assistant
}

struct BibleReference: Identifiable {
    let id = UUID()
    let book: String
    let chapter: Int
    let verse: Int
    let displayText: String
}

struct OpenAIResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}
