import SwiftUI

struct MoveView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(GameModel.self) private var gameModel
    
    var moveName: String
    var countingDown: Bool
    var showingImage: Bool
    var showingVideo: Bool
    var namespace: Namespace.ID
    var canPlayVideo: Bool
    var showTutorial: Bool
    var imageTapHandler: () -> Void
    var videoTapHandler: () -> Void
    
    @State private var rotationTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var rotation = 0.0
    @State private var currentMove: Letter = Letter.unknown
    @State private var isPlayingVideo = true
    
    @ScaledMetric private var iconPadding: CGFloat = 20
    @ScaledMetric private var viewPadding: CGFloat = 5
    @ScaledMetric private var scaledPadding: CGFloat = 20
    @ScaledMetric private var fontSize: CGFloat = 80
    @ScaledMetric private var arrowFontSize: CGFloat = 55
    @ScaledMetric private var cornerRadius: CGFloat = 15
    
    var itemShadow: CGFloat {
        countingDown ? 10 : 5
    }
    
    var body: some View {
        HStack {
            if showTutorial {
                tutorialImageView()
                
                tutorialVideoView()
            }
            
            shape()
                .overlay(alignment: .center) {
                    icon()
                        .scaleEffect(countingDown && !reduceMotion ? 1.1 : 1)
                }
                .padding(viewPadding)
                .onChange(of: moveName) { _, _ in
                    getCurrentMove()
                }
                .onAppear {
                    getCurrentMove()
                }
                .padding()
                .animation(reduceMotion ? nil : .smooth(duration: 3), value: countingDown)
        }
        .frame(maxWidth: .infinity, maxHeight: 280)
        .gameLabelBackground()
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .containerRelativeFrame(.horizontal)
        .scaleEffect(countingDown ? 0.99 : 1)
    }
    
    @ViewBuilder
    private func tutorialImageView() -> some View {
        if !showingImage {
            Button(action: imageTapHandler) {
                currentMove.tutorialImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding()
                    .overlay(alignment: .bottomTrailing) {
                        expandIcon()
                    }
                    .shadow(radius: 5, y: 5)
                    .contentShape(Rectangle())
                    .frame(minWidth: 150)
                    .matchedGeometryEffect(id: moveName, in: namespace)
            }
            .buttonStyle(.squishable(fadeOnPress: false))
            .accessibility(label: Text("Open full screen image"))
        }
    }
    
    @ViewBuilder
    private func tutorialVideoView() -> some View {
        if (moveName == "J" || moveName == "Z") && !showingVideo {
            Button(action: videoTapHandler) {
                LetterVideo(for: moveName, isPlaying: isPlayingVideo && canPlayVideo)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding()
                    .overlay(alignment: .bottomTrailing) {
                        expandIcon()
                    }
                    .overlay(alignment: .bottomLeading) {
                        PlayPauseButton(isPlaying: isPlayingVideo) { 
                            isPlayingVideo.toggle()
                        }
                    }
                    .contentShape(Rectangle())
                    .onAppear {
                        isPlayingVideo = true
                    }
                    .shadow(radius: 5, y: 5)
                    .frame(minWidth: 150)
                    .matchedGeometryEffect(id: moveName + "video", in: namespace)
            }
            .buttonStyle(.squishable(fadeOnPress: false))
            .accessibilityLabel(Text("Open full screen video"))
        }
    }
    
    private func shape() -> some View {
        ZStack {
            if !reduceMotion {
                LoadingView(isAnimating: countingDown)
                    .rotationEffect(.degrees(rotation))
                    .onReceive(rotationTimer) { _ in
                        withAnimation(.linear) {
                            rotation += countingDown ? 1 : 0
                        }
                    }
                    .opacity(countingDown ? 1 : 0)
            }
            
            Circle()
                .fill(.thinMaterial)
                .shadow(color: .translucentBlack, radius: itemShadow, y: itemShadow)
                .frame(maxHeight: 120)
                .scaleEffect(countingDown ? 1.1 : 1)
        }
    }
    
    private func icon() -> some View {
        Group {
            if currentMove == Letter.unknown {
                Image(systemName: currentMove.icon)
                    .foregroundStyle(.primary)
            } else {
                Text(currentMove.icon)
                    .foregroundStyle(.primary)
            }
        }
        .fixedSize()
        .font(.system(size: fontSize))
        .padding(iconPadding)
    }
    
    private func expandIcon() -> some View {
        ZStack {
            Image(systemName: "square.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(2)
                .frame(width: 22, height: 22)
                .foregroundStyle(.primary)
                .padding(5)
            
            Image(systemName: "arrow.down.backward.and.arrow.up.forward.square.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 22, height: 22)
                .foregroundStyle(.thickMaterial)
                .padding(5)
        }
        .padding()
        .accessibilityHidden(true)
    }
    
    private func getCurrentMove() {
        currentMove = gameModel.validMoves[moveName] ?? Letter.unknown
    }
}
