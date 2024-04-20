import SwiftUI

@Observable final class GameModel {
    static var countDown: Int = 3
    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var playButtonText: String = "Check sign"
    let validMoves: [String: Letter] = {
        var moves = [String: Letter]()
        Alphabet.allCases.forEach { letter in
            moves[letter.rawValue] = Letter(name: letter.rawValue, icon: letter.rawValue)
        }
        return moves
    }()
    
    var validMoveNames: [String] {
        validMoves.values.map{ $0.name }.sorted()
    }
    
    var countDown: Int = GameModel.countDown
    var currentState: GameState = .notPlaying
    var yourMoveName: String = Letter.unknown.name
    var computersMoveName: String
    
    private var yourMove: Letter {
        validMoves[yourMoveName] ?? Letter.unknown
    }
    
    private var computersMove: Letter {
        validMoves[computersMoveName] ?? Letter.unknown
    }
    
    init() {
        computersMoveName = validMoves["A"]?.name ?? Letter.unknown.name
    }
    
    func updateGameState() {
        switch currentState {
        case .notPlaying:
            currentState = .playing
        case .playing:
            currentState = .notPlaying
        case .finished:
            currentState = .playing
        }
    }
    
    func updateComputersMove(direction: RotationDirection = .forward) {
        let nextMove = rotateThroughValidMoves(computersMoveName, direction: direction)
        computersMoveName = nextMove.name
    }
    
    func updateGameResultText() -> String {
        var text = ""
        
        guard currentState == .finished else { return text }
        
        let result = getGameResult()
        
        switch result {
        case .correct: 
            text = "CORRECT"
            Task { @MainActor in
                await Task.sleep(seconds: 0.3)
                updateComputersMove()
                playButtonText = "Check sign"
            }
        case .incorrect:
            text = "TRY AGAIN"
            playButtonText = "Try again"
        case .inconclusive:
            text = "INCONCLUSIVE"
            playButtonText = "Try again"
        }
        
        return text
    }
    
    func updateGameTimer() -> String {
        switch currentState {
        case .playing:
            if countDown > 0 {
                countDown -= 1
            }
            
            if countDown == 0 {
                currentState = .finished
                countDown = GameModel.countDown
            }
            return updateGameResultText()
        case .finished, .notPlaying:
            return ""
        }
    }
    
    func rotateThroughValidMoves(_ currentMove: String, direction: RotationDirection = .forward) -> Letter {
        guard let firstMoveName = validMoveNames.first,
              let firstMove = validMoves[firstMoveName],
              let lastMoveName = validMoveNames.last,
              let lastMove = validMoves[lastMoveName] else {
            return Letter.unknown            
        }
        
        guard let index = validMoveNames.firstIndex(of: currentMove) else { return firstMove }
        switch direction {
        case .forward:
            if index + 1 < validMoveNames.count {
                let moveName = validMoveNames[index + 1]
                return validMoves[moveName] ?? firstMove
            } else {
                return firstMove
            }
        case .backward:
            if index - 1 >= 0 {
                let moveName = validMoveNames[index - 1]
                return validMoves[moveName] ?? lastMove
            } else {
                return lastMove
            }
        }
    }
    
    private func getGameResult() -> GameResult {
        guard yourMove != Letter.unknown,
              computersMove != Letter.unknown else {
            return .inconclusive
        }
        
        return yourMove.compare(to: computersMove)
    }
}

enum GameState: String {
    case notPlaying
    case playing
    case finished
}

enum GameResult {
    case correct
    case incorrect
    case inconclusive
}

enum RotationDirection {
    case forward
    case backward
}
