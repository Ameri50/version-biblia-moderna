import SwiftData

@Model
final class bibleVerse {
    var book: String
    var chapter: Int
    var verse: Int
    var text: String
    var translation: String = "RVR1960"
    
    init(book: String, chapter: Int, verse: Int, text: String, translation: String = "RVR1960") {
        self.book = book
        self.chapter = chapter
        self.verse = verse
        self.text = text
        self.translation = translation
    }
}
