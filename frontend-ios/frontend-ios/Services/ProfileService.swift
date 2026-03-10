//
//  ProfileService.swift
//  frontend-ios
//
//  Created by Lennin Sabogal on 10/03/26.
//

import Foundation


import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private init() {}

    private let backendBaseURL = APIConfiguration.baseURL
    private let tokenStore = TokenStore.shared

    private func logRequest(_ request: URLRequest, name: String) {
        print("========== \(name) REQUEST ==========")
        print("URL:", request.url?.absoluteString ?? "nil")
        print("Method:", request.httpMethod ?? "nil")
        print("Headers:", request.allHTTPHeaderFields ?? [:])

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("Body:", bodyString)
        } else {
            print("Body: nil")
        }

        print("====================================")
    }

    private func logResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        name: String
    ) {
        print("========== \(name) RESPONSE ==========")

        if let error = error {
            print("Error:", error.localizedDescription)
        } else {
            print("Error: nil")
        }

        if let http = response as? HTTPURLResponse {
            print("Status Code:", http.statusCode)
            print("Headers:", http.allHeaderFields)
        } else {
            print("Response: not HTTPURLResponse")
        }

        if let data = data,
           let bodyString = String(data: data, encoding: .utf8) {
            print("Raw Body:", bodyString)
        } else {
            print("Raw Body: nil")
        }

        print("=====================================")
    }

    private func authorizedRequest(
        url: URL,
        method: String,
        body: Data? = nil,
        contentType: String? = nil
    ) -> Result<URLRequest, Error> {
        guard let token = tokenStore.loadToken() else {
            return .failure(SimpleError("Missing auth token, login is required"))
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        if let contentType = contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        request.httpBody = body
        return .success(request)
    }

    func fetchProfile(
        userId: String,
        completion: @escaping (Result<ProfileResponseItem, Error>) -> Void
    ) {
        guard let url = URL(string: "\(backendBaseURL)/profiles/\(userId)") else {
            print("[ProfileService.fetchProfile] Invalid profile URL")
            return completion(.failure(SimpleError("Invalid profile URL")))
        }

        let request: URLRequest
        switch authorizedRequest(url: url, method: "GET") {
        case .failure(let error):
            return completion(.failure(error))
        case .success(let built):
            request = built
        }

        logRequest(request, name: "FETCH PROFILE")

        URLSession.shared.dataTask(with: request) { data, response, error in
            self.logResponse(data: data, response: response, error: error, name: "FETCH PROFILE")

            if let error = error {
                return completion(.failure(error))
            }

            guard let http = response as? HTTPURLResponse else {
                return completion(.failure(SimpleError("Invalid response")))
            }

            guard (200...299).contains(http.statusCode) else {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No body"
                return completion(.failure(SimpleError("Fetch profile failed (\(http.statusCode)): \(body)")))
            }

            guard let data = data else {
                return completion(.failure(SimpleError("Missing response data")))
            }

            do {
                let decoded = try JSONDecoder().decode(APIResource<ProfileResponseItem>.self, from: data)
                completion(.success(decoded.data))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchProfiles(
        userIds: [String],
        completion: @escaping (Result<[String: ProfileSummary], Error>) -> Void
    ) {
        let uniqueIds = Array(Set(userIds)).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        if uniqueIds.isEmpty {
            return completion(.success([:]))
        }

        let group = DispatchGroup()
        let queue = DispatchQueue(label: "ProfileService.fetchProfiles.queue")
        var profilesById: [String: ProfileSummary] = [:]
        var firstError: Error?

        for userId in uniqueIds {
            group.enter()

            fetchProfile(userId: userId) { result in
                queue.async {
                    switch result {
                    case .success(let profile):
                        let attrs = profile.attributes

                        let firstName = attrs.firstName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        let lastName = attrs.lastName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)

                        let authorName: String
                        if !fullName.isEmpty {
                            authorName = fullName
                        } else if let username = attrs.username, !username.isEmpty {
                            authorName = username
                        } else {
                            authorName = profile.id
                        }

                        let authorUsername = (attrs.username?.isEmpty == false ? attrs.username! : profile.id)

                        profilesById[userId] = ProfileSummary(
                            id: profile.id,
                            authorName: authorName,
                            authorUsername: authorUsername,
                            email: attrs.email ?? "",
                            authorProfileImageURL: attrs.profilePicture
                        )

                    case .failure(let error):
                        print("[ProfileService.fetchProfiles] Failed for userId \(userId):", error.localizedDescription)
                        if firstError == nil {
                            firstError = error
                        }
                    }

                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            if let firstError = firstError, profilesById.isEmpty {
                completion(.failure(firstError))
            } else {
                completion(.success(profilesById))
            }
        }
    }
}
