// File: Views/BookPickerView.swift
import SwiftUI

struct BookPickerView: View {
    @Environment(AppEnvironment.self) private var app
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(BibleBookCategory.displayOrder) { category in
                    let books = booksInCategory(category)
                    if !books.isEmpty {
                        Section {
                            ForEach(books) { book in
                                bookRow(book, category: category)
                            }
                        } header: {
                            Label {
                                Text("\(testamentLabel(category.testament)) — \(category.title)")
                            } icon: {
                                Text(category.emoji)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Buscar libro")
            .navigationTitle("Libro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }

    private func bookRow(_ book: BibleBook, category: BibleBookCategory) -> some View {
        Button {
            app.selectedBookID = book.id
            app.selectedChapter = book.chapters.map(\.number).min() ?? 1
            dismiss()
        } label: {
            HStack {
                Circle()
                    .fill(category.color)
                    .frame(width: 10, height: 10)
                Text(book.name)
                    .foregroundStyle(.primary)
                Spacer()
                if book.id == app.selectedBookID {
                    Image(systemName: "checkmark")
                        .foregroundStyle(category.color)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func booksInCategory(_ category: BibleBookCategory) -> [BibleBook] {
        let inCategory = app.books
            .filter { $0.category == category }
            .sorted { $0.order < $1.order }
        guard !searchText.isEmpty else { return inCategory }
        return inCategory.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private func testamentLabel(_ testament: BibleTestament) -> String {
        testament == .old ? "Antiguo Testamento" : "Nuevo Testamento"
    }
}
