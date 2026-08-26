import SwiftData
import SwiftUI
import Observation

@Observable
class appEnvironment {
    var openaiAPIKey: String = ""
    var aiEnabled: Bool = true
    
    init(openaiAPIKey: String = "", aiEnabled: Bool = true) {
        self.openaiAPIKey = openaiAPIKey
        self.aiEnabled = aiEnabled
    }
}
