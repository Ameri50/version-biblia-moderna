// File: Repositories/BibleRepository.swift
import Foundation

protocol BibleRepositoryProtocol {
    var translations: [BibleTranslation] { get }
    func books(for translationID: String) -> [BibleBook]
    func chapter(translationID: String, bookID: String, chapter: Int) -> BibleChapter?
    func verse(id: String) -> BibleVerse?
    func allVerses(translationID: String?) -> [BibleVerse]
}

final class DemoBibleRepository: BibleRepositoryProtocol {
    static let shared = DemoBibleRepository()

    let translations: [BibleTranslation]
    private let booksByTranslation: [String: [BibleBook]]

    init() {
        let bundledTranslation = BibleTranslation(
            id: "rv1909-es",
            name: "Reina-Valera 1909",
            languageCode: "es",
            abbreviation: "RV1909",
            licenseSummary: "Reina-Valera 1909. Dominio publico / CC0 segun BibleAquifer.",
            isDownloaded: true
        )
        if let bundledBooks = Self.loadBundledBible(translation: bundledTranslation), !bundledBooks.isEmpty {
            translations = [bundledTranslation]
            booksByTranslation = [bundledTranslation.id: bundledBooks]
            return
        }

        let translation = BibleTranslation(id: "demo-es", name: "Demo Biblia", languageCode: "es", abbreviation: "DEMO", licenseSummary: "Datos de demostracion; agrega los 66 JSON de RV1909 en Resources/Bible/RV1909 para habilitar la Biblia completa.", isDownloaded: true)
        translations = [translation]
        booksByTranslation = [translation.id: Self.makeBooks(translationID: translation.id)]
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

    static func makeVerse(_ translationID: String, _ bookID: String, _ book: String, _ chapter: Int, _ number: Int, _ text: String) -> BibleVerse {
        BibleVerse(id: "\(translationID)-\(bookID)-\(chapter)-\(number)", translationID: translationID, bookID: bookID, bookName: book, chapter: chapter, number: number, text: text)
    }

    private static func makeBooks(translationID: String) -> [BibleBook] {
        let genesis = BibleBook(id: "genesis", name: "Genesis", testament: .old, order: 1, chapters: [
            BibleChapter(id: "\(translationID)-genesis-1", bookID: "genesis", bookName: "Genesis", number: 1, verses: [
                makeVerse(translationID, "genesis", "Genesis", 1, 1, "En el principio creo Dios los cielos y la tierra."),
                makeVerse(translationID, "genesis", "Genesis", 1, 2, "La tierra estaba desordenada y vacia, y la luz de Dios vino sobre el caos."),
                makeVerse(translationID, "genesis", "Genesis", 1, 3, "Dijo Dios: Sea la luz; y fue la luz.")
            ])
        ])

        let psalms = BibleBook(id: "psalms", name: "Salmos", testament: .old, order: 19, chapters: [
            BibleChapter(id: "\(translationID)-psalms-23", bookID: "psalms", bookName: "Salmos", number: 23, verses: [
                makeVerse(translationID, "psalms", "Salmos", 23, 1, "El Senor es mi pastor; nada me faltara."),
                makeVerse(translationID, "psalms", "Salmos", 23, 2, "En lugares de delicados pastos me hara descansar."),
                makeVerse(translationID, "psalms", "Salmos", 23, 3, "Confortara mi alma y me guiara por sendas de justicia.")
            ])
        ])

        let john = BibleBook(id: "john", name: "Juan", testament: .new, order: 43, chapters: [
            BibleChapter(id: "\(translationID)-john-3", bookID: "john", bookName: "Juan", number: 3, verses: [
                makeVerse(translationID, "john", "Juan", 3, 16, "Porque de tal manera amo Dios al mundo; este pasaje muestra el amor de Dios al dar a su Hijo."),
                makeVerse(translationID, "john", "Juan", 3, 17, "Dios no envio a su Hijo para condenar al mundo, sino para que el mundo sea salvo.")
            ])
        ])

        let romans = BibleBook(id: "romans", name: "Romanos", testament: .new, order: 45, chapters: [
            BibleChapter(id: "\(translationID)-romans-8", bookID: "romans", bookName: "Romanos", number: 8, verses: [
                makeVerse(translationID, "romans", "Romanos", 8, 28, "Sabemos que a los que aman a Dios, todas las cosas ayudan a bien."),
                makeVerse(translationID, "romans", "Romanos", 8, 31, "Si Dios es por nosotros, quien contra nosotros?")
            ])
        ])

        return [genesis, psalms, john, romans]
    }
}

private extension DemoBibleRepository {
    struct AquiferVerse: Decodable {
        let title: String
        let indexReference: String
        let content: String

        enum CodingKeys: String, CodingKey {
            case title
            case indexReference = "index_reference"
            case content
        }
    }

