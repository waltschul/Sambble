import AVFoundation

final class SilentAudioPlayer {
    static let shared = SilentAudioPlayer()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()

    func start() {
        let format = AVAudioFormat(
            standardFormatWithSampleRate: 44100,
            channels: 1
        )!

        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)

        try? engine.start()

        // Create 1 second of silence
        let frameCount = AVAudioFrameCount(format.sampleRate)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        // Fill buffer with zeros (silence)
        if let channelData = buffer.floatChannelData {
            memset(channelData[0], 0, Int(frameCount) * MemoryLayout<Float>.size)
        }

        player.scheduleBuffer(buffer, at: nil, options: .loops)
        player.play()
        
        print("🔇 Silent audio engine playing")
    }
}
