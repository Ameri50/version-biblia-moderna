import Foundation
import Combine

// MARK: - Biblia Repository
class BibliaNuevaRepository: NSObject, ObservableObject {
    
    @Published var libros: [String: Libro] = [:]
    @Published var isLoading = false
    @Published var error: String?
    @Published var progreso: Double = 0.0
    
    static let shared = BibliaNuevaRepository()
    
    // MARK: - Diccionarios de referencia
    
    /// Mapeo de número a nombre de libro
    let nombresLibros: [String: String] = [
        // Antiguo Testamento
        "01": "Génesis", "02": "Éxodo", "03": "Levítico", "04": "Números",
        "05": "Deuteronomio", "06": "Josué", "07": "Jueces", "08": "Rut",
        "09": "1 Samuel", "10": "2 Samuel", "11": "1 Reyes", "12": "2 Reyes",
        "13": "1 Crónicas", "14": "2 Crónicas", "15": "Esdras", "16": "Nehemías",
        "17": "Ester", "18": "Job", "19": "Salmos", "20": "Proverbios",
        "21": "Eclesiastés", "22": "Cantares", "23": "Isaías", "24": "Jeremías",
        "25": "Lamentaciones", "26": "Ezequiel", "27": "Daniel", "28": "Oseas",
        "29": "Joel", "30": "Amós", "31": "Abdías", "32": "Jonás",
        "33": "Miqueas", "34": "Nahúm", "35": "Habacuc", "36": "Sofonías",
        "37": "Hageo", "38": "Zacarías", "39": "Malaquías",
        // Nuevo Testamento
        "40": "Mateo", "41": "Marcos", "42": "Lucas", "43": "Juan",
        "44": "Hechos de los Apóstoles",
        "45": "Romanos", "46": "1 Corintios", "47": "2 Corintios", "48": "Gálatas",
        "49": "Efesios", "50": "Filipenses", "51": "Colosenses",
        "52": "1 Tesalonicenses", "53": "2 Tesalonicenses", "54": "1 Timoteo",
        "55": "2 Timoteo", "56": "Tito", "57": "Filemón", "58": "Hebreos",
        "59": "Santiago", "60": "1 Pedro", "61": "2 Pedro", "62": "1 Juan",
        "63": "2 Juan", "64": "3 Juan", "65": "Judas", "66": "Apocalipsis"
    ]
    
    /// Mapeo de número a sección
    let seccionLibros: [String: String] = [
        "01": "Pentateuco", "02": "Pentateuco", "03": "Pentateuco",
        "04": "Pentateuco", "05": "Pentateuco",
        "06": "Históricos", "07": "Históricos", "08": "Históricos",
        "09": "Históricos", "10": "Históricos", "11": "Históricos",
        "12": "Históricos", "13": "Históricos", "14": "Históricos",
        "15": "Históricos", "16": "Históricos", "17": "Históricos",
        "18": "Poéticos", "19": "Poéticos", "20": "Poéticos",
        "21": "Poéticos", "22": "Poéticos",
        "23": "Profetas mayores", "24": "Profetas mayores",
        "25": "Profetas mayores", "26": "Profetas mayores", "27": "Profetas mayores",
        "28": "Profetas menores", "29": "Profetas menores", "30": "Profetas menores",
        "31": "Profetas menores", "32": "Profetas menores", "33": "Profetas menores",
        "34": "Profetas menores", "35": "Profetas menores", "36": "Profetas menores",
        "37": "Profetas menores", "38": "Profetas menores", "39": "Profetas menores",
        "40": "Evangelios", "41": "Evangelios", "42": "Evangelios", "43": "Evangelios",
        "44": "Historia",
        "45": "Cartas de Pablo", "46": "Cartas de Pablo", "47": "Cartas de Pablo",
        "48": "Cartas de Pablo", "49": "Cartas de Pablo", "50": "Cartas de Pablo",
        "51": "Cartas de Pablo", "52": "Cartas de Pablo", "53": "Cartas de Pablo",
        "54": "Cartas de Pablo", "55": "Cartas de Pablo", "56": "Cartas de Pablo",
        "57": "Cartas de Pablo",
        "58": "Hebreos",
        "59": "Generales", "60": "Generales", "61": "Generales",
        "62": "Generales", "63": "Generales", "64": "Generales", "65": "Generales",
        "66": "Profecía"
    ]
    
