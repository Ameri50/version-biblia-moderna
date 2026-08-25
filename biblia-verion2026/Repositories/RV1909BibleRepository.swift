// File: Repositories/RV1909BibleRepository.swift
import Foundation

/// Carga la Biblia Reina-Valera 1909 completa (66 libros) desde los JSON
/// de BibleAquifer incluidos en el bundle de la app (Resources/Bible/RV1909).
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

    /// true si logro cargar al menos un libro desde el bundle.
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
        var books: [BibleBook] = []
        let decoder = JSONDecoder()

        for info in BibleBookCatalog.books {
            let fileNumber = String(format: "%02d", info.number)

            guard
                let url = Bundle.main.url(
                    forResource: "\(fileNumber).content",
                    withExtension: "json",
                    subdirectory: "RV1909"
                ),
                let data = try? Data(contentsOf: url),
                let rawVerses = try? decoder.decode([RawVerse].self, from: data)
            else {
                // Archivo no incluido todavia en el bundle: se omite este libro.
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

/// Decide que repositorio usar: la RV1909 completa si los JSON ya estan en el bundle,
/// o el demo como respaldo si alguien clona el repo sin correr el script de descarga.
enum BibleRepositoryFactory {
    static func makeDefault() -> BibleRepositoryProtocol {
        let full = RV1909BibleRepository.shared
        return full.hasContent ? full : DemoBibleRepository.shared
    }
}
