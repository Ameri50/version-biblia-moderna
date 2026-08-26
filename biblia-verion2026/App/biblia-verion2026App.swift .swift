import SwiftUI
import SwiftData

@main
struct biblia_verion2026App: App {
    let modelContainer: ModelContainer
   

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
    
    init() {
        do {
            modelContainer = try ModelContainer(
                for: 
                    FavoriteVerse.self,
                BibleNote.self,
                VerseHighlight.self,
                ReadingHistoryEntry.self,
                SearchHistoryEntry.self,
                AIQuestionHistoryEntry.self,
                AppPreference.self,
                
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
}
