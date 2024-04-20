import SwiftUI

struct RadialLayout: Layout {
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        let radius = min(bounds.size.width, bounds.size.height) / 3.0
        
        let angle = Angle.degrees(360.0 / Double(subviews.count)).radians
        
        for (index, subview) in subviews.enumerated() {
            var point = CGPoint(x: 0, y: -radius)
                .applying(CGAffineTransform(
                    rotationAngle: angle * Double(index)))
            
            point.x += bounds.midX
            point.y += bounds.midY
            
            subview.place(at: point, anchor: .center, proposal: .unspecified)
        }
    }
}

class SmallDot : Identifiable, ObservableObject {
    let id = UUID()
    
    @Published var offset : CGSize = .zero
    @Published var color : Color = .primary
}


@Observable class BigDot : Identifiable {
    let id = UUID()
    
    var offset: CGSize = .zero
    var color: Color = .primary
    var scale: Double = 1.0
    var smallDots = [SmallDot]()
    
    init() {
        for _ in 0..<8 {
            smallDots.append(SmallDot())
        }
    }
    
    
    func randomizePositions() {
        for dot in smallDots {
            dot.offset = CGSize(width: Double.random(in: -40...40), height: Double.random(in: -40...40))
            dot.color = DotTracker.randomColor
        }
    }
    
    
    func resetPositions() {
        for dot in smallDots {
            dot.offset = .zero
            dot.color = .primary
        }
    }
}

@Observable class DotTracker {
    var bigDots = [BigDot]()
    
    static var colors: [Color] = [.pink, .purple, .mint, .blue, .yellow, .red, .teal, .cyan]
    static var randomColor: Color {
        colors.randomElement() ?? .blue
    }
    
    init() {
        for _ in 0..<7 {
            bigDots.append(BigDot())
        }
    }
    
    func randomizePositions() {
        for bigDot in bigDots {
            bigDot.offset = CGSize(width: Double.random(in: -35...35), height: Double.random(in: -35...35))
            bigDot.scale = 2.5
            bigDot.color = DotTracker.randomColor
            bigDot.randomizePositions()
        }
    }
    
    
    func resetPositions() {
        for bigDot in bigDots {
            bigDot.offset = .zero
            bigDot.scale = 1.0
            bigDot.color = DotTracker.randomColor
            bigDot.resetPositions()
        }
    }
}

struct LoadingView: View {
    var isAnimating: Bool
    
    @State private var tracker = DotTracker()
        
    var body: some View {
        RadialLayout {
            ForEach(tracker.bigDots) { bigDot in
                ZStack {
                    Circle()
                        .offset(bigDot.offset)
                        .foregroundStyle(bigDot.color)
                        .scaleEffect(bigDot.scale)
                    
                    ForEach(bigDot.smallDots) { smallDot in
                        Circle()
                            .offset(smallDot.offset)
                            .foregroundStyle(smallDot.color)
                    }
                }
            }
        }
        .frame(minWidth: 90, maxWidth: 150, minHeight: 90, maxHeight: 150)
        .padding(100)
        .drawingGroup()
        .onChange(of: isAnimating) { oldValue, newValue in
            if newValue {
                withAnimation(.smooth(duration: 3)) {
                    tracker.randomizePositions()
                }
            } else {
                withAnimation {
                    tracker.resetPositions()
                }
            }
        }
    }
}

#Preview {
    LoadingView(isAnimating: false)
}
