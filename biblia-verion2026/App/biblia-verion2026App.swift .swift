import SwiftUI

@main
struct biblia_verion2026App: App {

    @StateObject private var bibleManager = BibleManager()  // ✅ Mayúscula

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bibleManager)
        }
    }
}
