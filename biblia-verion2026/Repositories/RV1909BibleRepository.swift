// File: Repositories/RV1909BibleRepository.swift
import Foundation

/// Carga la Biblia Reina-Valera 1909 completa (66 libros) desde los JSON de BibleAquifer.
/// Busca los archivos "NN.content.json" en, por orden de prioridad:
/// 1. La carpeta donde BibleResourceInstaller los descarga en tiempo de ejecucion.
/// 2. La subcarpeta "Resources/Bible/RV1909" incluida en el bundle de la app.
/// 3. La subcarpeta "Bible/RV1909" incluida en el bundle de la app.
/// 4. La subcarpeta "RV1909" incluida en el bundle de la app.
/// 5. Recursos sueltos en la raiz del bundle.
final class RV1909BibleRepository: BibleRepositoryProtocol {
    static let shared = RV1909BibleRepository()
    static let translationID = "rv1909-es"

    let translations: [BibleTranslation]
    private let booksByTranslation: [String: [BibleBook]]

    private struct RawVerse: Decodable {
        let index_reference: String
        let content: String
    }

    init() {
        let translation = BibleTranslation(
            id: Self.translationID,
            name: "Reina-Valera 1909",
            languageCode: "es",
            abbreviation: "RV1909",
            licenseSummary: "Dominio publico / CC0 (fuente: BibleAquifer)",
            isDownloaded: true
        )
        translations = [translation]
        booksByTranslation = [translation.id: Self.loadBooks(translationID: translation.id)]
    }

    /// true si logro cargar al menos un libro.
    var hasContent: Bool {
        !(booksByTranslation[Self.translationID]?.isEmpty ?? true)
    }

    func books(for translationID: String) -> [BibleBook] {
        booksByTranslation[translationID] ?? []
    }

    func chapter(translationID: String, bookID: String, chapter: Int) -> BibleChapter? {
        books(for: translationID).first { $0.id == bookID }?.chapters.first { $0.number == chapter }
    }

    func verse(id: String) -> BibleVerse? {
        booksByTranslation.values.flatMap { $0 }.flatMap(\.chapters).flatMap(\.verses).first { $0.id == id }
    }

    func allVerses(translationID: String?) -> [BibleVerse] {
        let ids = translationID.map { [$0] } ?? Array(booksByTranslation.keys)
        return ids.flatMap { booksByTranslation[$0] ?? [] }.flatMap(\.chapters).flatMap(\.verses)
    }

    // MARK: - Carga y parseo

    private static func loadBooks(translationID: String) -> [BibleBook] {
        let urlsByFileName = availableFileURLs()
        guard !urlsByFileName.isEmpty else { return [] }

        var books: [BibleBook] = []
        let decoder = JSONDecoder()

        for info in BibleBookCatalog.books {
            let fileName = String(format: "%02d.content.json", info.number)

            guard
                let url = urlsByFileName[fileName],
                let data = try? Data(contentsOf: url),
                let rawVerses = try? decoder.decode([RawVerse].self, from: data)
            else {
                // Archivo no disponible todavia: se omite este libro.
                continue
            }

            var versesByChapter: [Int: [BibleVerse]] = [:]

            for raw in rawVerses {
                // index_reference tiene formato BBCCCVVV (2 + 3 + 3 digitos)
                guard raw.index_reference.count == 8 else { continue }
                let chars = Array(raw.index_reference)
                let chapterNumber = Int(String(chars[2..<5])) ?? 0
                let verseNumber = Int(String(chars[5..<8])) ?? 0
                guard chapterNumber > 0, verseNumber > 0 else { continue }

                let verse = BibleVerse(
                    id: "\(translationID)-\(info.id)-\(chapterNumber)-\(verseNumber)",
                    translationID: translationID,
                    bookID: info.id,
                    bookName: info.name,
                    chapter: chapterNumber,
                    number: verseNumber,
                    text: cleanText(from: raw.content)
                )
                versesByChapter[chapterNumber, default: []].append(verse)
            }

            let chapters = versesByChapter.keys.sorted().map { number -> BibleChapter in
                let verses = (versesByChapter[number] ?? []).sorted { $0.number < $1.number }
                return BibleChapter(
                    id: "\(translationID)-\(info.id)-\(number)",
                    bookID: info.id,
                    bookName: info.name,
                    number: number,
                    verses: verses
                )
            }

            guard !chapters.isEmpty else { continue }

            books.append(
                BibleBook(
                    id: info.id,
                    name: info.name,
                    testament: info.testament,
                    order: info.number,
                    chapters: chapters
                )
            )
        }

        return books.sorted { $0.order < $1.order }
    }

    /// Junta los archivos "NN.content.json" disponibles en todas las ubicaciones posibles,
    /// indexados por nombre de archivo. Si el mismo archivo existe en varias ubicaciones,
    /// gana el de mayor prioridad (carpeta descargada > bundle).
    private static func availableFileURLs() -> [String: URL] {
        var result: [String: URL] = [:]

        func add(_ urls: [URL]) {
            for url in urls where url.lastPathComponent.hasSuffix(".content.json") {
                if result[url.lastPathComponent] == nil {
                    result[url.lastPathComponent] = url
                }
            }
        }

        // 1. Carpeta de descarga en tiempo de ejecucion (BibleResourceInstaller).
        let downloaded = (try? FileManager.default.contentsOfDirectory(
            at: BibleResourceInstaller.localDirectory,
            includingPropertiesForKeys: nil
        )) ?? []
        add(downloaded)

        // 2. Subcarpeta "Resources/Bible/RV1909" dentro del bundle (ruta real con
        //    "synchronized groups" de Xcode).
        add(Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "Resources/Bible/RV1909") ?? [])

        // 3. Subcarpeta "Bible/RV1909" dentro del bundle de la app.
        add(Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "Bible/RV1909") ?? [])

        // 4. Subcarpeta "RV1909" dentro del bundle de la app.
        add(Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "RV1909") ?? [])

        // 5. Recursos sueltos en la raiz del bundle.
        add(Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? [])

        return result
    }

    /// Limpia el HTML de BibleAquifer: quita <p>, <sup>N</sup>, &nbsp; y deja solo el texto plano.
    private static func cleanText(from html: String) -> String {
        var text = html
        text = text.replacingOccurrences(of: "<sup>[0-9]+</sup>", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        text = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Decide que repositorio usar: la RV1909 completa si los JSON ya estan disponibles
/// (descargados o incluidos en el bundle), o el demo como respaldo.
enum BibleRepositoryFactory {
    static func makeDefault() -> BibleRepositoryProtocol {
        let full = RV1909BibleRepository.shared
        return full.hasContent ? full : DemoBibleRepository.shared
    }
}
