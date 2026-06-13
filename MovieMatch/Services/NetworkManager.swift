// Services/NetworkManager.swift

import Foundation

public final class NetworkManager {
    public static let shared = NetworkManager()
    private init() {}

    /// Backend base URL. Override per-build via the `BackendBaseURL` key in
    /// Info.plist (e.g. a deployed server); falls back to localhost for the simulator.
    private let backendBaseURL: URL = {
        if let s = Bundle.main.object(forInfoDictionaryKey: "BackendBaseURL") as? String,
           !s.isEmpty, let u = URL(string: s) {
            return u
        }
        return URL(string: "http://127.0.0.1:3000")!
    }()

    /// Reads an Int? from UserDefaults.standard.integer(forKey: "userId")
    private var storedUserId: Int? {
        let val = UserDefaults.standard.object(forKey: "userId")
        return val as? Int
    }

    private let jsonDecoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    // ─── 1) Fetch the swipe‐deck of popular movies
    public func fetchMovies(completion: @escaping ([SwipeMovie]) -> Void) {
        let url = backendBaseURL.appendingPathComponent("movies")
        URLSession.shared.dataTask(with: url) { data, _, err in
            guard let data = data,
                  err == nil,
                  let list = try? JSONDecoder().decode([SwipeMovie].self, from: data)
            else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            DispatchQueue.main.async { completion(list) }
        }.resume()
    }

    // ─── 2) Send a swipe (requires a valid Int userId)
    public func sendSwipe(movieId: Int, direction: String, completion: @escaping (Bool) -> Void) {
        guard let uid = storedUserId else {
            print("❌ No userId found in UserDefaults") // should never happen once you log in
            completion(false)
            return
        }

        let url = backendBaseURL.appendingPathComponent("swipes")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "userId": uid,
            "movieId": movieId,
            "direction": direction
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: req) { _, resp, err in
            let ok = err == nil && (resp as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(ok) }
        }.resume()
    }

    // ─── 3) Fetch full movie detail by ID (unrelated to userId)
    public func fetchMovieDetail(movieId: Int, completion: @escaping (Movie?) -> Void) {
        let url = backendBaseURL.appendingPathComponent("movie/\(movieId)")
        var req = URLRequest(url: url)
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: req) { data, _, err in
            guard let data = data,
                  err == nil,
                  let m = try? self.jsonDecoder.decode(Movie.self, from: data)
            else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            DispatchQueue.main.async { completion(m) }
        }.resume()
    }

    // ─── 4) Generic “recommendations” fetcher (content / cf / hybrid)
    private func fetchRecs(endpoint: String, completion: @escaping ([Movie]) -> Void) {
        guard let uid = storedUserId else {
            print("❌ No userId found; returning empty recs")
            DispatchQueue.main.async { completion([]) }
            return
        }

        let url = backendBaseURL
            .appendingPathComponent("recommendations")
            .appendingPathComponent("\(endpoint)/\(uid)")

        var req = URLRequest(url: url)
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        print("🔍 Fetching recs from: \(url)")

        URLSession.shared.dataTask(with: req) { data, _, err in
            if let err = err {
                print("❌ Network error fetching recs: \(err)")
            }
            guard let data = data else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            do {
                let movies = try self.jsonDecoder.decode([Movie].self, from: data)
                DispatchQueue.main.async { completion(movies) }
            } catch {
                print("❌ Decoding error: \(error)")
                DispatchQueue.main.async { completion([]) }
            }
        }.resume()
    }

    // ─── 5) Content‐based recs
    public func fetchContentRecs(completion: @escaping ([Movie]) -> Void) {
        fetchRecs(endpoint: "content", completion: completion)
    }
    // ─── 6) Collaborative‐filtering recs
    public func fetchCfRecs(completion: @escaping ([Movie]) -> Void) {
        fetchRecs(endpoint: "cf", completion: completion)
    }
    // ─── 7) Hybrid recs
    public func fetchHybridRecs(completion: @escaping ([Movie]) -> Void) {
        fetchRecs(endpoint: "hybrid", completion: completion)
    }
    // ─── 8) Liked movies (watchlist / history)
    public func fetchLikedMovies(completion: @escaping ([Movie]) -> Void) {
        guard let uid = storedUserId else {
            DispatchQueue.main.async { completion([]) }
            return
        }
        let url = backendBaseURL
            .appendingPathComponent("users")
            .appendingPathComponent("\(uid)")
            .appendingPathComponent("likes")

        var req = URLRequest(url: url)
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: req) { data, _, _ in
            guard let data = data,
                  let movies = try? self.jsonDecoder.decode([Movie].self, from: data)
            else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            DispatchQueue.main.async { completion(movies) }
        }.resume()
    }
}
