import SwiftUI

struct BibliaPrincipalViewMejorada: View {
    @StateObject private var repository = BibliaNuevaRepository.shared
    @State private var searchText = ""
    @State private var expandedSections: Set<UUID> = Set()
    
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
                if repository.isLoading && repository.libros.isEmpty {
                    VStack(spacing: 16) {
                        ProgressView(value: repository.progreso)
                            .progressViewStyle(.linear)
                            .frame(width: 180)
                        Text("Cargando Biblia... \(Int(repository.progreso * 100))%")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                    .onAppear {
                        if repository.libros.isEmpty {
                            repository.cargarBiblia()
                        }
                    }
                } else if let error = repository.error, repository.libros.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Button("Reintentar") {
                            repository.cargarBiblia()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(32)
                    .frame(maxHeight: .infinity)
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
        Color(hex: seccion.color)
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
        Group {
            if let libro = repository.obtenerLibro(libroId) {
                VStack(spacing: 0) {
                    // Selector de capítulos: chips en scroll horizontal
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(chapters, id: \.self) { cap in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            selectedChapter = cap
                                        }
                                    } label: {
                                        Text("\(cap)")
                                            .font(.system(size: 14, weight: .semibold))
                                            .frame(minWidth: 36, minHeight: 36)
                                            .background(
                                                Circle().fill(
                                                    cap == selectedChapter
                                                        ? Color.blue
                                                        : Color(.systemGray6)
                                                )
                                            )
                                            .foregroundColor(cap == selectedChapter ? .white : .primary)
                                    }
                                    .id(cap)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .onChange(of: selectedChapter) { _, nuevo in
                            withAnimation { proxy.scrollTo(nuevo, anchor: .center) }
                        }
                    }
                    .background(Color(.systemBackground))

                    Divider()

                    // Versículos del capítulo seleccionado
                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Capítulo \(selectedChapter)")
                                .font(.system(size: 20, weight: .bold))
                                .padding(.top, 16)

                            ForEach(libro.versiculosDelCapitulo(selectedChapter)) { versiculo in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("\(versiculo.numeroVersiculo ?? 0)")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.blue)
                                        .frame(width: 22, alignment: .trailing)

                                    Text(versiculo.contenidoLimpio)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.primary)
                                        .lineSpacing(5)
                                }
                            }

                            // Navegación entre capítulos
                            HStack {
                                Button {
                                    irACapitulo(selectedChapter - 1)
                                } label: {
                                    Label("Anterior", systemImage: "chevron.left")
                                }
                                .disabled(selectedChapter <= (chapters.first ?? 1))

                                Spacer()

                                Button {
                                    irACapitulo(selectedChapter + 1)
                                } label: {
                                    Label("Siguiente", systemImage: "chevron.right")
                                        .labelStyle(.titleAndIcon)
                                }
                                .disabled(selectedChapter >= (chapters.last ?? 1))
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 24)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .onAppear {
                    chapters = libro.capitulosUnicos.sorted()
                    if !chapters.contains(selectedChapter) {
                        selectedChapter = chapters.first ?? 1
                    }
                }
            } else if repository.isLoading {
                ProgressView("Cargando \(libroNombre)...")
                    .frame(maxHeight: .infinity)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No se pudo cargar \(libroNombre)")
                        .foregroundColor(.gray)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .navigationTitle(libroNombre)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func irACapitulo(_ numero: Int) {
        guard chapters.contains(numero) else { return }
        withAnimation(.easeInOut(duration: 0.15)) {
            selectedChapter = numero
        }
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
