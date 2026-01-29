struct NowPlaying {
    let album: String
    let title: String
    let artist: String

    static func presets() async -> [NowPlaying] {
        let samRating = await RatingScraper(player: "Sam Masling").fetchRating()
        let danRating = await RatingScraper(player: "Dan Wachtell").fetchRating()

        print("Debug: Sam's rating is \(samRating), Dan's rating is \(danRating)")

        return [
            NowPlaying(
                album: "Help!",
                title: "I'm trapped in an",
                artist: "alphagram factory"
            ),
            NowPlaying(
                album: "Sambble",
                title: "Sam Masling rating: \(samRating)",
                artist: "Dan Wachtell rating: \(danRating)"
            )
        ]
    }
}
