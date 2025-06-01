// Models/Movie.swift

import Foundation

public struct Movie: Identifiable, Decodable {
    public let id: Int
    public let title: String
    public let overview: String?
    public let tagline: String?
    public let releaseDate: String?
    public let voteAverage: Double?
    public let runtime: Int?
    public let budget: Int?
    public let revenue: Int?
    public let posterPath: String?
    public let genres: [Genre]?

    // Build a full URL from TMDB’s partial path
    public var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
}
