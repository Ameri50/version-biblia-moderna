import Foundation

final class ConversationStorage {
    static let shared = ConversationStorage()

    private let folderURL: URL = {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = docs.appendingPathComponent("Conversations", isDirectory: true)
        try? fm.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }()

    private func fileURL(for id: String) -> URL {
        folderURL.appendingPathComponent("\(id).json")
    }

    func save(_ convo: Conversation) throws {
        let data = try JSONEncoder().encode(convo)
        let url = fileURL(for: convo.id)
        try data.write(to: url, options: .atomic)
    }

    func delete(_ convo: Conversation) throws {
        let url = fileURL(for: convo.id)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    func loadAll() -> [Conversation] {
        (try? FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil))?
            .compactMap { url in
                guard url.pathExtension == "json", let data = try? Data(contentsOf: url) else { return nil }
                return try? JSONDecoder().decode(Conversation.self, from: data)
            } ?? []
    }
}
