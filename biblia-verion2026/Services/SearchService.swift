// File: Services/SearchService.swift
import Foundation

protocol BibleSearchServiceProtocol {
    func search(_ query: String, translationID: String?) -> [BibleSearchResult]
    func parseReference(_ query: String, translationID: String?) -> [BibleSearchResult]
}

final class BibleSearchService: BibleSearchServiceProtocol {
    private let repository: BibleRepositoryProtocol
    private let normalizedIndex: [String: Set<String>]
    private let versesByID: [String: BibleVerse]

    init(repository: BibleRepositoryProtocol) {
        self.repository = repository
        let verses = repository.allVerses(translationID: nil)
        versesByID = Dictionary(uniqueKeysWithValues: verses.map { ($0.id, $0) })
        var index: [String: Set<String>] = [:]
        for verse in verses {
            for token in Self.tokens(from: verse.text + " " + verse.reference) {
                index[token, default: []].insert(verse.id)
            }
        }
        normalizedIndex = index
    }

    func search(_ query: String, translationID: String?) -> [BibleSearchResult] {
        let referenceResults = parseReference(query, translationID: translationID)
        if !referenceResults.isEmpty { return referenceResults }

        let queryTokens = Self.tokens(from: query)
        guard !queryTokens.isEmpty else { return [] }

        var scores: [String: Double] = [:]
        for token in queryTokens {
            let exact = normalizedIndex[token] ?? []
            let partial = normalizedIndex
                .filter { $0.key.hasPrefix(token) || $0.key.localizedCaseInsensitiveContains(token) }
                .flatMap(\.value)
            for id in exact { scores[id, default: 0] += 2 }
            for id in partial { scores[id, default: 0] += 0.75 }
        }

        let translations = Dictionary(uniqueKeysWithValues: repository.translations.map { ($0.id, $0) })
        return scores.compactMap { id, score in
            guard let verse = versesByID[id],
                  translationID == nil || verse.translationID == translationID,
                  let translation = translations[verse.translationID]
            else { return nil }
            return BibleSearchResult(id: id, verse: verse, translation: translation, relevance: score)
        }
        .sorted { $0.relevance == $1.relevance ? $0.verse.reference < $1.verse.reference : $0.relevance > $1.relevance }
    }

    func parseReference(_ query: String, translationID: String?) -> [BibleSearchResult] {
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanQuery.isEmpty else { return [] }

        let translations = Dictionary(uniqueKeysWithValues: repository.translations.map { ($0.id, $0) })
        let candidates = repository.allVerses(translationID: translationID)
        let normalized = Self.normalize(cleanQuery)

        return candidates.compactMap { verse in
            let chapterReference = Self.normalize("\(verse.bookName) \(verse.chapter)")
            let verseReference = Self.normalize(verse.reference)
            guard normalized == chapterReference || normalized == verseReference else { return nil }
            guard let translation = translations[verse.translationID] else { return nil }
            return BibleSearchResult(id: verse.id, verse: verse, translation: translation, relevance: 10)
        }
    }

    static func tokens(from text: String) -> [String] {
        normalize(text)
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .map(String.init)
            .filter { $0.count > 1 }
    }

    static func normalize(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).lowercased()
    }
}
