import SwiftUI

struct ContentView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @StateObject private var vm = MovieViewModel()

    var body: some View {
        Group {
            if !isAuthenticated {
                LoginView()
            } else {
                TabView {
                    MainSwipeView()
                        .tabItem {
                            Image(systemName: "hand.point.right.fill")
                            Text("Swipe")
                        }
                    RecommendationsView()
                        .tabItem {
                            Image(systemName: "star.fill")
                            Text("Recs")
                        }
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                }
                .accentColor(Theme.Colors.primary)
                .background(Theme.Colors.backgroundDark.ignoresSafeArea())
            }
        }
    }
}
