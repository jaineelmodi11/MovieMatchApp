// Views/LoginView.swift

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("userId")          private var userId: Int?    // now an Int

    @State private var email     = ""
    @State private var password  = ""
    @State private var isLoading = false
    @State private var authError: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("Welcome Back")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.top, 40)

                    VStack(spacing: 12) {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(white: 0.12))
                            .cornerRadius(8)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(white: 0.12))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 24)

                    Button(action: login) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                                .frame(height: 50)

                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.2)
                            } else {
                                Text("Log In")
                                    .foregroundColor(.white)
                                    .bold()
                            }
                        }
                    }
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    .opacity((isLoading || email.isEmpty || password.isEmpty) ? 0.5 : 1)
                    .alert("Error", isPresented: Binding(
                        get: { authError != nil },
                        set: { if !$0 { authError = nil } }
                    )) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text(authError ?? "Unknown error")
                    }
                    .padding(.top, 12)

                    Spacer()

                    NavigationLink("Don't have an account? Register", destination: RegisterView())
                        .foregroundColor(.white)
                        .padding(.bottom, 24)
                }
                .padding(.top, 80)
            }
            .navigationBarHidden(true)
        }
    }

    private func login() {
        isLoading = true
        authError = nil

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    authError = error.localizedDescription
                    return
                }
                guard let firebaseUser = result?.user else {
                    authError = "Unexpected Firebase error."
                    return
                }

                // ─── STEP 1: Hit our Node endpoint to map Firebase UID → Int userId ───
                let url = URL(string: "http://localhost:3000/users/importOrGetId")!
                var req = URLRequest(url: url)
                req.httpMethod = "POST"
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let body: [String: String] = [
                    "firebaseUid": firebaseUser.uid,
                    "displayName": firebaseUser.displayName ?? ""
                ]
                req.httpBody = try? JSONEncoder().encode(body)

                URLSession.shared.dataTask(with: req) { data, response, err in
                    DispatchQueue.main.async {
                        if let err = err {
                            authError = "Server error: \(err.localizedDescription)"
                            return
                        }
                        guard
                            let data = data,
                            let decoded = try? JSONDecoder().decode([String: Int].self, from: data),
                            let fetchedId = decoded["userId"]
                        else {
                            authError = "Failed to parse userId from server."
                            return
                        }

                        // ─── STEP 2: Save that Int and switch to the main app ──────────────
                        userId = fetchedId
                        isAuthenticated = true
                    }
                }
                .resume()
            }
        }
    }
}
