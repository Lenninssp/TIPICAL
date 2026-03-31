//
//  AuthService.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-02-10.
//
import Foundation
import FirebaseAuth
import Combine
import FirebaseFirestore

final class AuthService: ObservableObject {
static let shared = AuthService()

@Published var currentUser: AppUser?

private let db = Firestore.firestore()
private let backendBaseURL = APIConfiguration.baseURL
private let tokenStore = TokenStore.shared

private init() {}

var isFullyAuthenticated: Bool {
    Auth.auth().currentUser != nil && tokenStore.loadToken() != nil
}

func signUp(
    email: String,
    password: String,
    displayName: String,
    completion: @escaping (Result<AppUser, Error>) -> Void
) {
    Auth.auth().createUser(withEmail: email, password: password) { result, error in
        if let error = error {
            print("Firebase sign up error:", error.localizedDescription)
            return completion(.failure(error))
        }

        guard let user = result?.user else {
            return completion(.failure(SimpleError("Unable to create user")))
        }

        let uid = user.uid
        let appUser = AppUser(id: uid, email: email, displayName: displayName)

        do {
            try self.db.collection("users").document(uid).setData(from: appUser) { error in
                if let error = error {
                    print("Firestore sign up save error:", error.localizedDescription)
                    return completion(.failure(error))
                }

                self.loginToBackendWithFirebaseToken { backendResult in
                    switch backendResult {
                    case .failure(let error):
                        print("Backend login after sign up failed:", error.localizedDescription)
                        completion(.failure(error))

                    case .success:
                        DispatchQueue.main.async {
                            self.currentUser = appUser
                        }
                        completion(.success(appUser))
                    }
                }
            }
        } catch {
            print("Firestore encoding error:", error.localizedDescription)
            completion(.failure(error))
        }
    }
}

func login(
    email: String,
    password: String,
    completion: @escaping (Result<AppUser?, Error>) -> Void
) {
    Auth.auth().signIn(withEmail: email, password: password) { result, error in
        if let error = error {
            print("Firebase sign in error:", error.localizedDescription)
            return completion(.failure(error))
        }

        guard let firebaseUser = result?.user else {
            return completion(.failure(SimpleError("Missing Firebase user after login")))
        }

        let uid = firebaseUser.uid

        self.loginToBackendWithFirebaseToken { backendResult in
            switch backendResult {
            case .failure(let error):
                print("Backend login failed:", error.localizedDescription)
                completion(.failure(error))

            case .success:
                self.fetchCurrentAppUser { fetchResult in
                    switch fetchResult {
                    case .success(let existingUser):
                        if let existingUser = existingUser {
                            completion(.success(existingUser))
                        } else {
                            let fallbackUser = AppUser(
                                id: uid,
                                email: firebaseUser.email ?? email,
                                displayName: firebaseUser.displayName ?? "Anonymous"
                            )

                            do {
                                try self.db.collection("users").document(uid).setData(from: fallbackUser) { error in
                                    if let error = error {
                                        print("Firestore fallback user save error:", error.localizedDescription)
                                        return completion(.failure(error))
                                    }

                                    DispatchQueue.main.async {
                                        self.currentUser = fallbackUser
                                    }

                                    completion(.success(fallbackUser))
                                }
                            } catch {
                                print("Firestore fallback encoding error:", error.localizedDescription)
                                completion(.failure(error))
                            }
                        }

                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}

private struct BackendLoginResponse: Decodable {
    let ok: Bool
    let userId: String
    let token: String
    let tokenType: String
    let expiresAt: String?
}

private func loginToBackendWithFirebaseToken(
    completion: @escaping (Result<Void, Error>) -> Void
) {
    guard let user = Auth.auth().currentUser else {
        return completion(.failure(SimpleError("No Firebase user is currently signed in")))
    }

    user.getIDToken { idToken, error in
        if let error = error {
            print("Get ID token error:", error.localizedDescription)
            return completion(.failure(error))
        }

        guard let idToken = idToken else {
            return completion(.failure(SimpleError("Failed to get Firebase ID token")))
        }

        guard let url = URL(string: "\(self.backendBaseURL)/auth/firebase/login") else {
            return completion(.failure(SimpleError("Invalid backend login URL")))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "idToken": idToken
        ])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(SimpleError("Invalid backend response")))
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let bodyString = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No body"
                return completion(.failure(SimpleError("Backend login failed (\(httpResponse.statusCode)): \(bodyString)")))
            }

            guard let data = data else {
                return completion(.failure(SimpleError("Backend login returned no body")))
            }

            do {
                let payload = try JSONDecoder().decode(BackendLoginResponse.self, from: data)
                try self.tokenStore.save(token: payload.token)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

func fetchCurrentAppUser(
    completion: @escaping (Result<AppUser?, Error>) -> Void
) {
    guard let uid = Auth.auth().currentUser?.uid else {
        DispatchQueue.main.async {
            self.currentUser = nil
        }
        return completion(.success(nil))
    }

    db.collection("users").document(uid).getDocument { snapshot, error in
        if let error = error {
            return completion(.failure(error))
        }

        guard let snapshot = snapshot else {
            return completion(.success(nil))
        }

        do {
            let user = try snapshot.data(as: AppUser.self)

            DispatchQueue.main.async {
                self.currentUser = user
            }

            completion(.success(user))
        } catch {
            print("Firestore decode error:", error.localizedDescription)
            completion(.failure(error))
        }
    }
}

func updateProfile(
    displayName: String,
    completion: @escaping (Result<Void, Error>) -> Void
) {
    guard let uid = Auth.auth().currentUser?.uid else {
        return completion(.success(()))
    }

    db.collection("users").document(uid).updateData([
        "displayName": displayName
    ]) { error in
        if let error = error {
            return completion(.failure(error))
        }

        self.fetchCurrentAppUser { _ in
            completion(.success(()))
        }
    }
}

private func logoutFromBackend(
    completion: @escaping (Result<Void, Error>) -> Void
) {
    guard let token = tokenStore.loadToken() else {
        return completion(.success(()))
    }

    guard let url = URL(string: "\(backendBaseURL)/auth/firebase/logout") else {
        return completion(.failure(SimpleError("Invalid backend logout URL")))
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            return completion(.failure(error))
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            return completion(.failure(SimpleError("Invalid backend response")))
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let bodyString = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No body"
            return completion(.failure(SimpleError("Backend logout failed (\(httpResponse.statusCode)): \(bodyString)")))
        }

        completion(.success(()))
    }.resume()
}

func backendMe(
    completion: @escaping (Result<String, Error>) -> Void
) {
    guard let token = tokenStore.loadToken() else {
        return completion(.failure(SimpleError("No auth token available")))
    }

    guard let url = URL(string: "\(backendBaseURL)/me") else {
        return completion(.failure(SimpleError("Invalid backend /me URL")))
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            return completion(.failure(error))
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            return completion(.failure(SimpleError("Invalid backend response")))
        }

        let bodyString = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""

        guard (200...299).contains(httpResponse.statusCode) else {
            return completion(.failure(SimpleError("Backend /me failed (\(httpResponse.statusCode)): \(bodyString)")))
        }

        completion(.success(bodyString))
    }.resume()
}

func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
    logoutFromBackend { backendResult in
        if case .failure(let error) = backendResult {
            print("Backend logout warning:", error.localizedDescription)
        }

        self.tokenStore.deleteToken()

        do {
            try Auth.auth().signOut()

            DispatchQueue.main.async {
                self.currentUser = nil
            }

            completion(.success(()))
        } catch {
            print("Firebase sign out error:", error.localizedDescription)
            completion(.failure(error))
        }
    }
}
}
