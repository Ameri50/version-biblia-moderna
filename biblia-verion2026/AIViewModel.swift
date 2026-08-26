// File: ViewModels/AIViewModel.swift
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
        
        // Agregar mensaje del usuario a la interfaz
        let userChatMessage = ChatMessage(
            id: UUID(),
            text: userMessage,
            role: .user,
            timestamp: Date(),
            references: []
        )
        messages.append(userChatMessage)
        
        // Marcar como cargando
        isLoading = true
        
        do {
            // Obtener la respuesta de la IA
            let response = try await fetchAIResponse(
                userMessage: userMessage,
                language: language,
                apiKey: appEnvironment.openaiAPIKey
            )
            
            // Agregar respuesta de la IA
            let aiMessage = ChatMessage(
                id: UUID(),
                text: response.text,
                role: .assistant,
                timestamp: Date(),
                references: response.references
            )
            messages.append(aiMessage)
            
            // Guardar en historial
            let historyEntry = AIQuestionHistoryEntry(
                question: userMessage,
                answer: response.text,
                timestamp: Date()
            )
            modelContext.insert(historyEntry)
            try? modelContext.save()
            
        } catch {
            print("Error fetching AI response: \(error)")
            let errorMessage = ChatMessage(
                id: UUID(),
                text: language == "es"
                    ? "Lo siento, hubo un error al obtener la respuesta. Por favor, intenta de nuevo."
                    : "Sorry, there was an error getting the response. Please try again.",
                role: .assistant,
                timestamp: Date(),
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
    
    // MARK: - Método privado para obtener respuesta de OpenAI
    private func fetchAIResponse(
        userMessage: String,
        language: String,
        apiKey: String
    ) async throws -> (text: String, references: [BibleReference]) {
        let languageName = language == "es" ? "español" : "English"
        
        // Sistema prompt que especifica el idioma
        let systemPrompt = """
        Eres un asistente experto en la Biblia especializado en responder preguntas sobre pasajes bíblicos.
        
        IDIOMA: Debes SIEMPRE responder SOLAMENTE en \(languageName).
        - Si el usuario habla en \(languageName), responde en \(languageName).
        - NUNCA mezcles idiomas.
        - Adapta tu tono y expresiones al idioma seleccionado.
        
        INSTRUCCIONES:
        1. Proporciona respuestas claras y precisas sobre pasajes bíblicos
        2. Cita los versículos relevantes cuando sea apropiado
        3. Explica el contexto histórico y cultural cuando sea necesario
        4. Ofrece interpretaciones diversas si existen
        5. Sé respetuoso y académico en tu enfoque
        
        FORMATO DE REFERENCIAS:
        Cuando menciones un versículo, úsalo en este formato: "Libro Capítulo:Versículo"
        Ejemplo: "Génesis 1:1" o "Juan 3:16"
        """
        
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
            throw NSError(domain: "JSON Encoding Error", code: -1)
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
            throw NSError(domain: "No content in response", code: -1)
        }
        
        // Extraer referencias bíblicas del contenido
        let references = extractBibleReferences(from: content)
        
        return (text: content, references: references)
    }
    
    // MARK: - Extraer referencias bíblicas del texto
    private func extractBibleReferences(from text: String) -> [BibleReference] {
        var references: [BibleReference] = []
        
        // Patrón para buscar referencias como "Génesis 1:1" o "Juan 3:16"
        let pattern = "([A-ZÁÉÍÓÚa-záéíóú\\s]+)\\s(\\d+):(\\d+)"
        
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            let matches = regex.matches(in: text, range: range)
            
            for match in matches {
                if let bookRange = Range(match.range(at: 1), in: text),
                   let chapterRange = Range(match.range(at: 2), in: text),
                   let verseRange = Range(match.range(at: 3), in: text) {
                    
                    let book = String(text[bookRange]).trimmingCharacters(in: .whitespaces)
                    let chapter = String(text[chapterRange])
                    let verse = String(text[verseRange])
                    
                    let reference = BibleReference(
                        book: book,
                        chapter: Int(chapter) ?? 0,
                        verse: Int(verse) ?? 0,
                        displayText: "\(book) \(chapter):\(verse)"
                    )
                    references.append(reference)
                }
            }
        }
        
        return references
    }
}

// MARK: - Modelos de datos
struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let role: ChatRole
    let timestamp: Date
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

// MARK: - Respuesta de OpenAI
struct OpenAIResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}
