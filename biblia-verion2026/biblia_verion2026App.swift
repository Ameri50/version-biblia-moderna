// File: App/biblia_verion2026App.swift
import SwiftData
import SwiftUI

@main
struct biblia_verion2026App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FavoriteVerse.self,
            BibleNote.self,
            VerseHighlight.self,
            ReadingHistoryEntry.self,
            SearchHistoryEntry.self,
            AIQuestionHistoryEntry.self,
            AppPreference.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
