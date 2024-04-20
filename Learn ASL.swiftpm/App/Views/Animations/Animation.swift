import SwiftUI

extension Animation {
    static let openImage = Animation.spring(response: 0.45, dampingFraction: 0.9)
    static let closeImage = Animation.spring(response: 0.35, dampingFraction: 1)
    
    static var smooth: Animation {
        Animation.timingCurve(0.11, 0.16, 0.05, 1.53)
    }
    
    static func smooth(duration: TimeInterval = 0.2) -> Animation {
        Animation.timingCurve(0.11, 0.16, 0.00, 1.56, duration: duration)
    }
}
