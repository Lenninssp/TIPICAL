//
//  LikeService.swift
//  frontend-ios
//

import Foundation

final class LikeService {
    static let shared = LikeService()
    private init() {}

    private let backendBaseURL = APIConfiguration.baseURL
    private let tokenStore = TokenStore.shared

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

        if let contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        request.httpBody = body
        return .success(request)
    }

    func likePost(
        postId: String,
        completion: @escaping (Result<LikeResponseItem, Error>) -> Void
    ) {
        guard let url = URL(string: "\(backendBaseURL)/post_likes") else {
            return completion(.failure(SimpleError("Invalid like URL")))
        }

        let payload = CreateLikeRequest(postId: postId)

        let body: Data
        do {
            body = try JSONEncoder().encode(payload)
        } catch {
            return completion(.failure(error))
        }

        let request: URLRequest
        switch authorizedRequest(
            url: url,
            method: "POST",
            body: body,
            contentType: "application/json"
        ) {
        case .failure(let error):
            return completion(.failure(error))
        case .success(let built):
            request = built
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                return completion(.failure(error))
            }

            guard let http = response as? HTTPURLResponse else {
                return completion(.failure(SimpleError("Invalid response")))
            }

            guard (200...299).contains(http.statusCode) else {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No body"
                return completion(.failure(SimpleError("Like failed (\(http.statusCode)): \(body)")))
            }

            guard let data else {
                return completion(.failure(SimpleError("Missing response data")))
            }

            do {
                let decoded = try JSONDecoder().decode(APIResource<LikeResponseItem>.self, from: data)
                completion(.success(decoded.data))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchLikes(
        targetUserId: String? = nil,
        limit: Int = 30,
        completion: @escaping (Result<[LikeResponseItem], Error>) -> Void
    ) {
        guard var components = URLComponents(string: "\(backendBaseURL)/post_likes") else {
            return completion(.failure(SimpleError("Invalid likes URL")))
        }

        var queryItems = [URLQueryItem(name: "limit", value: String(limit))]
        if let targetUserId, !targetUserId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            queryItems.append(URLQueryItem(name: "targetUserId", value: targetUserId))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            return completion(.failure(SimpleError("Invalid likes URL")))
        }

        let request: URLRequest
        switch authorizedRequest(url: url, method: "GET") {
        case .failure(let error):
            return completion(.failure(error))
        case .success(let built):
            request = built
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                return completion(.failure(error))
            }

            guard let http = response as? HTTPURLResponse else {
                return completion(.failure(SimpleError("Invalid response")))
            }

            guard (200...299).contains(http.statusCode) else {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No body"
                return completion(.failure(SimpleError("Fetch likes failed (\(http.statusCode)): \(body)")))
            }

            guard let data else {
                return completion(.failure(SimpleError("Missing response data")))
            }

            do {
                let decoded = try JSONDecoder().decode(APIResourceList<LikeResponseItem>.self, from: data)
                completion(.success(decoded.data))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func unlikePost(
        postId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: "\(backendBaseURL)/post_likes/\(postId)") else {
            return completion(.failure(SimpleError("Invalid unlike URL")))
        }

        let request: URLRequest
        switch authorizedRequest(url: url, method: "DELETE") {
        case .failure(let error):
            return completion(.failure(error))
        case .success(let built):
            request = built
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                return completion(.failure(error))
            }

            guard let http = response as? HTTPURLResponse else {
                return completion(.failure(SimpleError("Invalid response")))
            }

            guard (200...299).contains(http.statusCode) else {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No body"
                return completion(.failure(SimpleError("Unlike failed (\(http.statusCode)): \(body)")))
            }

            completion(.success(()))
        }.resume()
    }
}
