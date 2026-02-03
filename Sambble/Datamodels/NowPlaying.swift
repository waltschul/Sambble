import UIKit

struct NowPlaying {
    let album: String
    let title: String
    let artist: String
    let artworkImage: UIImage?

    static func presets() async -> [NowPlaying] {
        let samRating = await RatingScraper(player: "Sam Masling").fetchRating()
        let danRating = await RatingScraper(player: "Dan Wachtell").fetchRating()

        return [
            NowPlaying(
                album: "Help!",
                title: "I'm trapped in an",
                artist: "alphagram factory",
                artworkImage: UIImage(named: "Sam1")
            ),
            NowPlaying(
                album: "Sambble",
                title: "Sam Masling rating: \(samRating)",
                artist: "Dan Wachtell rating: \(danRating)",
                artworkImage: UIImage(named: "Sam2")
            ),
        ]
    }
}
