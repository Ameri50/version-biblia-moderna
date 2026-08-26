// File: Views/BibleSearchView.swift
import SwiftData
import SwiftUI

struct BibleSearchView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var query: String = ""
    @State private var results: [BibleSearchResult] = []
    @State private var isLoading: Bool = false
    
    @Query(sort: \SearchHistoryEntry.timestamp, order: .reverse)
    private var history: [SearchHistoryEntry]

    var body: some View {
        NavigationStack {
            List {
                // Sección: Búsquedas recientes
                if query.isEmpty {
                    Section("Búsquedas recientes") {
                        if history.isEmpty {
                            Text("Aún no hay búsquedas.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(history.prefix(10)) { entry in
                                Button(entry.query) {
                                    query = entry.query
                                }
                            }
                        }
                    }
                } else {
                    // Sección: Resultados
                    if isLoading {
                        Section {
                            HStack {
                                ProgressView()
                                Text("Buscando...")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else if results.isEmpty {
                        Section {
                            Text("Sin resultados para '\(query)'")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Section("Resultados") {
                            ForEach(results) { result in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(result.verse.reference)
                                        .font(.subheadline.weight(.semibold))
                                    
                                    Text(result.verse.text)
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(3)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Buscar")
            .searchable(
                text: $query,
                prompt: "Palabra, frase o referencia"
            )
            .onSubmit(of: .search) {
                submit()
            }
            .onChange(of: query) { oldValue, newValue in
                if newValue.isEmpty {
                    results = []
                }
            }
        }
    }

    private func submit() {
        // Aquí va tu lógica de búsqueda
        print("Buscando: \(query)")
    }
}

#Preview {
    BibleSearchView()
        .modelContainer(for: [SearchHistoryEntry.self], inMemory: true)
}
