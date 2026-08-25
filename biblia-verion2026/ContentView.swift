// File: ContentView.swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        BibleRootView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [FavoriteVerse.self, BibleNote.self, VerseHighlight.self, ReadingHistoryEntry.self, SearchHistoryEntry.self, AIQuestionHistoryEntry.self, AppPreference.self], inMemory: true)
}
