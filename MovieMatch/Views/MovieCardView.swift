// Views/MovieCardView.swift

import SwiftUI

/// A simple, polished card for the swipe stack showing only title & poster.
struct MovieCardView: View {
    let title: String
    let posterURL: URL

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Poster image with loading & failure states
            AsyncImage(url: posterURL) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: Theme.Spacing.radiusLarge)
                        .fill(Theme.Colors.backgroundMedium)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        )
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    RoundedRectangle(cornerRadius: Theme.Spacing.radiusLarge)
                        .fill(Theme.Colors.backgroundMedium)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(Theme.Colors.textSecondary)
                        )
                @unknown default:
                    RoundedRectangle(cornerRadius: Theme.Spacing.radiusLarge)
                        .fill(Theme.Colors.backgroundMedium)
                }
            }
            .aspectRatio(2/3, contentMode: .fit)
            .cornerRadius(Theme.Spacing.radiusLarge)
            .clipped()

            // Gradient overlay for readability
            LinearGradient(
                gradient: Gradient(colors: [.clear, Color.black.opacity(0.8)]),
                startPoint: .center,
                endPoint: .bottom
            )
            .cornerRadius(Theme.Spacing.radiusLarge)

            // Title overlay
            Text(title)
                .font(Theme.Typography.bodyLarge)
                .foregroundColor(.white)
                .padding(Theme.Spacing.small)
        }
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

struct MovieCardView_Previews: PreviewProvider {
    static var previews: some View {
        MovieCardView(
            title: "Inception",
            posterURL: URL(string: "https://image.tmdb.org/t/p/w500/qmDpIHrmpJINaRKAfWQfftjCdyi.jpg")!
        )
        .preferredColorScheme(.dark)
        .padding()
        .background(Color.black)
    }
}
