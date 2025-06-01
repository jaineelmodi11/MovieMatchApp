import SwiftUI
import FirebaseCore   // ← make sure you’ve added FirebaseCore in your Podfile

@main
struct MovieMatchApp: App {
    // Track whether the user has signed in
    @AppStorage("isAuthenticated") private var isAuthenticated = false

    // Initialize Firebase as soon as the app launches
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                MainTabView()   // Shows Swipe / Recs / Profile tabs
                    .preferredColorScheme(.dark)
            } else {
                LoginView()     // Shows Login / Register screens
                    .preferredColorScheme(.dark)
            }
        }
    }
}
