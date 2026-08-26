// File: ContentView.swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @State private var selectedTab = 0
    @StateObject private var repository = BibliaNuevaRepository.shared
    @StateObject private var languageManager = LanguageManager.shared
    @State private var refreshKey = UUID()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // TAB 1: BIBLIA
            NavigationStack {
                BibliaPrincipalViewMejorada()
            }
            .tabItem {
                Image(systemName: "book.fill")
                Text(NSLocalizedString("tab.bible", ""))
            }
            .tag(0)
            
            // TAB 2: BUSCAR
            BibleSearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text(NSLocalizedString("tab.search", ""))
                }
                .tag(1)
            
            // TAB 3: FAVORITOS
            FavoritesTabView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text(NSLocalizedString("tab.favorites", ""))
                }
                .tag(2)
            
            // TAB 4: NOTAS
            NotesTabView()
                .tabItem {
                    Image(systemName: "note.text.badge.plus")
                    Text(NSLocalizedString("tab.notes", ""))
                }
                .tag(3)
            
            // TAB 5: RESALTADOS
            HighlightsTabView()
                .tabItem {
                    Image(systemName: "highlighter")
                    Text(NSLocalizedString("tab.highlights", ""))
                }
                .tag(4)
            
           
            
            // TAB 7: MÁS
            MoreTabView()
                .tabItem {
                    Image(systemName: "ellipsis")
                    Text(NSLocalizedString("tab.more", ""))
                }
                .tag(6)
        }
        .id(refreshKey)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
            refreshKey = UUID()
        }
        .onAppear {
            repository.cargarBiblia()
        }
    }
}

// MARK: - Vista de Favoritos
struct FavoritesTabView: View {
    @Query(sort: \FavoriteVerse.dateAdded, order: .reverse) var favorites: [FavoriteVerse]
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // HEADER
                VStack(spacing: 8) {
                    Text(NSLocalizedString("favorites.title", ""))
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        // ✅ CORREGIDO: Usar String() en lugar de "\(...)"
                        Text(String(favorites.count))
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(NSLocalizedString("favorites.subtitle", ""))
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.8, green: 0.2, blue: 0.3),
                            Color(red: 0.9, green: 0.3, blue: 0.4)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                if favorites.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text(NSLocalizedString("favorites.empty.title", ""))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Text(NSLocalizedString("favorites.empty.subtitle", ""))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                    .padding(40)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(favorites) { favorite in
                                FavoriteCardView(favorite: favorite)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FavoriteCardView: View {
    let favorite: FavoriteVerse
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(favorite.reference)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.red)
                    
                    Text(favorite.bookName)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    modelContext.delete(favorite)
                    try? modelContext.save()
                }) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                }
            }
            
            Text(favorite.content)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Vista de Notas
