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
        let translation = BibleTranslation(id: "demo-es", name: "Demo Biblia", languageCode: "es", abbreviation: "DEMO", licenseSummary: "Datos de demostracion; reemplazar por textos de dominio publico o con licencia.", isDownloaded: true)
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
                makeVerse(translationID, "john", "Juan", 3, 16, "Porque de tal manera amo Dios al mundo, que dio a su Hijo, para que todo aquel que cree tenga vida eterna."),
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
