import Foundation

// MARK: - Versiculo Model
struct Versiculo: Codable, Identifiable {
    let id = UUID()
    let content_id: String
    let version: String
    let title: String
    let media_type: String
    let index_reference: String
    let language: String
    let review_level: String
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case content_id
        case version
        case title
        case media_type
        case index_reference
        case language
        case review_level
        case content
    }
    
    // MARK: - Métodos útiles
    
    /// Retorna el contenido limpio sin etiquetas HTML
    var contenidoLimpio: String {
        var resultado = content
        
        // Decodificar entidades HTML
        resultado = resultado
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&apos;", with: "'")
        
        // Eliminar tags HTML
        let regex = try! NSRegularExpression(pattern: "<[^>]+>")
        let range = NSRange(resultado.startIndex..<resultado.endIndex, in: resultado)
        resultado = regex.stringByReplacingMatches(
            in: resultado,
            options: [],
            range: range,
            withTemplate: ""
        )
        
        // Limpiar espacios
        resultado = resultado.trimmingCharacters(in: .whitespaces)
        
        return resultado
    }
    
    /// Extrae el número de capítulo de la referencia (ej: "Génesis 1:1" -> 1)
    var capitulo: Int? {
        let pattern = "(\\d+):(\\d+)"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(title.startIndex..<title.endIndex, in: title)
        
        if let match = regex.firstMatch(in: title, range: range) {
            if let capRange = Range(match.range(at: 1), in: title) {
                return Int(String(title[capRange]))
            }
        }
        return nil
    }
    
    /// Extrae el número de versículo de la referencia (ej: "Génesis 1:1" -> 1)
    var numeroVersiculo: Int? {
        let pattern = "(\\d+):(\\d+)"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(title.startIndex..<title.endIndex, in: title)
        
        if let match = regex.firstMatch(in: title, range: range) {
            if let versRange = Range(match.range(at: 2), in: title) {
                return Int(String(title[versRange]))
            }
        }
        return nil
    }
    
    /// Cuenta el número de palabras en el versículo
    var numeroPalabras: Int {
        return contenidoLimpio.split(separator: " ").count
    }
    
    /// Retorna la referencia formateada (ej: "1:1")
    var referencia: String {
        if let cap = capitulo, let vers = numeroVersiculo {
            return "\(cap):\(vers)"
        }
        return title
    }
}

// MARK: - Preview data
#if DEBUG
extension Versiculo {
    static var sampleData: Versiculo {
        Versiculo(
            content_id: "10001001001",
            version: "1.0.2",
            title: "Génesis 1:1",
            media_type: "Text",
            index_reference: "01001001",
            language: "spa",
            review_level: "Professional",
            content: "<p><sup>1</sup>&nbsp;EN el principio crió Dios los cielos y la tierra.</p>"
        )
    }
}
#endif
