import Foundation

struct Message: Codable, Identifiable {
    let id: UUID
    let sender: String
    let text: String
    let date: Date

    init(id: UUID = UUID(), sender: String, text: String, date: Date = Date()) {
        self.id = id
        self.sender = sender
        self.text = text
        self.date = date
    }
}

struct Conversation: Codable, Identifiable {
    public var id: String
    public var title: String
    public var messages: [Message]
    public var bibleMode: Bool

    public init(id: String = UUID().uuidString, title: String = "Chat", messages: [Message] = [], bibleMode: Bool = false) {
        self.id = id
        self.title = title
        self.messages = messages
        self.bibleMode = bibleMode
    }
}