struct NotesTabView: View {
    @Query(sort: \BibleNote.createdAt, order: .reverse) var notes: [BibleNote]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // HEADER
                VStack(spacing: 8) {
                    Text(NSLocalizedString("notes.title", ""))
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        // ✅ CORREGIDO: Usar String() en lugar de "\(...)"
                        Text(String(notes.count))
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(NSLocalizedString("notes.subtitle", ""))
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.6, blue: 0.8),
                            Color(red: 0.3, green: 0.7, blue: 0.9)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                if notes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "note.text.badge.plus")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text(NSLocalizedString("notes.empty.title", ""))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Text(NSLocalizedString("notes.empty.subtitle", ""))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                    .padding(40)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(notes) { note in
                                NoteCardView(note: note)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct NoteCardView: View {
    let note: BibleNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(note.reference)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
                
                Text(note.bookName)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            Text(note.noteContent)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.primary)
                .lineSpacing(4)
            
            Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Vista de Resaltados
struct HighlightsTabView: View {
    @Query(sort: \VerseHighlight.dateAdded, order: .reverse) var highlights: [VerseHighlight]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // HEADER
                VStack(spacing: 8) {
                    Text(NSLocalizedString("highlights.title", ""))
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        // ✅ CORREGIDO: Usar String() en lugar de "\(...)"
                        Text(String(highlights.count))
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(NSLocalizedString("highlights.subtitle", ""))
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.8, blue: 0.0),
                            Color(red: 1.0, green: 0.9, blue: 0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                if highlights.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "highlighter")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text(NSLocalizedString("highlights.empty.title", ""))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Text(NSLocalizedString("highlights.empty.subtitle", ""))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                    .padding(40)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(highlights) { highlight in
                                HighlightCardView(highlight: highlight)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct HighlightCardView: View {
    let highlight: VerseHighlight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(hex: highlight.colorHex))
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(highlight.reference)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(highlight.bookName)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            Text(highlight.content)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
        .padding(12)
        .background(Color(hex: highlight.colorHex).opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Vista de Más Opciones
struct MoreTabView: View {
    @Query var preferences: [AppPreference]
    @Query(sort: \ReadingHistoryEntry.date, order: .reverse) var readingHistory: [ReadingHistoryEntry]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // HEADER
                VStack(spacing: 8) {
                    Text(NSLocalizedString("more.title", ""))
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Text(NSLocalizedString("more.subtitle", ""))
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.5, green: 0.5, blue: 0.5),
                            Color(red: 0.6, green: 0.6, blue: 0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                ScrollView {
                    VStack(spacing: 12) {
                        NavigationLink(destination: SettingsView()) {
                            MoreOptionCardView(
                                icon: "⚙️",
                                title: NSLocalizedString("more.settings", ""),
                                subtitle: NSLocalizedString("more.settings.subtitle", "")
                            )
                        }
                        
                        NavigationLink(destination: ReadingHistoryView(readingHistory: readingHistory)) {
                            MoreOptionCardView(
                                icon: "📚",
                                title: NSLocalizedString("more.history", ""),
                                // ✅ CORREGIDO: Usar String() en lugar de "\(...)"
                                subtitle: String(readingHistory.count) + " " + NSLocalizedString("more.history.subtitle", "")
                            )
                        }
                        
                        NavigationLink(destination: SearchHistoryView()) {
                            MoreOptionCardView(
                                icon: "🔍",
                                title: NSLocalizedString("more.search.history", ""),
                                subtitle: NSLocalizedString("more.search.history.subtitle", "")
                            )
                        }
                        
                        NavigationLink(destination: AboutView()) {
                            MoreOptionCardView(
                                icon: "ℹ️",
                                title: NSLocalizedString("more.about", ""),
                                subtitle: NSLocalizedString("more.about.subtitle", "")
                            )
                        }
                    }
                    .padding(16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MoreOptionCardView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.system(size: 32))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Vista de Historial de Lectura
struct ReadingHistoryView: View {
    let readingHistory: [ReadingHistoryEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if readingHistory.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "book")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text(NSLocalizedString("history.no.results", ""))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(readingHistory) { entry in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.chapterReference)
                                        .font(.system(size: 14, weight: .semibold))
                                    
                                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(16)
        .navigationTitle(NSLocalizedString("more.history", ""))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Vista de Historial de Búsqueda
struct SearchHistoryView: View {
    @Query(sort: \SearchHistoryEntry.timestamp, order: .reverse) var searchHistory: [SearchHistoryEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if searchHistory.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text(NSLocalizedString("search.no.results", ""))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(searchHistory) { search in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(search.query)
                                        .font(.system(size: 14, weight: .semibold))
                                    
                                    Text(search.timestamp.formatted(date: .abbreviated, time: .shortened))
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                // ✅ CORREGIDO: Usar String() en lugar de "\(...)"
                                Text(String(search.resultsCount))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(16)
        .navigationTitle(NSLocalizedString("more.search.history", ""))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Vista Acerca de
struct AboutView: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("📖")
                    .font(.system(size: 64))
                
                Text(NSLocalizedString("about.title", ""))
                    .font(.system(size: 22, weight: .bold))
                
                Text(NSLocalizedString("about.version", ""))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("about.features", ""))
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text(NSLocalizedString("about.features.list", ""))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.primary)
                        .lineSpacing(6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(NSLocalizedString("about.copyright", ""))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
                
                Text(NSLocalizedString("about.license", ""))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .navigationTitle(NSLocalizedString("more.about", ""))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [FavoriteVerse.self, BibleNote.self, VerseHighlight.self, ReadingHistoryEntry.self, SearchHistoryEntry.self, AIQuestionHistoryEntry.self, AppPreference.self], inMemory: true)
}
