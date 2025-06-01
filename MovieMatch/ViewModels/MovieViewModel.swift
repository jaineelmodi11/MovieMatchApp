import Foundation

final class MovieViewModel: ObservableObject {
    @Published var movies: [SwipeMovie] = []

    init() {
        fetchMovies()
    }

    func fetchMovies() {
        NetworkManager.shared.fetchMovies { list in
            DispatchQueue.main.async {
                self.movies = list
            }
        }
    }
}
