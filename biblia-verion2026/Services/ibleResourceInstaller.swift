import Foundation

enum bibleResourceInstallerError: LocalizedError {
    case invalidURL
    case downloadFailed(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "No se pudo construir la URL de descarga."

        case .downloadFailed(let book):
            return "No se pudo descargar el libro número \(book)."
        }
    }
}

struct bibleResourceInstaller {

    static let remoteBaseURL =
        "https://raw.githubusercontent.com/BibleAquifer/ReinaValera1909/main/spa/json"

    static var localDirectory: URL {
        let base = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]

        return base.appendingPathComponent(
            "Bible/RV1909",
            isDirectory: true
        )
    }

    /// Descarga los 66 archivos de la Reina-Valera 1909.
    func installRV1909() async throws {

        let directory = Self.localDirectory

        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        print("📖 Iniciando descarga de la Reina-Valera 1909...")

        for bookNumber in 1...66 {

            let fileName = String(
                format: "%02d.content.json",
                bookNumber
            )

            guard let url = URL(
                string: "\(Self.remoteBaseURL)/\(fileName)"
            ) else {
                throw BibleResourceInstallerError.invalidURL
            }

            do {
                let (temporaryURL, response) =
                    try await URLSession.shared.download(
                        from: url
                    )

                guard
                    let httpResponse = response as? HTTPURLResponse,
                    (200..<300).contains(httpResponse.statusCode)
                else {
                    throw BibleResourceInstallerError
                        .downloadFailed(bookNumber)
                }

                let destination =
                    directory.appendingPathComponent(fileName)

                if FileManager.default.fileExists(
                    atPath: destination.path
                ) {
                    try FileManager.default.removeItem(
                        at: destination
                    )
                }

                try FileManager.default.moveItem(
                    at: temporaryURL,
                    to: destination
                )

                print("✅ \(fileName)")

            } catch {
                print("❌ Error descargando \(fileName): \(error)")

                throw BibleResourceInstallerError
                    .downloadFailed(bookNumber)
            }
        }

        print("🎉 Biblia Reina-Valera 1909 descargada correctamente.")
        print("📁 \(directory.path)")
    }

    /// Comprueba cuántos libros están descargados.
    static var downloadedBooksCount: Int {

        guard
            let files = try? FileManager.default.contentsOfDirectory(
                at: localDirectory,
                includingPropertiesForKeys: nil
            )
        else {
            return 0
        }

        return files.filter {
            $0.lastPathComponent.hasSuffix(".content.json")
        }.count
    }

    /// Indica si están disponibles los 66 libros.
    static var isComplete: Bool {
        downloadedBooksCount == 66
    }
}
