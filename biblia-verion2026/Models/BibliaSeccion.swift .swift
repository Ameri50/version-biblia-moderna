import Foundation

// MARK: - Estructura de Secciones
struct BibliaSeccion: Identifiable {
    let id = UUID()
    let nombre: String
    let emoji: String
    let color: String // Hex color
    let libros: [LibroSeccion]
    let testamento: String // "OT" o "NT"
}

struct LibroSeccion: Identifiable {
    let id: String // número del libro (01-66)
    let nombre: String
    let numero: Int
}

// MARK: - Datos de la Biblia Completa
let BIBLIA_COMPLETA_SECCIONES: [BibliaSeccion] = [
    // ANTIGUO TESTAMENTO - 39 libros
    BibliaSeccion(
        nombre: "Pentateuco",
        emoji: "🟢",
        color: "#34C759",
        libros: [
            LibroSeccion(id: "01", nombre: "Génesis", numero: 1),
            LibroSeccion(id: "02", nombre: "Éxodo", numero: 2),
            LibroSeccion(id: "03", nombre: "Levítico", numero: 3),
            LibroSeccion(id: "04", nombre: "Números", numero: 4),
            LibroSeccion(id: "05", nombre: "Deuteronomio", numero: 5),
        ],
        testamento: "OT"
    ),
    
    BibliaSeccion(
        nombre: "Libros históricos",
        emoji: "🟡",
        color: "#FF9500",
        libros: [
            LibroSeccion(id: "06", nombre: "Josué", numero: 6),
            LibroSeccion(id: "07", nombre: "Jueces", numero: 7),
            LibroSeccion(id: "08", nombre: "Rut", numero: 8),
            LibroSeccion(id: "09", nombre: "1 Samuel", numero: 9),
            LibroSeccion(id: "10", nombre: "2 Samuel", numero: 10),
            LibroSeccion(id: "11", nombre: "1 Reyes", numero: 11),
            LibroSeccion(id: "12", nombre: "2 Reyes", numero: 12),
            LibroSeccion(id: "13", nombre: "1 Crónicas", numero: 13),
            LibroSeccion(id: "14", nombre: "2 Crónicas", numero: 14),
            LibroSeccion(id: "15", nombre: "Esdras", numero: 15),
            LibroSeccion(id: "16", nombre: "Nehemías", numero: 16),
            LibroSeccion(id: "17", nombre: "Ester", numero: 17),
        ],
        testamento: "OT"
    ),
    
    BibliaSeccion(
        nombre: "Libros poéticos y sapienciales",
        emoji: "🔵",
        color: "#007AFF",
        libros: [
            LibroSeccion(id: "18", nombre: "Job", numero: 18),
            LibroSeccion(id: "19", nombre: "Salmos", numero: 19),
            LibroSeccion(id: "20", nombre: "Proverbios", numero: 20),
            LibroSeccion(id: "21", nombre: "Eclesiastés", numero: 21),
            LibroSeccion(id: "22", nombre: "Cantares", numero: 22),
        ],
        testamento: "OT"
    ),
    
    BibliaSeccion(
        nombre: "Profetas mayores",
        emoji: "🟣",
        color: "#AF52DE",
        libros: [
            LibroSeccion(id: "23", nombre: "Isaías", numero: 23),
            LibroSeccion(id: "24", nombre: "Jeremías", numero: 24),
            LibroSeccion(id: "25", nombre: "Lamentaciones", numero: 25),
            LibroSeccion(id: "26", nombre: "Ezequiel", numero: 26),
            LibroSeccion(id: "27", nombre: "Daniel", numero: 27),
        ],
        testamento: "OT"
    ),
    
    BibliaSeccion(
        nombre: "Profetas menores",
        emoji: "🟠",
        color: "#FF6B35",
        libros: [
            LibroSeccion(id: "28", nombre: "Oseas", numero: 28),
            LibroSeccion(id: "29", nombre: "Joel", numero: 29),
            LibroSeccion(id: "30", nombre: "Amós", numero: 30),
            LibroSeccion(id: "31", nombre: "Abdías", numero: 31),
            LibroSeccion(id: "32", nombre: "Jonás", numero: 32),
            LibroSeccion(id: "33", nombre: "Miqueas", numero: 33),
            LibroSeccion(id: "34", nombre: "Nahúm", numero: 34),
            LibroSeccion(id: "35", nombre: "Habacuc", numero: 35),
            LibroSeccion(id: "36", nombre: "Sofonías", numero: 36),
            LibroSeccion(id: "37", nombre: "Hageo", numero: 37),
            LibroSeccion(id: "38", nombre: "Zacarías", numero: 38),
            LibroSeccion(id: "39", nombre: "Malaquías", numero: 39),
        ],
        testamento: "OT"
    ),
    
    // NUEVO TESTAMENTO - 27 libros
    BibliaSeccion(
        nombre: "Evangelios",
        emoji: "🟢",
        color: "#34C759",
        libros: [
            LibroSeccion(id: "40", nombre: "Mateo", numero: 40),
            LibroSeccion(id: "41", nombre: "Marcos", numero: 41),
            LibroSeccion(id: "42", nombre: "Lucas", numero: 42),
            LibroSeccion(id: "43", nombre: "Juan", numero: 43),
        ],
        testamento: "NT"
    ),
    
    BibliaSeccion(
        nombre: "Historia",
        emoji: "🟡",
        color: "#FF9500",
        libros: [
            LibroSeccion(id: "44", nombre: "Hechos de los Apóstoles", numero: 44),
        ],
        testamento: "NT"
    ),
    
    BibliaSeccion(
        nombre: "Cartas de Pablo",
        emoji: "🔵",
        color: "#007AFF",
        libros: [
            LibroSeccion(id: "45", nombre: "Romanos", numero: 45),
            LibroSeccion(id: "46", nombre: "1 Corintios", numero: 46),
            LibroSeccion(id: "47", nombre: "2 Corintios", numero: 47),
            LibroSeccion(id: "48", nombre: "Gálatas", numero: 48),
            LibroSeccion(id: "49", nombre: "Efesios", numero: 49),
            LibroSeccion(id: "50", nombre: "Filipenses", numero: 50),
            LibroSeccion(id: "51", nombre: "Colosenses", numero: 51),
            LibroSeccion(id: "52", nombre: "1 Tesalonicenses", numero: 52),
            LibroSeccion(id: "53", nombre: "2 Tesalonicenses", numero: 53),
            LibroSeccion(id: "54", nombre: "1 Timoteo", numero: 54),
            LibroSeccion(id: "55", nombre: "2 Timoteo", numero: 55),
            LibroSeccion(id: "56", nombre: "Tito", numero: 56),
            LibroSeccion(id: "57", nombre: "Filemón", numero: 57),
        ],
        testamento: "NT"
    ),
    
    BibliaSeccion(
        nombre: "Carta a los Hebreos",
        emoji: "🟣",
        color: "#AF52DE",
        libros: [
            LibroSeccion(id: "58", nombre: "Hebreos", numero: 58),
        ],
        testamento: "NT"
    ),
    
    BibliaSeccion(
        nombre: "Cartas generales",
        emoji: "🟠",
        color: "#FF6B35",
        libros: [
            LibroSeccion(id: "59", nombre: "Santiago", numero: 59),
            LibroSeccion(id: "60", nombre: "1 Pedro", numero: 60),
            LibroSeccion(id: "61", nombre: "2 Pedro", numero: 61),
            LibroSeccion(id: "62", nombre: "1 Juan", numero: 62),
            LibroSeccion(id: "63", nombre: "2 Juan", numero: 63),
            LibroSeccion(id: "64", nombre: "3 Juan", numero: 64),
            LibroSeccion(id: "65", nombre: "Judas", numero: 65),
        ],
        testamento: "NT"
    ),
    
    BibliaSeccion(
        nombre: "Profecía",
        emoji: "🔴",
        color: "#FF3B30",
        libros: [
            LibroSeccion(id: "66", nombre: "Apocalipsis", numero: 66),
        ],
        testamento: "NT"
    ),
]