    struct BookInfo {
        let id: String
        let name: String
        let testament: BibleTestament
        let order: Int
    }

    static let bookInfoByNumber: [Int: BookInfo] = {
        let names = [
            "Genesis", "Exodo", "Levitico", "Numeros", "Deuteronomio", "Josue", "Jueces", "Rut",
            "1 Samuel", "2 Samuel", "1 Reyes", "2 Reyes", "1 Cronicas", "2 Cronicas", "Esdras", "Nehemias",
            "Ester", "Job", "Salmos", "Proverbios", "Eclesiastes", "Cantares", "Isaias", "Jeremias",
            "Lamentaciones", "Ezequiel", "Daniel", "Oseas", "Joel", "Amos", "Abdias", "Jonas",
            "Miqueas", "Nahum", "Habacuc", "Sofonias", "Hageo", "Zacarias", "Malaquias", "Mateo",
            "Marcos", "Lucas", "Juan", "Hechos", "Romanos", "1 Corintios", "2 Corintios", "Galatas",
            "Efesios", "Filipenses", "Colosenses", "1 Tesalonicenses", "2 Tesalonicenses", "1 Timoteo",
            "2 Timoteo", "Tito", "Filemon", "Hebreos", "Santiago", "1 Pedro", "2 Pedro", "1 Juan",
            "2 Juan", "3 Juan", "Judas", "Apocalipsis"
        ]
        return Dictionary(uniqueKeysWithValues: names.enumerated().map { index, name in
            let order = index + 1
            let slug = normalizeID(name)
            let testament: BibleTestament = order <= 39 ? .old : .new
            return (order, BookInfo(id: slug, name: name, testament: testament, order: order))
        })
    }()

    static func loadBundledBible(translation: BibleTranslation) -> [BibleBook]? {
        let decoder = JSONDecoder()
        let urls = bundledBibleURLs()
        guard !urls.isEmpty else { return nil }

        var chaptersByBook: [Int: [Int: [BibleVerse]]] = [:]
        for url in urls.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            guard let data = try? Data(contentsOf: url),
                  let records = try? decoder.decode([AquiferVerse].self, from: data)
            else { continue }

            for record in records {
                guard let parsed = parse(indexReference: record.indexReference),
                      let info = bookInfoByNumber[parsed.book]
                else { continue }
                let text = plainText(fromHTML: record.content)
                let verse = BibleVerse(
                    id: "\(translation.id)-\(info.id)-\(parsed.chapter)-\(parsed.verse)",
                    translationID: translation.id,
                    bookID: info.id,
                    bookName: info.name,
                    chapter: parsed.chapter,
                    number: parsed.verse,
                    text: text
                )
                chaptersByBook[parsed.book, default: [:]][parsed.chapter, default: []].append(verse)
            }
        }

        return chaptersByBook.keys.sorted().compactMap { bookNumber in
            guard let info = bookInfoByNumber[bookNumber],
                  let chapters = chaptersByBook[bookNumber]
            else { return nil }
            let bibleChapters = chapters.keys.sorted().map { chapterNumber in
                BibleChapter(
                    id: "\(translation.id)-\(info.id)-\(chapterNumber)",
                    bookID: info.id,
                    bookName: info.name,
                    number: chapterNumber,
                    verses: chapters[chapterNumber, default: []].sorted { $0.number < $1.number }
                )
            }
            return BibleBook(id: info.id, name: info.name, testament: info.testament, order: info.order, chapters: bibleChapters)
        }
    }

    static func bundledBibleURLs() -> [URL] {
        let bundle = Bundle.main
        let subdirectoryURLs = bundle.urls(forResourcesWithExtension: "json", subdirectory: "Bible/RV1909") ?? []
        let flatURLs = bundle.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        let installedURLs = (try? FileManager.default.contentsOfDirectory(
            at: BibleResourceInstaller.localDirectory,
            includingPropertiesForKeys: nil
        )) ?? []
        return (installedURLs + subdirectoryURLs + flatURLs)
            .filter { $0.lastPathComponent.hasSuffix(".content.json") }
    }

    static func parse(indexReference: String) -> (book: Int, chapter: Int, verse: Int)? {
        guard indexReference.count == 8 else { return nil }
        let bookEnd = indexReference.index(indexReference.startIndex, offsetBy: 2)
        let chapterEnd = indexReference.index(bookEnd, offsetBy: 3)
        let book = Int(indexReference[..<bookEnd])
        let chapter = Int(indexReference[bookEnd..<chapterEnd])
        let verse = Int(indexReference[chapterEnd...])
        guard let book, let chapter, let verse else { return nil }
        return (book, chapter, verse)
    }

    static func plainText(fromHTML html: String) -> String {
        var text = html
            .replacingOccurrences(of: #"<sup>.*?</sup>"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"<[^>]+>"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func normalizeID(_ name: String) -> String {
        name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
    }
}
