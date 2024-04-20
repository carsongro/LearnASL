import SwiftUI

@main
struct LearnASLApp: App {
    @StateObject var appModel = AppModel()
    
    var body: some Scene {
        WindowGroup {
            MLLearnView()
                .environmentObject(appModel)
        }
    }
}
