import Foundation

// MARK: - Libro Model
struct Libro: Codable, Identifiable {
    let id = UUID()
    let numero: String
    let nombre: String
    let testamento: String  // "OT" (Antiguo) o "NT" (Nuevo)
    let seccion: String
    let versiculos: [Versiculo]
    let conteo: Conteo?
    
    // Estructura para estadísticas
    struct Conteo: Codable {
        let versiculos: Int
        let capitulos: Int
        let palabras: Int
    }
    
    enum CodingKeys: String, CodingKey {
        case numero
        case nombre
        case testamento
        case seccion
        case versiculos
        case conteo
    }
    
    // MARK: - Métodos útiles
    
    /// Retorna todos los versículos de un capítulo específico
    func versiculosDelCapitulo(_ capitulo: Int) -> [Versiculo] {
        return versiculos.filter { $0.capitulo == capitulo }
            .sorted { ($0.numeroVersiculo ?? 0) < ($1.numeroVersiculo ?? 0) }
    }
    
    /// Retorna un versículo específico
    func obtenerVersiculo(_ capitulo: Int, _ numero: Int) -> Versiculo? {
        return versiculos.first {
            $0.capitulo == capitulo && $0.numeroVersiculo == numero
        }
    }
    
    /// Retorna todos los números de capítulos únicos ordenados
    var capitulosUnicos: [Int] {
        let capitulos = Set(versiculos.compactMap { $0.capitulo })
        return Array(capitulos).sorted()
    }
    
    /// Retorna el número del capítulo con más versículos
    var capituloMasLargo: Int? {
        var maxCapitulo: Int?
        var maxVersioniculos = 0
        
        for cap in capitulosUnicos {
            let count = versiculosDelCapitulo(cap).count
            if count > maxVersioniculos {
                maxVersioniculos = count
                maxCapitulo = cap
            }
        }
        
        return maxCapitulo
    }
    
    /// Retorna el número del capítulo con menos versículos
    var capituloMasCorto: Int? {
        var minCapitulo: Int?
        var minVersioniculos = Int.max
        
        for cap in capitulosUnicos {
            let count = versiculosDelCapitulo(cap).count
            if count < minVersioniculos {
                minVersioniculos = count
                minCapitulo = cap
            }
        }
        
        return minCapitulo
    }
    
    /// Busca versículos que contengan una palabra específica
    func buscarPorPalabra(_ palabra: String) -> [Versiculo] {
        let palabraBaja = palabra.lowercased()
        return versiculos.filter { versiculo in
            versiculo.contenidoLimpio.lowercased().contains(palabraBaja)
        }
    }
    
    /// Retorna el primer versículo del libro
    var primerVersiculo: Versiculo? {
        return versiculos.first
    }
    
    /// Retorna el último versículo del libro
    var ultimoVersiculo: Versiculo? {
        return versiculos.last
    }
    
    /// Verifica si el libro tiene un capítulo específico
    func tieneCapitulo(_ numero: Int) -> Bool {
        return capitulosUnicos.contains(numero)
    }
    
    /// Retorna una descripción detallada del libro
    var descripcion: String {
        let tipo = testamento == "OT" ? "Antiguo Testamento" : "Nuevo Testamento"
        return "\(nombre) (\(tipo))\n\(seccion)\nCapítulos: \(conteo?.capitulos ?? 0), Versículos: \(conteo?.versiculos ?? 0)"
    }
}

// MARK: - Extensión para crear desde datos JSON
extension Libro {
    init(numero: String, nombre: String, testamento: String, seccion: String, versiculos: [Versiculo]) {
        self.numero = numero
        self.nombre = nombre
        self.testamento = testamento
        self.seccion = seccion
        self.versiculos = versiculos
        
        // Calcular estadísticas automáticamente
        let capitulos = Set(versiculos.compactMap { $0.capitulo }).count
        let palabras = versiculos.reduce(0) {
            $0 + $1.contenidoLimpio.split(separator: " ").count
        }
        
        self.conteo = Conteo(
            versiculos: versiculos.count,
            capitulos: capitulos,
            palabras: palabras
        )
    }
}

// MARK: - Preview data
#if DEBUG
extension Libro {
    static var sampleData: Libro {
        Libro(
            numero: "01",
            nombre: "Génesis",
            testamento: "OT",
            seccion: "Pentateuco",
            versiculos: [
                Versiculo(
                    content_id: "10001001001",
                    version: "1.0.2",
                    title: "Génesis 1:1",
                    media_type: "Text",
                    index_reference: "01001001",
                    language: "spa",
                    review_level: "Professional",
                    content: "<p><sup>1</sup>&nbsp;EN el principio crió Dios los cielos y la tierra.</p>"
                ),
                Versiculo(
                    content_id: "10001001002",
                    version: "1.0.2",
                    title: "Génesis 1:2",
                    media_type: "Text",
                    index_reference: "01001002",
                    language: "spa",
                    review_level: "Professional",
                    content: "<p><sup>2</sup>&nbsp;Y la tierra estaba desordenada y vacía, y las tinieblas estaban sobre la haz del abismo, y el Espíritu de Dios se movía sobre la haz de las aguas.</p>"
                )
            ]
        )
    }
}
#endif
