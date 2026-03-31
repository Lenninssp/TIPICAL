//
//  CommentService.swift
//  frontend-ios
//

import Foundation

final class CommentService {
    static let shared = CommentService()
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

    func fetchComments(
        postId: String,
        completion: @escaping (Result<[CommentResponseItem], Error>) -> Void
    ) {
        guard var components = URLComponents(string: "\(backendBaseURL)/comments") else {
            return completion(.failure(SimpleError("Invalid comments URL")))
        }

        components.queryItems = [
            URLQueryItem(name: "postId", value: postId),
            URLQueryItem(name: "hidden", value: "false"),
        ]

        guard let url = components.url else {
            return completion(.failure(SimpleError("Invalid comments URL")))
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
                return completion(.failure(SimpleError("Fetch comments failed (\(http.statusCode)): \(body)")))
            }

            guard let data else {
                return completion(.failure(SimpleError("Missing response data")))
            }

            do {
                let decoded = try JSONDecoder().decode(APIResourceList<CommentResponseItem>.self, from: data)
                completion(.success(decoded.data))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchCommentCounts(
        postIds: [String],
        completion: @escaping (Result<[String: Int], Error>) -> Void
    ) {
        let requestedIds = Set(postIds.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
        if requestedIds.isEmpty {
            return completion(.success([:]))
        }

        guard var components = URLComponents(string: "\(backendBaseURL)/comments") else {
            return completion(.failure(SimpleError("Invalid comments URL")))
        }

        components.queryItems = [
            URLQueryItem(name: "hidden", value: "false"),
        ]

        guard let url = components.url else {
            return completion(.failure(SimpleError("Invalid comments URL")))
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
                return completion(.failure(SimpleError("Fetch comments failed (\(http.statusCode)): \(body)")))
            }

            guard let data else {
                return completion(.failure(SimpleError("Missing response data")))
            }

            do {
                let decoded = try JSONDecoder().decode(APIResourceList<CommentResponseItem>.self, from: data)
                var counts: [String: Int] = [:]

                for item in decoded.data {
                    guard let postId = item.attributes.postId, requestedIds.contains(postId) else {
                        continue
                    }

                    counts[postId, default: 0] += 1
                }

                completion(.success(counts))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func createComment(
        postId: String,
        comment: String,
        completion: @escaping (Result<CommentResponseItem, Error>) -> Void
    ) {
        guard let url = URL(string: "\(backendBaseURL)/comments") else {
            return completion(.failure(SimpleError("Invalid create comment URL")))
        }

        let payload = CreateCommentRequest(postId: postId, comment: comment)

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
                return completion(.failure(SimpleError("Create comment failed (\(http.statusCode)): \(body)")))
            }

            guard let data else {
                return completion(.failure(SimpleError("Missing response data")))
            }

            do {
                let decoded = try JSONDecoder().decode(APIResource<CommentResponseItem>.self, from: data)
                completion(.success(decoded.data))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
