import SwiftUI

struct CellStyle: ViewModifier {
    var cornerRadius: CGFloat = 15.0
    var padding: CGFloat = 15.0
    var disabled: Bool = false
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(disabled ? Color.gray : .black)
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(disabled ? Color.gray : Color.accent)
                    .brightness(disabled ? 0.3 : 0.5)
            }
    }
}

struct ChartViewStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
//            .frame(width: 500, height: 500)
            .padding()
            .cornerRadius(10)
            .padding()
    }
}

struct GameLabelBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.thinMaterial)
    }
}

extension View {
    func gameLabelBackground() -> some View {
        modifier(GameLabelBackground())
    }
    
    func chartViewStyle() -> some View {
        modifier(ChartViewStyle())
    }
}

struct CapsuleButton: ButtonStyle {
    var backgroundColor: Color = .white
    var foregroundColor: Color = .accentColor
    var disabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .foregroundStyle(foregroundColor.opacity(disabled ? 0.7 : 1.0))
            .background(backgroundColor.opacity(disabled ? 0.5 : 1.0))
            .clipShape(Capsule())
    }
}

struct Constants {
    static let photoSpacing = 12.0
    static let photoCornerRadius = 10.0
    static let photoSize = CGSize(width: 104, height: 104)
}

// From Fruta Apple Developer app
struct SquishableButtonStyle: ButtonStyle {
    var fadeOnPress = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed && fadeOnPress ? 0.75 : 1)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

extension ButtonStyle where Self == SquishableButtonStyle {
    static var squishable: SquishableButtonStyle {
        SquishableButtonStyle()
    }
    
    static func squishable(fadeOnPress: Bool = true) -> SquishableButtonStyle {
        SquishableButtonStyle(fadeOnPress: fadeOnPress)
    }
}

struct ProminentButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    var squishable = false
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.title3.bold())
            .foregroundStyle(Color.accentColor)
            .padding()
            .background(backgroundColor.cornerRadius(8))
            .scaleEffect(configuration.isPressed && squishable ? 0.95 : 1)
    }
    
    private var backgroundColor: Color {
        return Color(uiColor: (colorScheme == .dark) ? .secondarySystemBackground : .systemBackground)
    }
}

extension ButtonStyle where Self == ProminentButtonStyle {
    
    static var prominent: ProminentButtonStyle {
        ProminentButtonStyle()
    }
    
    static func prominent(squishable: Bool = false) -> ProminentButtonStyle {
        ProminentButtonStyle(squishable: squishable)
    }
}
