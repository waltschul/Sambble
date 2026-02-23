import AVFoundation
import MediaPlayer
import UIKit

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

    func stop() {
        let commandCenter = MPRemoteCommandCenter.shared()
        if let handler = nextHandler {
            commandCenter.nextTrackCommand.removeTarget(handler)
            self.nextHandler = nil
        }
        if let handler = previousHandler {
            commandCenter.previousTrackCommand.removeTarget(handler)
            self.previousHandler = nil
        }
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        print("MediaCommandManager stopped")
    }

    func initializeNowPlaying() {
        Task {
            nowPlaying = await NowPlaying.presets().randomElement()!
            updateNowPlaying()
        }
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            print("Setting audio session")
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            
            print("Audio session active:", session.isOtherAudioPlaying)
            print("Category:", session.category.rawValue)
            print("Mode:", session.mode.rawValue)
            
            
            
        } catch {
            print("Audio session error:", error)
        }
    }

    private var nextHandler: Any?
    private var previousHandler: Any?

    private func configureRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        // Remove old handlers if they exist
        if let nextHandler = nextHandler {
            commandCenter.nextTrackCommand.removeTarget(nextHandler)
        }
        if let previousHandler = previousHandler {
            commandCenter.previousTrackCommand.removeTarget(previousHandler)
        }

        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true

        nextHandler = commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            print("NEXT TRACK RECEIVED")
            self?.onNext?()
            return .success
        }

        previousHandler = commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            print("PREVIOUS TRACK RECEIVED")
            self?.onPrevious?()
            return .success
        }
    }

    func updateNowPlaying() {
        guard let nowPlaying = nowPlaying else {
            print("⚠️ updateNowPlaying called but nowPlaying is nil")
            return
        }
        
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: nowPlaying.title,
            MPMediaItemPropertyAlbumTitle: nowPlaying.album,
            MPMediaItemPropertyArtist: nowPlaying.artist,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0
        ]
        
        // Add artwork if available
        if let artworkImage = nowPlaying.artworkImage {
            let artwork = MPMediaItemArtwork(boundsSize: artworkImage.size) { _ in
                artworkImage
            }
            info[MPMediaItemPropertyArtwork] = artwork
        }

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
