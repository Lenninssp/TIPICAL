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
    private let backendBaseURL = "https://lenninsabogal.online/tipical"

    private init() {}

    private var backendSession: URLSession {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = HTTPCookieStorage.shared
        config.httpShouldSetCookies = true
        config.httpCookieAcceptPolicy = .always
        return URLSession(configuration: config)
    }

    // MARK: - Sign up

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

                    DispatchQueue.main.async {
                        self.currentUser = appUser
                    }

                    completion(.success(appUser))
                }
            } catch {
                print("Firestore encoding error:", error.localizedDescription)
                completion(.failure(error))
            }
        }
    }

    // MARK: - Login

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

            // 1) Login to backend with Firebase ID token
            self.loginToBackendWithFirebaseToken { backendResult in
                switch backendResult {
                case .failure(let error):
                    print("Backend login failed:", error.localizedDescription)
                    completion(.failure(error))

                case .success:
                    // 2) Fetch AppUser from Firestore
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

    // MARK: - Backend login with Firebase token

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
            request.httpShouldHandleCookies = true
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: [
                "idToken": idToken
            ])

            self.backendSession.dataTask(with: request) { data, response, error in
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

                completion(.success(()))
            }.resume()
        }
    }

    // MARK: - Fetch current app user

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

    // MARK: - Update profile

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

    // MARK: - Backend logout

    private func logoutFromBackend(
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: "\(backendBaseURL)/auth/firebase/logout") else {
            return completion(.failure(SimpleError("Invalid backend logout URL")))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpShouldHandleCookies = true
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        backendSession.dataTask(with: request) { data, response, error in
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

    // MARK: - Optional backend /me debug helper

    func backendMe(
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let url = URL(string: "\(backendBaseURL)/me") else {
            return completion(.failure(SimpleError("Invalid backend /me URL")))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.httpShouldHandleCookies = true

        backendSession.dataTask(with: request) { data, response, error in
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

    // MARK: - Sign out

    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        logoutFromBackend { backendResult in
            switch backendResult {
            case .failure(let error):
                print("Backend logout error:", error.localizedDescription)
                completion(.failure(error))

            case .success:
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
}
