// File: Views/RootViews.swift
import SwiftData
import SwiftUI

struct BibleRootView: View {
    @StateObject private var environment = AppEnvironment()

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Inicio", systemImage: "house") }
            BibleReaderView()
                .tabItem { Label("Biblia", systemImage: "book") }
            BibleSearchView()
                .tabItem { Label("Buscar", systemImage: "magnifyingglass") }
            AIChatView()
                .tabItem { Label("IA", systemImage: "sparkles") }
            SettingsView()
                .tabItem { Label("Ajustes", systemImage: "gearshape") }
        }
        .environmentObject(environment)
        .preferredColorScheme(preferredScheme)
    }

    private var preferredScheme: ColorScheme? {
        switch environment.colorSchemePreference {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var app: AppEnvironment
    @Query(sort: \ReadingHistoryEntry.readAt, order: .reverse) private var history: [ReadingHistoryEntry]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Biblia")
                            .font(.largeTitle.bold())
                        Text(app.currentChapter?.verses.first?.text ?? "Lee, busca y estudia la Biblia sin crear una cuenta.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("Versiculo del dia")
                    }
                    .padding(.vertical, 8)
                }

                Section("Accesos") {
                    NavigationLink("Leer Biblia", destination: BibleReaderView())
                    NavigationLink("Buscar", destination: BibleSearchView())
                    NavigationLink("Preguntar a IA", destination: AIChatView())
                    NavigationLink("Favoritos", destination: FavoritesView())
                    NavigationLink("Notas", destination: NotesView())
                    NavigationLink("Ajustes", destination: SettingsView())
                }

                Section("Ultimo capitulo") {
                    if let last = history.first {
                        Button(last.reference) {
                            app.selectedTranslationID = last.translationID
                            app.selectedBookID = last.bookID
                            app.selectedChapter = last.chapter
                        }
                    } else {
                        Text("Juan 3")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Inicio")
        }
    }
}

struct BibleReaderView: View {
    @EnvironmentObject private var app: AppEnvironment
    @Environment(\.modelContext) private var modelContext
    @Query private var highlights: [VerseHighlight]
    @State private var inChapterSearch = ""
    @State private var selectedVerseForNote: BibleVerse?
    @State private var noteText = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Libro", selection: $app.selectedBookID) {
                        ForEach(app.books) { book in
                            Text(book.name).tag(book.id)
                        }
                    }
                    Picker("Capitulo", selection: $app.selectedChapter) {
                        ForEach(chapterNumbers, id: \.self) { number in
                            Text("\(number)").tag(number)
                        }
                    }
                }

                Section(app.currentChapter?.bookName ?? "Biblia") {
                    ForEach(filteredVerses) { verse in
                        VerseRow(verse: verse, highlight: highlight(for: verse))
                            .contextMenu {
                                Button("Copiar") { UIPasteboard.general.string = "\(verse.reference)\n\(verse.text)" }
                                ShareLink("Compartir", item: "\(verse.reference)\n\(verse.text)")
                                Button("Favorito") { toggleFavorite(verse) }
                                Button("Resaltar") { toggleHighlight(verse) }
                                Button("Nota") { selectedVerseForNote = verse }
                                Button("Preguntar a IA") {
                                    NotificationCenter.default.post(name: .askAIAboutVerse, object: verse)
                                }
                            }
                            .accessibilityElement(children: .combine)
                    }
                }
            }
            .searchable(text: $inChapterSearch, prompt: "Buscar en el capitulo")
            .navigationTitle(chapterTitle)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: previousChapter) { Image(systemName: "chevron.left") }
                        .accessibilityLabel("Capitulo anterior")
                    Button(action: nextChapter) { Image(systemName: "chevron.right") }
                        .accessibilityLabel("Capitulo siguiente")
                }
            }
            .onAppear { recordReading() }
            .onChange(of: app.selectedChapter) { _, _ in recordReading() }
            .sheet(item: $selectedVerseForNote) { verse in
                NoteEditorView(reference: verse.reference, text: $noteText) {
                    modelContext.insert(BibleNote(verseID: verse.id, translationID: verse.translationID, reference: verse.reference, text: noteText))
                    noteText = ""
                    selectedVerseForNote = nil
                }
            }
        }
    }

    private var chapterTitle: String {
        guard let chapter = app.currentChapter else { return "Biblia" }
        return "\(chapter.bookName) \(chapter.number)"
    }

    private var chapterNumbers: [Int] {
        app.books.first { $0.id == app.selectedBookID }?.chapters.map(\.number) ?? []
    }

    private var filteredVerses: [BibleVerse] {
        let verses = app.currentChapter?.verses ?? []
        guard !inChapterSearch.isEmpty else { return verses }
        return verses.filter { $0.text.localizedCaseInsensitiveContains(inChapterSearch) }
    }

    private func previousChapter() {
        guard let index = chapterNumbers.firstIndex(of: app.selectedChapter), index > 0 else { return }
        app.selectedChapter = chapterNumbers[index - 1]
    }

    private func nextChapter() {
        guard let index = chapterNumbers.firstIndex(of: app.selectedChapter), index < chapterNumbers.count - 1 else { return }
        app.selectedChapter = chapterNumbers[index + 1]
    }

    private func recordReading() {
        guard let chapter = app.currentChapter else { return }
        modelContext.insert(ReadingHistoryEntry(translationID: app.selectedTranslationID, bookID: chapter.bookID, bookName: chapter.bookName, chapter: chapter.number))
    }

    private func highlight(for verse: BibleVerse) -> VerseHighlight? {
        highlights.first { $0.verseID == verse.id }
    }

    private func toggleHighlight(_ verse: BibleVerse) {
        if let existing = highlight(for: verse) {
            modelContext.delete(existing)
        } else {
            modelContext.insert(VerseHighlight(verseID: verse.id, colorName: "yellow"))
        }
    }

    private func toggleFavorite(_ verse: BibleVerse) {
        modelContext.insert(FavoriteVerse(verse: verse))
    }
}

struct VerseRow: View {
    @EnvironmentObject private var app: AppEnvironment
    let verse: BibleVerse
    let highlight: VerseHighlight?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            if app.showVerseNumbers {
                Text("\(verse.number)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 24, alignment: .trailing)
            }
            Text(verse.text)
                .font(.system(size: app.fontSize, design: .serif))
                .lineSpacing(app.lineSpacing)
        }
        .padding(.vertical, 6)
        .listRowBackground(highlight == nil ? Color.clear : Color.yellow.opacity(0.22))
    }
}
