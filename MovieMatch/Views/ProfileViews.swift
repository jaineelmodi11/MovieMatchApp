import SwiftUI

struct ProfileView: View {
    // Persisted user info
    @AppStorage("userDisplayName") private var displayName: String = "Your Name"
    @AppStorage("userEmail")       private var email: String       = ""
    @AppStorage("isAuthenticated") private var isAuthenticated: Bool = false

    // Local toggles
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled      = true
    @State private var downloadQuality      = "High"
    @State private var language             = "English"

    var body: some View {
        ZStack {
            // Solid black behind everything
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                topHeader
                Spacer(minLength: 0)

                ScrollView {
                    VStack(spacing: Theme.Spacing.large) {
                        profileHeader
                        settingsSections
                        signOutButton
                    }
                    .padding(.horizontal, Theme.Spacing.screenEdge)
                    .padding(.vertical, Theme.Spacing.medium)
                }
            }
        }
        // Make the Tab Bar transparent / blurred
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.visible,            for: .tabBar)
    }

    // MARK: - Top Header
    private var topHeader: some View {
        HStack {
            Spacer()
            Text("Profile")
                .font(Theme.Typography.title3)
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.top, Theme.Spacing.large)
        .padding(.bottom, Theme.Spacing.medium)
    }

    // MARK: - Profile Info
    private var profileHeader: some View {
        VStack(spacing: Theme.Spacing.small) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.backgroundMedium)
                    .frame(width: 100, height: 100)
                Text(initials(for: displayName))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Theme.Colors.primary)
            }

            Text(displayName)
                .font(Theme.Typography.title2)
                .foregroundColor(.white)

            Text(email)
                .font(Theme.Typography.bodyLarge)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }

    // MARK: - Settings
    private var settingsSections: some View {
        VStack(spacing: Theme.Spacing.large) {
            SettingsSection(title: "Preferences") {
                ToggleSetting(icon: "bell.fill",
                              iconColor: Theme.Colors.primary,
                              title: "Notifications",
                              isOn: $notificationsEnabled)
                Divider().background(Theme.Colors.backgroundLight)
                ToggleSetting(icon: "moon.fill",
                              iconColor: Theme.Colors.secondary,
                              title: "Dark Mode",
                              isOn: $darkModeEnabled)
                Divider().background(Theme.Colors.backgroundLight)
                SelectSetting(icon: "arrow.down.circle.fill",
                              iconColor: Theme.Colors.accentSuccess,
                              title: "Download Quality",
                              value: downloadQuality)
                Divider().background(Theme.Colors.backgroundLight)
                SelectSetting(icon: "globe",
                              iconColor: Theme.Colors.accentWarning,
                              title: "Language",
                              value: language)
            }

            SettingsSection(title: "Account") {
                NavigationSetting(icon: "lock.fill",
                                  iconColor: Theme.Colors.primary,
                                  title: "Change Password")
                Divider().background(Theme.Colors.backgroundLight)
                NavigationSetting(icon: "hand.raised.fill",
                                  iconColor: Theme.Colors.secondary,
                                  title: "Privacy Settings")
                Divider().background(Theme.Colors.backgroundLight)
                NavigationSetting(icon: "questionmark.circle.fill",
                                  iconColor: Theme.Colors.accentSuccess,
                                  title: "Help & Support")
            }
        }
    }

    // MARK: - Sign Out
    private var signOutButton: some View {
        Button(action: {
            isAuthenticated = false
        }) {
            Text("Sign Out")
                .font(Theme.Typography.button)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.medium)
                .background(Theme.Colors.accentError)
                .cornerRadius(Theme.Spacing.radiusMedium)
        }
    }

    // Helper to extract initials
    private func initials(for name: String) -> String {
        name.split(separator: " ")
            .compactMap { $0.first }
            .prefix(2)
            .map(String.init)
            .joined()
    }
}

// MARK: - SettingsSection
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title   = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text(title)
                .font(Theme.Typography.caption.bold())
                .foregroundColor(Theme.Colors.textSecondary)
                .padding(.leading, Theme.Spacing.small)

            VStack(spacing: Theme.Spacing.medium) {
                content
            }
            .padding(Theme.Spacing.medium)
            .background(Theme.Colors.backgroundMedium)
            .cornerRadius(Theme.Spacing.radiusMedium)
        }
    }
}

// MARK: - ToggleSetting
struct ToggleSetting: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: Theme.IconSize.medium))
                .foregroundColor(iconColor)
                .frame(width: Theme.IconSize.large, height: Theme.IconSize.large)

            Text(title)
                .font(Theme.Typography.bodyLarge)
                .foregroundColor(.white)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Theme.Colors.primary))
        }
    }
}

// MARK: - SelectSetting
struct SelectSetting: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: Theme.IconSize.medium))
                .foregroundColor(iconColor)
                .frame(width: Theme.IconSize.large, height: Theme.IconSize.large)

            Text(title)
                .font(Theme.Typography.bodyLarge)
                .foregroundColor(.white)

            Spacer()

            HStack(spacing: Theme.Spacing.xSmall) {
                Text(value)
                    .font(Theme.Typography.bodyMedium)
                    .foregroundColor(Theme.Colors.textSecondary)
                Image(systemName: "chevron.right")
                    .font(.system(size: Theme.IconSize.small))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
    }
}

// MARK: - NavigationSetting
struct NavigationSetting: View {
    let icon: String
    let iconColor: Color
    let title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: Theme.IconSize.medium))
                .foregroundColor(iconColor)
                .frame(width: Theme.IconSize.large, height: Theme.IconSize.large)

            Text(title)
                .font(Theme.Typography.bodyLarge)
                .foregroundColor(.white)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: Theme.IconSize.small))
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .preferredColorScheme(.dark)
    }
}
