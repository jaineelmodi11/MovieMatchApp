// Views/RegisterView.swift

import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("userId")          private var userId: Int?

    @State private var name      = ""
    @State private var email     = ""
    @State private var password  = ""
    @State private var isLoading = false
    @State private var authError: String?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Create Account")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.top, 40)

                VStack(spacing: 12) {
                    TextField("Full Name", text: $name)
                        .padding()
                        .background(Color(white: 0.12))
                        .cornerRadius(8)

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

                Button(action: register) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue)
                            .frame(height: 50)

                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.2)
                        } else {
                            Text("Sign Up")
                                .foregroundColor(.white)
                                .bold()
                        }
                    }
                }
                .disabled(isLoading || email.isEmpty || password.count < 6 || name.isEmpty)
                .opacity((isLoading || email.isEmpty || password.count < 6 || name.isEmpty) ? 0.5 : 1)
                .alert("Error", isPresented: Binding(
                    get: { authError != nil },
                    set: { if !$0 { authError = nil } }
                )) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(authError ?? "Unknown error")
                }
                .padding(.top, 12)

                Spacer()
            }
        }
        .navigationBarTitle("", displayMode: .inline)
    }

    private func register() {
        guard password.count >= 6, !name.isEmpty else {
            authError = "Please fill in all fields and use a 6+ character password."
            return
        }
        isLoading = true
        authError = nil

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    authError = error.localizedDescription
                    return
                }
                guard let firebaseUser = result?.user else {
                    authError = "Registration error"
                    return
                }

                // ─── STEP 1: Set the display name in Firebase, then map to Int ───
                let changeReq = firebaseUser.createProfileChangeRequest()
                changeReq.displayName = name
                changeReq.commitChanges { _ in
                    let url = URL(string: "http://localhost:3000/users/importOrGetId")!
                    var req = URLRequest(url: url)
                    req.httpMethod = "POST"
                    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    let body: [String: String] = [
                        "firebaseUid": firebaseUser.uid,
                        "displayName": name
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
                                let newId = decoded["userId"]
                            else {
                                authError = "Failed to get userId"
                                return
                            }

                            // ─── STEP 2: Save that integer and switch to main app ────────
                            userId = newId
                            isAuthenticated = true
                        }
                    }
                    .resume()
                }
            }
        }
    }
}
