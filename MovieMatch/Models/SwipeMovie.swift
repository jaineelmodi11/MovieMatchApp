import Foundation

public struct SwipeMovie: Identifiable, Codable, Equatable {
    public let id: Int
    public let title: String
    public let posterURL: URL
}
