import SwiftUI
import SwiftData

@main
struct biblia_verion2026App: App {

    @State private var appEnvironment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appEnvironment)
        }
        .modelContainer(
            for: [
                FavoriteVerse.self,
                BibleNote.self,
                VerseHighlight.self,
                ReadingHistoryEntry.self,
                SearchHistoryEntry.self,
                AIQuestionHistoryEntry.self,
                AppPreference.self
            ]
        )
    }
}
