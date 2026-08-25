import SwiftUI

struct BibliaPrincipalViewMejorada: View {
    @StateObject private var repository = BibliaNuevaRepository.shared
    @State private var searchText = ""
    @State private var expandedSections: Set<UUID> = Set()
    @State private var isLoading = true
    
    var filteredSecciones: [BibliaSeccion] {
        if searchText.isEmpty {
            return BIBLIA_COMPLETA_SECCIONES
        }
        return BIBLIA_COMPLETA_SECCIONES.map { seccion in
            let librosFilterados = seccion.libros.filter { libro in
                libro.nombre.lowercased().contains(searchText.lowercased())
            }
            return BibliaSeccion(
                nombre: seccion.nombre,
                emoji: seccion.emoji,
                color: seccion.color,
                libros: librosFilterados,
                testamento: seccion.testamento
            )
        }.filter { !$0.libros.isEmpty }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // HEADER
                VStack(spacing: 12) {
                    Text("📖 Biblia Reina Valera 1909")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Text("66 libros • Antiguo y Nuevo Testamento")
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.4, blue: 0.8),
                            Color(red: 0.3, green: 0.5, blue: 0.9)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                // SEARCH BAR
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Buscar libro...", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color(.systemGray6))
                
                // CONTENIDO
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.3)
                        Text("Cargando Biblia...")
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                    .onAppear {
                        repository.cargarBiblia()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            isLoading = false
                        }
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // ANTIGUO TESTAMENTO
                            SectionTestamento(
                                titulo: "📜 Antiguo Testamento",
                                subtitulo: "39 libros",
                                secciones: filteredSecciones.filter { $0.testamento == "OT" },
                                expandedSections: $expandedSections
                            )
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            // NUEVO TESTAMENTO
                            SectionTestamento(
                                titulo: "✝️ Nuevo Testamento",
                                subtitulo: "27 libros",
                                secciones: filteredSecciones.filter { $0.testamento == "NT" },
                                expandedSections: $expandedSections
                            )
                        }
                        .padding(16)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Vista de Sección por Testamento
struct SectionTestamento: View {
    let titulo: String
    let subtitulo: String
    let secciones: [BibliaSeccion]
    @Binding var expandedSections: Set<UUID>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(titulo)
                    .font(.system(size: 18, weight: .bold, design: .default))
                
                Text(subtitulo)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 12) {
                ForEach(secciones) { seccion in
                    SectionCard(
                        seccion: seccion,
                        isExpanded: expandedSections.contains(seccion.id),
                        onToggle: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if expandedSections.contains(seccion.id) {
                                    expandedSections.remove(seccion.id)
                                } else {
                                    expandedSections.insert(seccion.id)
                                }
                            }
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Tarjeta de Sección
struct SectionCard: View {
    let seccion: BibliaSeccion
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var colorFromHex: Color {
        Color(UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0 ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // HEADER EXPANDIBLE
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    Text(seccion.emoji)
                        .font(.system(size: 20))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(seccion.nombre)
                            .font(.system(size: 16, weight: .semibold, design: .default))
                            .foregroundColor(.primary)
                        
                        Text("\(seccion.libros.count) libros")
                            .font(.system(size: 12, weight: .regular, design: .default))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // CONTENIDO EXPANDIBLE
            if isExpanded {
                VStack(spacing: 8) {
                    Divider()
                        .padding(.vertical, 4)
                    
                    ForEach(seccion.libros) { libro in
                        NavigationLink(destination: DetalleLibroView(libroId: libro.id, libroNombre: libro.nombre)) {
                            HStack(spacing: 12) {
                                Text("•")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: seccion.color))
                                
                                Text(libro.nombre)
                                    .font(.system(size: 15, weight: .regular, design: .default))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("\(libro.numero)")
                                    .font(.system(size: 12, weight: .regular, design: .default))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(4)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(8)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

// MARK: - Vista de Detalle del Libro
struct DetalleLibroView: View {
    let libroId: String
    let libroNombre: String
    @StateObject private var repository = BibliaNuevaRepository.shared
    @State private var selectedChapter = 1
    @State private var chapters: [Int] = []
    
    var body: some View {
        VStack {
            if let libro = repository.obtenerLibro(libroId) {
                VStack(spacing: 16) {
                    Text(libroNombre)
                        .font(.system(size: 22, weight: .bold))
                    
                    Picker("Capítulo", selection: $selectedChapter) {
                        ForEach(chapters, id: \.self) { cap in
                            Text("Cap. \(cap)").tag(cap)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(libro.versiculosDelCapitulo(selectedChapter)) { versiculo in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(versiculo.title)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.blue)
                                    
                                    Text(versiculo.contenidoLimpio)
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(.primary)
                                        .lineSpacing(4)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                            }
                        }
                    }
                }
                .onAppear {
                    chapters = libro.capitulosUnicos.sorted()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Extensión para Color desde Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let rgb = UInt32(hex, radix: 16) ?? 0
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    BibliaPrincipalViewMejorada()
}
