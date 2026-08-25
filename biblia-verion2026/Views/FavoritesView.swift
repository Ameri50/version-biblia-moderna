// File: Views/FavoritesView.swift
import SwiftData
import SwiftUI

struct favoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FavoriteVerse.dateAdded, order: .reverse) private var favorites: [FavoriteVerse]

    var body: some View {
        NavigationStack {
            List {
                if favorites.isEmpty {
                    Text("Aun no tienes versiculos favoritos.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(favorites) { favorite in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(favorite.reference)
                                .font(.subheadline.weight(.semibold))
                            Text(favorite.content)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        .contextMenu {
                            Button("Copiar") {
                                UIPasteboard.general.string = "\(favorite.reference)\n\(favorite.content)"
                            }
                            ShareLink("Compartir", item: "\(favorite.reference)\n\(favorite.content)")
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
            .navigationTitle("Favoritos")
            .toolbar {
                if !favorites.isEmpty {
                    EditButton()
                }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(favorites[index])
        }
    }
}