    /// Mapeo de número a testamento
    let testamentoLibros: [String: String] = [
        "01": "OT", "02": "OT", "03": "OT", "04": "OT", "05": "OT",
        "06": "OT", "07": "OT", "08": "OT", "09": "OT", "10": "OT",
        "11": "OT", "12": "OT", "13": "OT", "14": "OT", "15": "OT",
        "16": "OT", "17": "OT", "18": "OT", "19": "OT", "20": "OT",
        "21": "OT", "22": "OT", "23": "OT", "24": "OT", "25": "OT",
        "26": "OT", "27": "OT", "28": "OT", "29": "OT", "30": "OT",
        "31": "OT", "32": "OT", "33": "OT", "34": "OT", "35": "OT",
        "36": "OT", "37": "OT", "38": "OT", "39": "OT",
        "40": "NT", "41": "NT", "42": "NT", "43": "NT", "44": "NT",
        "45": "NT", "46": "NT", "47": "NT", "48": "NT", "49": "NT",
        "50": "NT", "51": "NT", "52": "NT", "53": "NT", "54": "NT",
        "55": "NT", "56": "NT", "57": "NT", "58": "NT", "59": "NT",
        "60": "NT", "61": "NT", "62": "NT", "63": "NT", "64": "NT",
        "65": "NT", "66": "NT"
    ]
    
    override init() {
        super.init()
    }
    
    // MARK: - Cargar Biblia
    
    /// Carga la Biblia completa desde los archivos JSON
    func cargarBiblia() {
        print("📖 Iniciando carga de la Biblia...")
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var librosTemporales: [String: Libro] = [:]
            
            for numeroLibro in 1...66 {
                let numero = String(format: "%02d", numeroLibro)
                
                if let datos = self?.cargarLibro(numero) {
                    librosTemporales[numero] = datos
                }
                
                // Actualizar progreso
                DispatchQueue.main.async {
                    self?.progreso = Double(numeroLibro) / 66.0
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.libros = librosTemporales
                self?.isLoading = false
                self?.progreso = 1.0
                
                if librosTemporales.isEmpty {
                    self?.error = "No se pudieron cargar los libros"
                } else {
                    print("✅ Biblia cargada exitosamente: \(librosTemporales.count) libros")
                }
            }
        }
    }
    
