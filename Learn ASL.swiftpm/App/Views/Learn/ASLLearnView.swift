import SwiftUI
import TipKit

struct OptimalHandPlacementTip: Tip {
    var title: Text {
        Text("Optimal hand placement")
    }
    
    var message: Text? {
        Text("For the best results, place your hand in the center of the frame 6-12 inches from the camera. It's okay if some parts of your hand are outside of the frame, and it's okay to try different hand angles. If predictions are consistently incorrect, restarting the app may help.")
    }
}

struct ASLLearnView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @EnvironmentObject var appModel: AppModel
    
    @State var gameModel = GameModel()
    @Namespace private var namespace
    
    @State private var movePosition: String?
    
    @State private var predictedMove: String = Letter.unknown.name
    @State private var gameResultText: String = ""
    @State private var countingDown = false
    @State private var showingFullScreenImage = false
    @State private var showingFullScreenVideo = false
    @State private var isPlayingVideo = true
    @State private var isQuizMode = false
    
    var optimalHandPlacementTip = OptimalHandPlacementTip()
    
    private var shouldDisablePlayButton: Bool {
        guard gameModel.currentState != .playing else { return true }
        return !appModel.isHandInFrame || !appModel.isGatheringObservations || !gameResultText.isEmpty
    }
    
    private let padding: CGFloat = 20
    
    private var label: String {
        switch gameModel.currentState {
        case .playing: return String(gameModel.countDown)
        default: return gameModel.computersMoveName == "J" || gameModel.computersMoveName == "Z" ? "Hold the sign during the count down at the end position of the sign" : "Hold the sign during the count down"
        }
    }
    
    var infoTapHandler: (() -> Void)?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                computersMoveView()
                    .overlay(alignment: .center) {
                        scrollPositionButtonOverlay()
                    }
                labelView()
                yourMoveView()
            }
            
            if showingFullScreenImage {
                fullScreenImage()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(fullScreenImageBackground())
            }
            
            if showingFullScreenVideo {
                fullScreenVideo()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(fullScreenImageBackground())
            }
        }
        .onAppear {
            movePosition = gameModel.computersMoveName
        }
        .onChange(of: movePosition, { oldValue, newValue in
            if newValue != gameModel.computersMoveName {
                gameModel.computersMoveName = newValue ?? gameModel.computersMoveName
                gameModel.playButtonText = "Check sign"
            }
        })
        .onChange(of: gameModel.computersMoveName, { oldValue, newValue in
            if newValue != movePosition {
                withAnimation(reduceMotion ? nil : .default) {
                    movePosition = newValue
                }
            }
        })
        .onReceive(gameModel.gameTimer) { _ in
            let resultText = gameModel.updateGameTimer()
            guard !resultText.isEmpty else { return }
            gameResultText = resultText
        }
        .background(gameBackground())
    }
    
    private func fullScreenImageBackground() -> some View {
        Rectangle()
            .foregroundStyle(.ultraThinMaterial)
    }
    
    private func computersMoveView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack { 
                ForEach(gameModel.validMoveNames, id: \.self) { name in
                    MoveView(
                        moveName: name, 
                        countingDown: countingDown && name == gameModel.computersMoveName, 
                        showingImage: showingFullScreenImage, 
                        showingVideo: showingFullScreenVideo,
                        namespace: namespace,
                        canPlayVideo: name == gameModel.computersMoveName,
                        showTutorial: !isQuizMode
                    ) {
                        selectImage()
                    } videoTapHandler: {
                        selectVideo()
                    }
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
                            .scaleEffect(phase.isIdentity ? 1 : 0.97)
                            .blur(radius: phase.isIdentity ? 0 : 4)
                    }
                }
            }
            .contentMargins(20, for: .scrollContent)
            .scrollTargetLayout()
            .listRowInsets(EdgeInsets())
        }
        .scrollPosition(id: $movePosition)
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, 55, for: .scrollContent)
        .environment(gameModel)
        .frame(maxHeight: 300)
    }
    
    private func labelView() -> some View {
        Text(label)
            .font(.largeTitle)
            .foregroundStyle(.primary)
            .transition(.slide)
            .padding(padding / 2)
            .frame(maxWidth: .infinity)
            .gameLabelBackground()
    }
    
    private func imageLabelView() -> some View {
        Text(gameModel.computersMoveName)
            .font(.largeTitle)
            .foregroundStyle(.primary)
            .transition(.slide)
            .padding(padding / 2)
            .frame(maxWidth: .infinity)
            .gameLabelBackground()
    }
    
    @ViewBuilder
    private func gameResultView() -> some View {
        if gameModel.currentState == .finished {
            Text(gameResultText)
                .font(.largeTitle)
                .foregroundStyle(.primary)
                .padding(padding)
                .gameLabelBackground()
                .cornerRadius(10.0)
                .opacity(gameResultText.isEmpty ? 0.0 : 1.0)
                .animation(.linear, value: gameResultText.isEmpty)
        }
    }
    
    @ViewBuilder
    private func yourMoveView() -> some View {
        ZStack {
            camera()
        }
        .overlay(alignment: .center) {
            gameResultView()
                .padding(.bottom, padding)
                .animation(.easeIn, value: !gameResultText.isEmpty)
        }
    }
    
    private func camera() -> some View {
        CameraView()
            .allowsHitTesting(false)
            .environmentObject(appModel)
            .onChange(of: gameModel.currentState) { _, _ in
                updateCameraAppearance(currentState: gameModel.currentState)
            }
            .onChange(of: appModel.predictionLabel) { _, _ in
                guard gameModel.currentState != .finished else { return }
                updateYourMove(with: appModel.predictionLabel)
                
            }
            .overlay(alignment: .bottom) {
                VStack {
                    PredictionLabelOverlay(label: appModel.predictionLabel, showIcon: false)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    TipView(optimalHandPlacementTip, arrowEdge: .bottom)
                    playButton()
                        .overlay(alignment: .center) {
                            HStack {
                                Toggle("Quiz mode", isOn: $isQuizMode.animation(reduceMotion ? nil : .default))
                                    .padding()
                                    .frame(maxWidth: 200)
                                    .foregroundStyle(.white)
                                
                                Spacer()
                                
                                Button {
                                    infoTapHandler?()
                                } label: {
                                    Image(systemName: "info.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding(6)
                                        .frame(width: 44, height: 44)
                                        .foregroundStyle(.white)
                                        .padding()
                                }
                                .accessibilityLabel(Text("Show information page"))
                            }
                        }
                        .background(Color.translucentBlack)
                }
            }
            .task {
                try? Tips.configure([
                    .displayFrequency(.immediate),
                    .datastoreLocation(.applicationDefault)
                ])
            }
    }
    
    private func playButton() -> some View {
        Button {
            gameModel.updateGameState()
        } label: {
            Text(gameModel.playButtonText)
        }
        .buttonStyle(CapsuleButton(disabled: shouldDisablePlayButton))
        .disabled(shouldDisablePlayButton)
        .padding()
        .frame(maxWidth: .infinity)
    }
    
    private func gameBackground() -> some View {
        gradient
    }
    
    @ViewBuilder
    private func fullScreenImage() -> some View {
        if let moveImage = gameModel.validMoves[gameModel.computersMoveName]?.tutorialImage, showingFullScreenImage {
            moveImage
                .resizable()
                .overlay(alignment: .topTrailing) { 
                    ImageActionButton(
                        label: "Deselect image", 
                        systemImage: "xmark.circle.fill", 
                        deselectImage
                    )
                }
                .overlay(alignment: .bottom) {
                    imageLabelView()
                }
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding()
                .zIndex(1)
                .shadow(radius: 10)
                .matchedGeometryEffect(id: gameModel.computersMoveName, in: namespace)
                .accessibilityLabel(Text("Full screen tutorial image"))
        }
    }
    
    @ViewBuilder
    private func fullScreenVideo() -> some View {
        if showingFullScreenVideo {
            LetterVideo(for: gameModel.computersMoveName, isPlaying: isPlayingVideo)
                .overlay(alignment: .topTrailing) { 
                    ImageActionButton(
                        label: "Deselect video", 
                        systemImage: "xmark.circle.fill", 
                        deselectVideo
                    )
                }
                .overlay(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        PlayPauseButton(isPlaying: isPlayingVideo) { 
                            isPlayingVideo.toggle()
                        }
                        
                        imageLabelView()
                    }
                }
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding()
                .zIndex(1)
                .shadow(radius: 10)
                .matchedGeometryEffect(id: gameModel.computersMoveName + "video", in: namespace)
                .accessibilityLabel(Text("Full screen tutorial video"))
        }
    }
    
    private func scrollPositionButtonOverlay() -> some View {
        HStack {
            Button{
                gameModel.updateComputersMove(direction: .backward)
            } label: {
                Image(systemName: "chevron.compact.left")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.thickMaterial)
                    .padding(4)
                    .frame(width: 44)
                    .frame(maxHeight: 88)
                    .fontWeight(.ultraLight)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.squishable)
            .accessibilityLabel(Text("Previous letter"))
            
            Spacer()
            
            Button {
                gameModel.updateComputersMove(direction: .forward)
            } label: {
                Image(systemName: "chevron.compact.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.thickMaterial)
                    .padding(4)
                    .frame(width: 44)
                    .frame(maxHeight: 88)
                    .fontWeight(.ultraLight)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.squishable)
            .accessibilityLabel(Text("Next letter"))
        }
        .padding(.horizontal, 4)
    }
    
    private func updateYourMove(with predicationLabel: String) {
        guard !predicationLabel.isEmpty else {
            gameModel.yourMoveName = Letter.unknown.name
            return
        }
        predictedMove = predicationLabel
        gameModel.yourMoveName = predictedMove
    }
    
    private func updateCameraAppearance(currentState: GameState) {
        switch currentState {
        case .playing:
            appModel.shouldPauseCamera = false
            withAnimation(reduceMotion ? nil : .smooth(duration: 3)) {
                countingDown = true
            }
        case .finished:
            appModel.isGatheringObservations = false
            withAnimation(reduceMotion ? nil : .bouncy) {
                countingDown = false
            }
            Task {
                appModel.shouldPauseCamera = true
                await Task.sleep(seconds: 1.5)
                gameResultText = ""
                appModel.shouldPauseCamera = false
                gameModel.currentState = .notPlaying
            }
        case .notPlaying:
            appModel.shouldPauseCamera = false
            withAnimation(reduceMotion ? nil : .bouncy) {
                countingDown = false
            }
        }
    }
    
    private var gradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: (130.0 / 255.0), green: (109.0 / 255.0), blue: (204.0 / 255.0)),
                Color(red: (130.0 / 255.0), green: (130.0 / 255.0), blue: (211.0 / 255.0)),
                Color(red: (131.0 / 255.0), green: (160.0 / 255.0), blue: (218.0 / 255.0))
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .flipsForRightToLeftLayoutDirection(false)
        .ignoresSafeArea()
    }
    
    private func selectImage() {
        withAnimation(reduceMotion ? nil : .openImage) {
            showingFullScreenImage = true
        }
    }
    
    private func deselectImage() {
        withAnimation(reduceMotion ? nil : .closeImage) {
            showingFullScreenImage = false
        }
    }
    
    private func selectVideo() {
        withAnimation(reduceMotion ? nil : .openImage) {
            showingFullScreenVideo = true
        }
        isPlayingVideo = true
    }
    
    private func deselectVideo() {
        withAnimation(reduceMotion ? nil : .closeImage) {
            showingFullScreenVideo = false
        }
        isPlayingVideo = true
    }
}

#Preview {
    ASLLearnView()
        .environmentObject(AppModel())   
}
