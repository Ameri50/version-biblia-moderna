// File: Models/BibleBookCatalog.swift
import Foundation

struct BibleBookInfo {
    /// Numero del libro 1...66, coincide con el nombre del archivo NN.content.json
    let number: Int
    let id: String
    let name: String
    let testament: BibleTestament
}

enum BibleBookCatalog {
    static func info(forNumber number: Int) -> BibleBookInfo? {
        books.first { $0.number == number }
    }

    static let books: [BibleBookInfo] = [
        BibleBookInfo(number: 1, id: "genesis", name: "Genesis", testament: .old),
        BibleBookInfo(number: 2, id: "exodus", name: "Exodo", testament: .old),
        BibleBookInfo(number: 3, id: "leviticus", name: "Levitico", testament: .old),
        BibleBookInfo(number: 4, id: "numbers", name: "Numeros", testament: .old),
        BibleBookInfo(number: 5, id: "deuteronomy", name: "Deuteronomio", testament: .old),
        BibleBookInfo(number: 6, id: "joshua", name: "Josue", testament: .old),
        BibleBookInfo(number: 7, id: "judges", name: "Jueces", testament: .old),
        BibleBookInfo(number: 8, id: "ruth", name: "Rut", testament: .old),
        BibleBookInfo(number: 9, id: "1samuel", name: "1 Samuel", testament: .old),
        BibleBookInfo(number: 10, id: "2samuel", name: "2 Samuel", testament: .old),
        BibleBookInfo(number: 11, id: "1kings", name: "1 Reyes", testament: .old),
        BibleBookInfo(number: 12, id: "2kings", name: "2 Reyes", testament: .old),
        BibleBookInfo(number: 13, id: "1chronicles", name: "1 Cronicas", testament: .old),
        BibleBookInfo(number: 14, id: "2chronicles", name: "2 Cronicas", testament: .old),
        BibleBookInfo(number: 15, id: "ezra", name: "Esdras", testament: .old),
        BibleBookInfo(number: 16, id: "nehemiah", name: "Nehemias", testament: .old),
        BibleBookInfo(number: 17, id: "esther", name: "Ester", testament: .old),
        BibleBookInfo(number: 18, id: "job", name: "Job", testament: .old),
        BibleBookInfo(number: 19, id: "psalms", name: "Salmos", testament: .old),
        BibleBookInfo(number: 20, id: "proverbs", name: "Proverbios", testament: .old),
        BibleBookInfo(number: 21, id: "ecclesiastes", name: "Eclesiastes", testament: .old),
        BibleBookInfo(number: 22, id: "songofsolomon", name: "Cantares", testament: .old),
        BibleBookInfo(number: 23, id: "isaiah", name: "Isaias", testament: .old),
        BibleBookInfo(number: 24, id: "jeremiah", name: "Jeremias", testament: .old),
        BibleBookInfo(number: 25, id: "lamentations", name: "Lamentaciones", testament: .old),
        BibleBookInfo(number: 26, id: "ezekiel", name: "Ezequiel", testament: .old),
        BibleBookInfo(number: 27, id: "daniel", name: "Daniel", testament: .old),
        BibleBookInfo(number: 28, id: "hosea", name: "Oseas", testament: .old),
        BibleBookInfo(number: 29, id: "joel", name: "Joel", testament: .old),
        BibleBookInfo(number: 30, id: "amos", name: "Amos", testament: .old),
        BibleBookInfo(number: 31, id: "obadiah", name: "Abdias", testament: .old),
        BibleBookInfo(number: 32, id: "jonah", name: "Jonas", testament: .old),
        BibleBookInfo(number: 33, id: "micah", name: "Miqueas", testament: .old),
        BibleBookInfo(number: 34, id: "nahum", name: "Nahum", testament: .old),
        BibleBookInfo(number: 35, id: "habakkuk", name: "Habacuc", testament: .old),
        BibleBookInfo(number: 36, id: "zephaniah", name: "Sofonias", testament: .old),
        BibleBookInfo(number: 37, id: "haggai", name: "Hageo", testament: .old),
        BibleBookInfo(number: 38, id: "zechariah", name: "Zacarias", testament: .old),
        BibleBookInfo(number: 39, id: "malachi", name: "Malaquias", testament: .old),
        BibleBookInfo(number: 40, id: "matthew", name: "Mateo", testament: .new),
        BibleBookInfo(number: 41, id: "mark", name: "Marcos", testament: .new),
        BibleBookInfo(number: 42, id: "luke", name: "Lucas", testament: .new),
        BibleBookInfo(number: 43, id: "john", name: "Juan", testament: .new),
        BibleBookInfo(number: 44, id: "acts", name: "Hechos", testament: .new),
        BibleBookInfo(number: 45, id: "romans", name: "Romanos", testament: .new),
        BibleBookInfo(number: 46, id: "1corinthians", name: "1 Corintios", testament: .new),
        BibleBookInfo(number: 47, id: "2corinthians", name: "2 Corintios", testament: .new),
        BibleBookInfo(number: 48, id: "galatians", name: "Galatas", testament: .new),
        BibleBookInfo(number: 49, id: "ephesians", name: "Efesios", testament: .new),
        BibleBookInfo(number: 50, id: "philippians", name: "Filipenses", testament: .new),
        BibleBookInfo(number: 51, id: "colossians", name: "Colosenses", testament: .new),
        BibleBookInfo(number: 52, id: "1thessalonians", name: "1 Tesalonicenses", testament: .new),
        BibleBookInfo(number: 53, id: "2thessalonians", name: "2 Tesalonicenses", testament: .new),
        BibleBookInfo(number: 54, id: "1timothy", name: "1 Timoteo", testament: .new),
        BibleBookInfo(number: 55, id: "2timothy", name: "2 Timoteo", testament: .new),
        BibleBookInfo(number: 56, id: "titus", name: "Tito", testament: .new),
        BibleBookInfo(number: 57, id: "philemon", name: "Filemon", testament: .new),
        BibleBookInfo(number: 58, id: "hebrews", name: "Hebreos", testament: .new),
        BibleBookInfo(number: 59, id: "james", name: "Santiago", testament: .new),
        BibleBookInfo(number: 60, id: "1peter", name: "1 Pedro", testament: .new),
        BibleBookInfo(number: 61, id: "2peter", name: "2 Pedro", testament: .new),
        BibleBookInfo(number: 62, id: "1john", name: "1 Juan", testament: .new),
        BibleBookInfo(number: 63, id: "2john", name: "2 Juan", testament: .new),
        BibleBookInfo(number: 64, id: "3john", name: "3 Juan", testament: .new),
        BibleBookInfo(number: 65, id: "jude", name: "Judas", testament: .new),
        BibleBookInfo(number: 66, id: "revelation", name: "Apocalipsis", testament: .new)
    ]
}