    /// Carga un libro individual desde su archivo JSON
    private func cargarLibro(_ numero: String) -> Libro? {
        guard let url = Bundle.main.url(
            forResource: numero,
            withExtension: "content.json",
            subdirectory: "Bible/RV1909"
        ) else {
            print("⚠️  No se encontró: \(numero).content.json")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let versiculos = try JSONDecoder().decode([Versiculo].self, from: data)
            
            guard let nombre = nombresLibros[numero] else {
                print("❌ Nombre no encontrado para libro: \(numero)")
                return nil
            }
            
            let libro = Libro(
                numero: numero,
                nombre: nombre,
                testamento: testamentoLibros[numero] ?? "OT",
                seccion: seccionLibros[numero] ?? "Otros",
                versiculos: versiculos
            )
            
            print("✅ \(numero). \(nombre) (\(versiculos.count) versículos)")
            return libro
            
        } catch {
            print("❌ Error al cargar \(numero): \(error.localizedDescription)")
            self.error = "Error al cargar \(numero): \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Búsqueda por referencia
    
    /// Obtiene un libro por su número (ej: "01" para Génesis)
    func obtenerLibro(_ numero: String) -> Libro? {
        return libros[numero]
    }
    
    /// Obtiene un libro por su nombre (ej: "Génesis")
    func obtenerLibroPorNombre(_ nombre: String) -> Libro? {
        return libros.values.first { $0.nombre == nombre }
    }
    
    /// Obtiene un versículo específico
    func obtenerVersiculo(_ numeroLibro: String, capitulo: Int, numero: Int) -> Versiculo? {
        guard let libro = libros[numeroLibro] else { return nil }
        return libro.versiculos.first {
            $0.capitulo == capitulo && $0.numeroVersiculo == numero
        }
    }
    
    // MARK: - Búsqueda por palabra
    
    /// Busca versículos que contengan una palabra específica
    func buscarPorPalabra(_ palabra: String) -> [Versiculo] {
        let palabra = palabra.lowercased()
        var resultados: [Versiculo] = []
        
        for libro in libros.values {
            for versiculo in libro.versiculos {
                if versiculo.contenidoLimpio.lowercased().contains(palabra) {
                    resultados.append(versiculo)
                }
            }
        }
        
        return resultados
    }
    
    /// Busca versículos en un libro específico
    func buscarPorPalabraEnLibro(_ palabra: String, numeroLibro: String) -> [Versiculo] {
        guard let libro = libros[numeroLibro] else { return [] }
        let palabra = palabra.lowercased()
        
        return libro.versiculos.filter {
            $0.contenidoLimpio.lowercased().contains(palabra)
        }
    }
    
    // MARK: - Filtrar libros
    
    /// Obtiene todos los libros de un testamento (OT o NT)
    func obtenerTodos(testamento: String) -> [Libro] {
        return libros.values
            .filter { $0.testamento == testamento }
            .sorted { Int($0.numero) ?? 0 < Int($1.numero) ?? 0 }
    }
    
    /// Obtiene todos los libros de una sección
    func obtenerPorSeccion(_ seccion: String) -> [Libro] {
        return libros.values
            .filter { $0.seccion == seccion }
            .sorted { Int($0.numero) ?? 0 < Int($1.numero) ?? 0 }
    }
    
    /// Obtiene todos los libros ordenados por número
    func obtenerTodos() -> [Libro] {
        return libros.values.sorted { Int($0.numero) ?? 0 < Int($1.numero) ?? 0 }
    }
    
    // MARK: - Estadísticas
    
    /// Calcula estadísticas totales de la Biblia
    func obtenerEstadisticas() -> EstadisticasBiblia {
        var totalLibros = 0
        var totalCapitulos = 0
        var totalVersioniculos = 0
        var totalPalabras = 0
        
        for libro in libros.values {
            totalLibros += 1
            totalCapitulos += libro.conteo?.capitulos ?? 0
            totalVersioniculos += libro.conteo?.versiculos ?? 0
            totalPalabras += libro.conteo?.palabras ?? 0
        }
        
        let otLibros = libros.values.filter { $0.testamento == "OT" }
        let ntLibros = libros.values.filter { $0.testamento == "NT" }
        
        return EstadisticasBiblia(
            totalLibros: totalLibros,
            totalCapitulos: totalCapitulos,
            totalVersioniculos: totalVersioniculos,
            totalPalabras: totalPalabras,
            antiguoTestamentoLibros: otLibros.count,
            nuevoTestamentoLibros: ntLibros.count
        )
    }
    
    struct EstadisticasBiblia {
        let totalLibros: Int
        let totalCapitulos: Int
        let totalVersioniculos: Int
        let totalPalabras: Int
        let antiguoTestamentoLibros: Int
        let nuevoTestamentoLibros: Int
    }
    
    // MARK: - Navegación
    
    /// Obtiene el libro siguiente
    func obtenerLibroSiguiente(_ numeroActual: String) -> Libro? {
        guard let numActual = Int(numeroActual), numActual < 66 else { return nil }
        let siguiente = String(format: "%02d", numActual + 1)
        return libros[siguiente]
    }
    
    /// Obtiene el libro anterior
    func obtenerLibroAnterior(_ numeroActual: String) -> Libro? {
        guard let numActual = Int(numeroActual), numActual > 1 else { return nil }
        let anterior = String(format: "%02d", numActual - 1)
        return libros[anterior]
    }
}
