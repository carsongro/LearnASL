import SwiftUI

struct PlayPauseButton: View {
    var isPlaying: Bool
    var action: () -> Void
    
    init(isPlaying: Bool, _ action: @escaping () -> Void) {
        self.isPlaying = isPlaying
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Image(systemName: "rectangle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.primary)
                    .padding(2)
                    .frame(width: 44, height: 44)
                    .padding(5)
                
                Image(systemName: isPlaying ? "pause.rectangle.fill" : "play.rectangle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                    .foregroundStyle(.thickMaterial)
                    .padding(5)
            }
            .padding()
            .contentShape(Rectangle())
            .transaction { transaction in 
                transaction.animation = .none
            }    
        }
        .buttonStyle(.squishable(fadeOnPress: true))
        .accessibilityLabel(Text(isPlaying ? "Play video" : "Pause video"))
    }
}

#Preview {
    PlayPauseButton(isPlaying: false) { }
        .previewLayout(.sizeThatFits)
}
