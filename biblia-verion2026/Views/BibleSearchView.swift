// File: Views/BibleSearchView.swift
import SwiftData
import SwiftUI

struct BibleSearchView: View {
    @EnvironmentObject private var app: AppEnvironment
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = SearchViewModel()
    @Query(sort: \SearchHistoryEntry.searchedAt, order: .reverse) private var history: [SearchHistoryEntry]

    var body: some View {
        NavigationStack {
            List {
                if viewModel.query.isEmpty {
                    Section("Busquedas recientes") {
                        if history.isEmpty {
                            Text("Aun no hay busquedas.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(history.prefix(10)) { entry in
                                Button(entry.query) {
                                    viewModel.query = entry.query
                                    submit()
                                }
                            }
                        }
                    }
                } else {
                    Section("Resultados") {
                        if viewModel.results.isEmpty {
                            Text("Sin resultados para \"\(viewModel.query)\".")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(viewModel.results) { result in
                                Button {
                                    open(result)
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(result.verse.reference)
                                            .font(.subheadline.weight(.semibold))
                                        Text(result.verse.text)
                                            .font(.body)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(3)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Buscar")
            .searchable(text: $viewModel.query, prompt: "Palabra, frase o referencia (ej. Juan 3:16)")
            .onSubmit(of: .search) { submit() }
            .onChange(of: viewModel.query) { _, newValue in
                if newValue.isEmpty { viewModel.results = [] }
            }
        }
    }

    private func submit() {
        viewModel.submit(using: app, modelContext: modelContext)
    }

    private func open(_ result: BibleSearchResult) {
        app.open(VerseReference(
            translationID: result.verse.translationID,
            bookID: result.verse.bookID,
            bookName: result.verse.bookName,
            chapter: result.verse.chapter,
            verse: result.verse.number
        ))
    }
}
