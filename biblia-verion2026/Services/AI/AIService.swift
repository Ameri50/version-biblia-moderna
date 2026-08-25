// File: Services/AI/AIService.swift
import Foundation

protocol AIServiceProtocol {
    func generateResponse(prompt: String, context: String?) async throws -> String
}

enum AIProvider: String, CaseIterable, Identifiable {
    case gemini
    case backend

    var id: String { rawValue }
}

struct AIConfiguration {
    static var provider: AIProvider = .gemini
    static var backendURL: URL? = URL(string: "https://example.com/api/ai")
}

struct GeminiConfiguration {
    let apiKey: String
    let model: String
    let baseURL: URL

    static var development: GeminiConfiguration {
        GeminiConfiguration(
            apiKey: Secrets.geminiAPIKey,
            model: "gemini-3.6-flash",
            baseURL: URL(string: "https://generativelanguage.googleapis.com/v1beta")!
        )
    }
}

enum GeminiAPIError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case unauthorized
    case rateLimitExceeded
    case serverError
    case invalidRequest
    case decodingError
    case networkError
    case emptyResponse
    case missingAPIKey

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Configura tu Gemini API key en Secrets.swift."
        case .unauthorized:
            return "Gemini rechazo la solicitud. Revisa la API key."
        case .rateLimitExceeded:
            return "Se alcanzo temporalmente el limite de solicitudes."
        case .serverError:
            return "Gemini no pudo procesar la solicitud. Intentalo nuevamente."
        case .networkError:
            return "No se pudo conectar con Gemini. Comprueba tu conexion a Internet."
        case .emptyResponse:
            return "Gemini devolvio una respuesta vacia."
        default:
            return "No se pudo completar la solicitud de IA."
        }
    }
}

struct GeminiPromptBuilder {
    static func buildPrompt(userPrompt: String, context: String?, languageCode: String = Locale.current.language.languageCode?.identifier ?? "es") -> String {
        """
        Responde en el idioma de la aplicacion: \(languageCode).
        Usa como fuente principal el contexto biblico proporcionado.
        Diferencia claramente entre texto biblico e interpretacion.
        No inventes versiculos ni referencias.
        Si el contexto no contiene evidencia suficiente, dilo claramente.

        Contexto:
        \(context?.isEmpty == false ? context! : "Sin contexto local relevante.")

        Pregunta:
        \(userPrompt)
        """
    }
}

final class GeminiAIService: AIServiceProtocol {
    private let configuration: GeminiConfiguration
    private let session: URLSession

    init(configuration: GeminiConfiguration = .development, session: URLSession = .shared) {
        self.configuration = configuration
        self.session = session
    }

    func generateResponse(prompt: String, context: String?) async throws -> String {
        guard configuration.apiKey != "YOUR_GEMINI_API_KEY", !configuration.apiKey.isEmpty else {
            throw GeminiAPIError.missingAPIKey
        }

        let fullPrompt = GeminiPromptBuilder.buildPrompt(userPrompt: prompt, context: context)
        let encodedModel = configuration.model.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? configuration.model
        guard var components = URLComponents(url: configuration.baseURL.appendingPathComponent("models/\(encodedModel):generateContent"), resolvingAgainstBaseURL: false) else {
            throw GeminiAPIError.invalidURL
        }
        components.queryItems = [URLQueryItem(name: "key", value: configuration.apiKey)]
        guard let url = components.url else { throw GeminiAPIError.invalidURL }

        var request = URLRequest(url: url, timeoutInterval: 45)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(GeminiRequest(contents: [
            GeminiContent(parts: [GeminiPart(text: fullPrompt)])
        ]))

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw GeminiAPIError.invalidResponse }
            try Self.validate(httpResponse)
            let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
            guard let text = decoded.candidates.first?.content.parts.compactMap(\.text).joined(separator: "\n"), !text.isEmpty else {
                throw GeminiAPIError.emptyResponse
            }
            return text
        } catch let error as GeminiAPIError {
            throw error
        } catch is DecodingError {
            throw GeminiAPIError.decodingError
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw GeminiAPIError.networkError
        }
    }

    private static func validate(_ response: HTTPURLResponse) throws {
        switch response.statusCode {
        case 200..<300: return
        case 400: throw GeminiAPIError.invalidRequest
        case 401, 403: throw GeminiAPIError.unauthorized
        case 429: throw GeminiAPIError.rateLimitExceeded
        case 500..<600: throw GeminiAPIError.serverError
        default: throw GeminiAPIError.invalidResponse
        }
    }
}

final class BackendAIService: AIServiceProtocol {
    private let endpoint: URL?

    init(endpoint: URL? = AIConfiguration.backendURL) {
        self.endpoint = endpoint
    }

    func generateResponse(prompt: String, context: String?) async throws -> String {
        guard let endpoint else { throw GeminiAPIError.invalidURL }
        var request = URLRequest(url: endpoint, timeoutInterval: 45)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["prompt": prompt, "context": context ?? ""])
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw GeminiAPIError.invalidResponse
        }
        let decoded = try JSONDecoder().decode(BackendAIResponse.self, from: data)
        return decoded.text
    }
}

enum AIServiceFactory {
    static func makeService() -> AIServiceProtocol {
        switch AIConfiguration.provider {
        case .gemini:
            return GeminiAIService()
        case .backend:
            return BackendAIService()
        }
    }
}

private struct GeminiRequest: Encodable {
    let contents: [GeminiContent]
}

private struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

private struct GeminiPart: Codable {
    let text: String?
}

private struct GeminiResponse: Decodable {
    let candidates: [GeminiCandidate]
}

private struct GeminiCandidate: Decodable {
    let content: GeminiContent
}

private struct BackendAIResponse: Decodable {
    let text: String
}
