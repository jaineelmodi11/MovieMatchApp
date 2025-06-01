import SwiftUI

struct MainSwipeView: View {
    @StateObject private var vm = MovieViewModel()
    @AppStorage("userId") private var userId: Int?

    @State private var offset       = CGSize.zero
    @State private var currentIndex = 0
    @State private var selectedMovie: Movie?
    @State private var isAnimating  = false
    @State private var swipeDirection: SwipeDirection?

    enum SwipeDirection { case like, dislike }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if vm.movies.isEmpty {
                loadingView
            } else {
                contentView
            }
        }
        .sheet(item: $selectedMovie) { movie in
            MovieDetailView(movie: movie)
        }
        .onAppear {
            vm.fetchMovies()
        }
        .onChange(of: vm.movies) { _ in
            // Now that SwipeMovie: Equatable, this compiles
            currentIndex = 0
            offset = .zero
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.2)
            Text("Discovering amazing movies…")
                .foregroundColor(.gray)
                .font(.subheadline)
        }
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            header
            Spacer()
            cardStack
            Spacer()
            actionButtons
                .padding(.bottom, 24)
        }
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text("MovieMatch")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .tracking(1)

            Text("Discover your next favorite movie")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding(.top, 24)
    }

    private var cardStack: some View {
        ZStack {
            ForEach(vm.movies.indices.reversed(), id: \.self) { idx in
                if idx >= currentIndex {
                    let movie = vm.movies[idx]
                    let isTop = (idx == currentIndex)

                    MovieCardView(
                        title: movie.title,
                        posterURL: movie.posterURL
                    )
                    .offset(isTop ? offset : .zero)
                    .scaleEffect(isTop ? 1.0 : 0.95)
                    .rotationEffect(.degrees(isTop ? Double(offset.width / 20) : 0))
                    .gesture(isTop ? dragGesture : nil)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentIndex)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { g in
                guard !isAnimating else { return }
                offset = g.translation
            }
            .onEnded { g in
                handleSwipe(translation: g.translation)
            }
    }

    private var actionButtons: some View {
        HStack(spacing: 32) {
            // Dislike
            Button {
                performSwipe(direction: .dislike)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .bold))
                    .frame(width: 64, height: 64)
                    .background(
                        LinearGradient(
                            colors: [Color.red.opacity(0.8), Color.red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
                    .foregroundColor(.white)
            }
            .scaleEffect(isAnimating && swipeDirection == .dislike ? 1.1 : 1.0)
            .disabled(isAnimating)

            // Info
            Button {
                fetchDetail()
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 22, weight: .medium))
                    .frame(width: 48, height: 48)
                    .background(Color(white: 0.12))
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }

            // Like
            Button {
                performSwipe(direction: .like)
            } label: {
                Image(systemName: "heart.fill")
                    .font(.system(size: 24, weight: .bold))
                    .frame(width: 64, height: 64)
                    .background(
                        LinearGradient(
                            colors: [Color.pink.opacity(0.8), Color.pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: .pink.opacity(0.3), radius: 10, x: 0, y: 5)
                    .foregroundColor(.white)
            }
            .scaleEffect(isAnimating && swipeDirection == .like ? 1.1 : 1.0)
            .disabled(isAnimating)
        }
    }

    private func handleSwipe(translation: CGSize) {
        let threshold: CGFloat = 100
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            if translation.width > threshold {
                performSwipe(direction: .like)
            } else if translation.width < -threshold {
                performSwipe(direction: .dislike)
            } else {
                offset = .zero
            }
        }
    }

    private func performSwipe(direction: SwipeDirection) {
        guard !isAnimating, currentIndex < vm.movies.count else { return }
        isAnimating    = true
        swipeDirection = direction

        let movie    = vm.movies[currentIndex]
        let swipeStr = (direction == .like ? "like" : "dislike")

        NetworkManager.shared.sendSwipe(
            movieId: movie.id,
            direction: swipeStr
        ) { _ in }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            offset = CGSize(width: direction == .like ? 500 : -500, height: 0)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentIndex   = min(currentIndex + 1, vm.movies.count - 1)
                offset         = .zero
                isAnimating    = false
                swipeDirection = nil
            }
        }
    }

    private func fetchDetail() {
        let movie = vm.movies[currentIndex]
        NetworkManager.shared.fetchMovieDetail(movieId: movie.id) { detail in
            if let detail = detail {
                selectedMovie = detail
            }
        }
    }
}

struct MainSwipeView_Previews: PreviewProvider {
    static var previews: some View {
        MainSwipeView()
            .preferredColorScheme(.dark)
    }
}
