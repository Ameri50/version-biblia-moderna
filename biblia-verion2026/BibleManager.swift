import Foundation
import SwiftUI
import Combine


@MainActor
final class BibleManager: ObservableObject {  // ✅ Mayúscula
    // ... resto del código

    @Published var books: [BibleBook] = []
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let installer = BibleResourceInstaller()

    init() {
        Task {
            await loadBible()
        }
    }

    func loadBible() async {
        isLoading = true
        errorMessage = nil

        do {
            // Verifica si los recursos ya están instalados
            if !BibleResourceInstaller.isComplete {
                try await installer.installRV1909()
            }

            // Usa tu repositorio existente
            _ = RV1909BibleRepository()

           

        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error cargando Biblia: \(error)")
        }

        isLoading = false
    }
}
