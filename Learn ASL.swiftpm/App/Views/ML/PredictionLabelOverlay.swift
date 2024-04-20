import SwiftUI

struct PredictionLabelOverlay: View {
    private var gameMoves: [String: Letter] {
        return GameModel().validMoves
    }
    
    private var icon: String {
        gameMoves[label]?.icon ?? Letter.unknown.icon
    }
    
    @ScaledMetric private var size: CGFloat = 80
    
    var label: String
    var showIcon: Bool = true
    
    var body: some View {
        if label.isEmpty {
            EmptyView()
        } else {
            RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                .fill(Color.translucentBlack)
                .frame(width: size, height: size)
                .padding()
                .overlay {
                    VStack {
                        if showIcon {
                            iconView()
                        }
                        Text(label)
                    }
                    .foregroundStyle(.white)
                }
        }
    }
    
    private func iconView() -> some View {
        Group {
            if icon == Letter.unknown.icon {
                Image(systemName: icon)
            } else {
                Text(icon)
            }
        }
    }
}
