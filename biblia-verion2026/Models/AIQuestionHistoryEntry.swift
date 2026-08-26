import SwiftData
import Foundation

@Model
final class aIQuestionHistoryEntry {
    var question: String
    var answer: String
    var timestamp: Date
    
    init(question: String, answer: String, timestamp: Date = Date()) {
        self.question = question
        self.answer = answer
        self.timestamp = timestamp
    }
}
