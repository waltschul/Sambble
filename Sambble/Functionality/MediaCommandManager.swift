import AVFoundation
import MediaPlayer

final class MediaCommandManager: ObservableObject {
    static let shared = MediaCommandManager()

    private init() {
    }

    private var nowPlaying: NowPlaying!
    
    // Callbacks your app provides
    var onNext: (() -> Void)?
    var onPrevious: (() -> Void)?

    func start() {
        initializeNowPlaying()
        configureAudioSession()
        configureRemoteCommands()
        observeAudioInterruptions()
        print("MediaCommandManager started")
    }

    func initializeNowPlaying() {
        Task {
            nowPlaying = await NowPlaying.presets().randomElement()!
        }
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            print("Setting audio session")
            try session.setCategory(
                            .playback,
                            mode: .spokenAudio,
                            options: [.mixWithOthers, .duckOthers]
                        )
            try session.setActive(true)
            print("Audio session category:", session.category.rawValue)
            print("Audio session mode:", session.mode.rawValue)
        } catch {
            print("Audio session error:", error)
        }
    }

    private func configureRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            print("NEXT TRACK RECEIVED")
            self?.onNext?()
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            print("NEXT TRACK RECEIVED")
            self?.onPrevious?()
            return .success
        }
    }

    func updateNowPlaying() {
        guard let nowPlaying = nowPlaying else { return }
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: nowPlaying.title,
            MPMediaItemPropertyAlbumTitle: nowPlaying.album,
            MPMediaItemPropertyArtist: nowPlaying.artist,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0
        ]

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private func observeAudioInterruptions() {
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard
                let info = notification.userInfo,
                let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
                let type = AVAudioSession.InterruptionType(rawValue: typeValue)
            else { return }

            switch type {
            case .began:
                print("⛔️ Audio interruption began")

            case .ended:
                print("✅ Audio interruption ended")

                // Re-activate session
                let session = AVAudioSession.sharedInstance()
                try? session.setActive(true)

                // Restart silent audio so we regain media controls
                SilentAudioPlayer.shared.start()

                // Re-assert Now Playing ownership
                self.updateNowPlaying()
            }
        }
    }
}
