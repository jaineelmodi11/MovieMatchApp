import SwiftUI

struct RecommendationsView: View {
    @AppStorage("userId") private var storedUserId: Int?

    /// The complete list (up to 50) of unique recommendations
    @State private var fullRecs: [Movie] = []

    /// The subset currently shown to the user
    @State private var shownRecs: [Movie] = []

    @State private var isLoadingFull = false    // True while gathering up to 50
    @State private var isLoadingMore = false    // True while appending next page

    // Pagination constants
    private let initialCount = 11
    private let pageSize = 6
    private let targetCount = 50

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isLoadingFull {
                // Spinner while fetching content, CF, hybrid, then fallback popular
                ProgressView("Loading recommendations…")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
                    .font(.headline)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // ─── Badge ─────────────────────────────────────
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.white)
                            Text("Smart Recommendations")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)

                        // ─── Header ───────────────────────────────────
                        VStack(spacing: 4) {
                            Text("Recommended for You")
                                .font(.title2).bold()
                                .foregroundColor(.white)
                            Text("Based on your likes")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }

                        // ─── Hero Card ─────────────────────────────────
                        if let first = shownRecs.first {
                            AsyncImage(url: first.posterURL) { phase in
                                switch phase {
                                case .empty:
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                case .failure:
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.5))
                                @unknown default:
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.5))
                                }
                            }
                            .frame(height: 240)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(16)
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                                .cornerRadius(16)
                            )
                            .overlay(
                                VStack(alignment: .leading, spacing: 4) {
                                    if let genreName = first.genres?.first?.name {
                                        Text(genreName.uppercased())
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.8))
                                            .cornerRadius(4)
                                    }
                                    Text(first.title)
                                        .font(.title3).bold()
                                        .foregroundColor(.white)
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                        Text(String(format: "%.1f", first.voteAverage ?? 0))
                                            .foregroundColor(.white)
                                            .font(.caption)
                                    }
                                }
                                .padding(12),
                                alignment: .bottomLeading
                            )
                        }

                        // ─── Grid of Remaining ────────────────────────
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(Array(shownRecs.dropFirst()), id: \.id) { movie in
                                ZStack(alignment: .bottomLeading) {
                                    AsyncImage(url: movie.posterURL) { phase in
                                        switch phase {
                                        case .empty:
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        case .failure:
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.5))
                                        @unknown default:
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.5))
                                        }
                                    }
                                    .frame(height: 180)
                                    .clipped()
                                    .cornerRadius(12)
                                    .overlay(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                                            startPoint: .center,
                                            endPoint: .bottom
                                        )
                                        .cornerRadius(12)
                                    )

                                    VStack(alignment: .leading, spacing: 2) {
                                        if let firstGenre = movie.genres?.first?.name {
                                            Text(firstGenre.uppercased())
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 2)
                                                .background(Color.blue.opacity(0.8))
                                                .cornerRadius(4)
                                        }
                                        Text(movie.title)
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .lineLimit(2)
                                        HStack(spacing: 2) {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                                .font(.caption2)
                                            Text(String(format: "%.1f", movie.voteAverage ?? 0))
                                                .foregroundColor(.white)
                                                .font(.caption2)
                                        }
                                    }
                                    .padding(8)
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        // ─── Load More Button ───────────────────────────
                        if !isLoadingMore && shownRecs.count < fullRecs.count {
                            Button(action: loadMore) {
                                Text("Load More")
                                    .font(.body).bold()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .padding(.horizontal, 32)
                            }
                        } else if isLoadingMore {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.0)
                                .padding(.vertical, 16)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear(perform: loadAllRecs)
        // ───────────────────────────────────────────────────────────────────
        // Make the Tab Bar transparent / blurred
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.visible,            for: .tabBar)
    }

    // ─── Step 1: Fetch content, CF, hybrid, then fallback to /movies until we have 50 ────────────────────
    private func loadAllRecs() {
        guard let uid = storedUserId else { return }
        isLoadingFull = true
        fullRecs = []
        shownRecs = []

        let group = DispatchGroup()

        var contentArr: [Movie] = []
        var cfArr: [Movie] = []
        var hybridArr: [Movie] = []

        group.enter()
        NetworkManager.shared.fetchContentRecs { movies in
            contentArr = movies
            group.leave()
        }

        group.enter()
        NetworkManager.shared.fetchCfRecs { movies in
            cfArr = movies
            group.leave()
        }

        group.enter()
        NetworkManager.shared.fetchHybridRecs { movies in
            hybridArr = movies
            group.leave()
        }

        group.notify(queue: .main) {
            // 1) Merge and dedupe the three arrays
            var combined: [Movie] = []
            for list in [contentArr, cfArr, hybridArr] {
                for m in list {
                    if !combined.contains(where: { $0.id == m.id }) {
                        combined.append(m)
                    }
                }
            }

            // 2) If less than targetCount, fetch /movies to fill to 50
            if combined.count < targetCount {
                NetworkManager.shared.fetchMovies { swipeList in
                    // Convert SwipeMovie → Movie by setting posterPath from posterURL
                    let extraMovies: [Movie] = swipeList.compactMap { swipe in
                        // Extract lastPathComponent from posterURL, prepend "/"
                        let lastComp = swipe.posterURL.lastPathComponent
                        let posterPath = "/" + lastComp
                        return Movie(
                            id:          swipe.id,
                            title:       swipe.title,
                            overview:    nil,
                            tagline:     nil,
                            releaseDate: nil,
                            voteAverage: nil,
                            runtime:     nil,
                            budget:      nil,
                            revenue:     nil,
                            posterPath:  posterPath,
                            genres:      nil
                        )
                    }
                    // Append extras until we have at least targetCount
                    for m in extraMovies {
                        if combined.count >= targetCount { break }
                        if !combined.contains(where: { $0.id == m.id }) {
                            combined.append(m)
                        }
                    }
                    finalizeFullRecs(combined)
                }
            } else {
                finalizeFullRecs(combined)
            }
        }
    }

    // Helper to set fullRecs + shownRecs
    private func finalizeFullRecs(_ combined: [Movie]) {
        DispatchQueue.main.async {
            fullRecs = combined
            let initial = min(initialCount, fullRecs.count)
            shownRecs = Array(fullRecs.prefix(initial))
            isLoadingFull = false
        }
    }

    // ─── Step 2: Append next `pageSize` items when “Load More” tapped ───
    private func loadMore() {
        guard !isLoadingMore else { return }
        isLoadingMore = true

        DispatchQueue.main.async {
            let currentCount = shownRecs.count
            let remaining = fullRecs.count - currentCount
            let nextCount = min(pageSize, remaining)

            if nextCount > 0 {
                let nextSlice = fullRecs[currentCount..<currentCount + nextCount]
                shownRecs.append(contentsOf: nextSlice)
            }
            isLoadingMore = false
        }
    }
}

struct RecommendationsView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendationsView()
            .preferredColorScheme(.dark)
    }
}
