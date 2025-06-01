// Views/MovieDetailView.swift

import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.Colors.backgroundDark
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                    // Poster + Back Button
                    ZStack(alignment: .topLeading) {
                        AsyncImage(url: movie.posterURL) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Theme.Colors.backgroundMedium)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                Rectangle()
                                    .fill(Theme.Colors.textSecondary)
                            @unknown default:
                                Rectangle()
                                    .fill(Theme.Colors.textSecondary)
                            }
                        }
                        .aspectRatio(2/3, contentMode: .fit)
                        .cornerRadius(Theme.Spacing.radiusLarge)
                        .shadow(radius: 10)

                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: Theme.IconSize.medium, weight: .bold))
                                .foregroundColor(.white)
                                .padding(Theme.Spacing.small)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding(Theme.Spacing.small)
                    }

                    // Title & Tagline
                    VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                        Text(movie.title)
                            .font(Theme.Typography.title1)
                            .foregroundColor(Theme.Colors.textPrimary)

                        if let tagline = movie.tagline, !tagline.isEmpty {
                            Text("“\(tagline)”")
                                .font(Theme.Typography.bodyLarge.italic())
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                    }

                    // Year • Rating • Runtime
                    HStack(spacing: Theme.Spacing.medium) {
                        if let date = movie.releaseDate, date.count >= 4 {
                            Text(String(date.prefix(4)))
                        }
                        HStack(spacing: Theme.Spacing.xSmall) {
                            Image(systemName: "star.fill")
                            Text(String(format: "%.1f", movie.voteAverage ?? 0))
                        }
                        if let runtime = movie.runtime {
                            HStack(spacing: Theme.Spacing.xSmall) {
                                Image(systemName: "clock")
                                Text("\(runtime) min")
                            }
                        }
                    }
                    .font(Theme.Typography.bodyMedium)
                    .foregroundColor(Theme.Colors.textSecondary)

                    // Genres
                    if let genres = movie.genres, !genres.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Theme.Spacing.small) {
                                ForEach(genres) { genre in
                                    Text(genre.name)
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                        .padding(.horizontal, Theme.Spacing.small)
                                        .padding(.vertical, Theme.Spacing.xSmall)
                                        .background(Theme.Colors.backgroundMedium)
                                        .cornerRadius(Theme.Spacing.radiusSmall)
                                }
                            }
                        }
                    }

                    // Overview
                    Text(movie.overview ?? "No overview available.")
                        .font(Theme.Typography.bodyLarge)
                        .foregroundColor(Theme.Colors.textPrimary)
                }
                .padding(Theme.Spacing.screenEdge)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailView(movie:
            Movie(
                id: 603,
                title: "The Matrix",
                overview: "Set in the 22nd century...",
                tagline: "Believe the unbelievable.",
                releaseDate: "1999-03-31",
                voteAverage: 8.2,
                runtime: 136,
                budget: 63_000_000,
                revenue: 463_517_383,
                posterPath: "/dXNAPwY7VrqMAo51EKhhCJfaGb5.jpg",
                genres: [
                    Genre(id: 28, name: "Action"),
                    Genre(id: 878, name: "Sci-Fi")
                ]
            )
        )
        .preferredColorScheme(.dark)
    }
}
