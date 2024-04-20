import SwiftUI
import AVFoundation
import AVKit

struct LetterVideo: UIViewControllerRepresentable {
    let letter: String
    var isPlaying: Bool
    
    init(for letter: String, isPlaying: Bool = true) {
        self.letter = letter
        self.isPlaying = isPlaying
    }
    
    func makeUIViewController(context: Context) -> VideoPlayerViewController {
        let controller = VideoPlayerViewController(letter: letter, isPlaying: isPlaying)
        controller.isPlaying = isPlaying
        return controller
    }
    
    func updateUIViewController(_ uiViewController: VideoPlayerViewController, context: Context) {
        uiViewController.isPlaying = isPlaying
    }
}

class VideoPlayerViewController: UIViewController {
    
    var player: AVPlayer?
    var layer: AVPlayerLayer?
    var letter: String
    var isPlaying: Bool {
        didSet {
            if isPlaying {
                playVideo()
            } else {
                pauseVideo()
            }
        }
    }
    
    init(letter: String, isPlaying: Bool = true) {
        self.letter = letter
        self.isPlaying = isPlaying
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let path = Bundle.main.path(forResource: letter + "Video", ofType: "mov") else { return }
        let player = AVPlayer(url: URL(filePath: path))
        let layer = AVPlayerLayer(player: player)
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        self.layer = layer
        if let currentLayer = self.layer {
            view.layer.addSublayer(currentLayer)
        }
        player.volume = 0
        self.player = player
        if isPlaying {
            self.player?.play()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidEnd),
            name: AVPlayerItem.didPlayToEndTimeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resumeVideo),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateFrame()
    }
    
    func updateFrame() {
        self.layer?.frame = view.bounds
    }
    
    func playVideo() {
        player?.play()
    }
    
    func pauseVideo() {
        player?.pause()
    }
    
    @objc private func videoDidEnd() {
        player?.seek(to: .zero)
        player?.play()
    }
    
    @objc private func resumeVideo() {
        player?.play()
    }
}

#Preview {
    VideoPlayerViewController(letter: "J")
}
