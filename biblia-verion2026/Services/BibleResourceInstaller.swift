// File: Services/BibleResourceInstaller.swift
import Foundation

enum BibleResourceInstallerError: LocalizedError {
    case invalidURL
    case downloadFailed(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "No se pudo construir la URL de descarga."
        case .downloadFailed(let book):
            return "No se pudo descargar el libro numero \(book)."
        }
    }
}

struct BibleResourceInstaller {
    static let remoteBaseURL = "https://raw.githubusercontent.com/BibleAquifer/ReinaValera1909/main/spa/json"

    static var localDirectory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent("Bible/RV1909", isDirectory: true)
    }

    func installRV1909() async throws {
        try FileManager.default.createDirectory(at: Self.localDirectory, withIntermediateDirectories: true)

        for bookNumber in 1...66 {
            let fileName = String(format: "%02d.content.json", bookNumber)
            guard let url = URL(string: "\(Self.remoteBaseURL)/\(fileName)") else {
                throw BibleResourceInstallerError.invalidURL
            }

            let (temporaryURL, response) = try await URLSession.shared.download(from: url)
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                throw BibleResourceInstallerError.downloadFailed(bookNumber)
            }

            let destination = Self.localDirectory.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.moveItem(at: temporaryURL, to: destination)
        }
    }
}
