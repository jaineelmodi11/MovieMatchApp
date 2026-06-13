//
//  WatchlistView.swift
//  MovieMatch
//
//  Shows the movies the user has liked (swiped right), backed by stored swipes.
//

import SwiftUI

struct WatchlistView: View {
    @State private var liked: [Movie] = []
    @State private var isLoading = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isLoading {
                ProgressView("Loading your likes…")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
            } else if liked.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("No likes yet")
                        .font(.title3).bold()
                        .foregroundColor(.white)
                    Text("Swipe right on movies you love and they'll show up here.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Your Likes")
                                .font(.title2).bold()
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(liked.count)")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 16)

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(liked, id: \.id) { movie in
                                ZStack(alignment: .bottomLeading) {
                                    AsyncImage(url: movie.posterURL) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image.resizable().scaledToFill()
                                        default:
                                            Rectangle().fill(Color.gray.opacity(0.3))
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

                                    Text(movie.title)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                        .padding(8)
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 24)
                }
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        isLoading = true
        NetworkManager.shared.fetchLikedMovies { movies in
            self.liked = movies
            self.isLoading = false
        }
    }
}

struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView().preferredColorScheme(.dark)
    }
}
