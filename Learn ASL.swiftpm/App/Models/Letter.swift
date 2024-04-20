import SwiftUI

final class Letter {
    static var unknown = Letter(name: "unknown", icon: "questionmark")
    var name: String
    var icon: String
    var tutorialImage: Image
    
    init(name: String, icon: String) {
        self.name = name.capitalized
        self.icon = icon
        self.tutorialImage = Image(name)
    }
    
    func compare(to move: Letter) -> GameResult {
        return self == move ? .correct : .incorrect
    }
}

extension Letter: Equatable {
    static func == (lhs: Letter, rhs: Letter) -> Bool {
        lhs.name == rhs.name
    }
}

enum Player {
    case you
    case computer
}
