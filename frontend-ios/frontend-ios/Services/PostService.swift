//
//  PostService.swift
//  frontend-ios
//
//  Created by Lennin Sabogal on 10/03/26.
//

import Foundation

final class PostService {
    static let shared = PostService()
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


    func fetchPosts(
        limit: Int = 20,
        completion: @escaping (Result<[PostResponseItem], Error>) -> Void
    ) {
        guard let url = URL(string: "\(backendBaseURL)/posts?limit=\(limit)") else {
            print("[PostService.fetchPosts] Invalid posts URL")
            return completion(.failure(SimpleError("Invalid posts URL")))
        }

        let request: URLRequest
        switch authorizedRequest(url: url, method: "GET") {
        case .failure(let error):
            return completion(.failure(error))
        case .success(let built):
            request = built
        }

        logRequest(request, name: "FETCH POSTS")

        URLSession.shared.dataTask(with: request) { data, response, error in
            self.logResponse(data: data, response: response, error: error, name: "FETCH POSTS")

            if let error = error {
                print("[PostService.fetchPosts] Network error:", error.localizedDescription)
                return completion(.failure(error))
            }

            guard let http = response as? HTTPURLResponse else {
                print("[PostService.fetchPosts] Invalid response type")
                return completion(.failure(SimpleError("Invalid response")))
            }

            guard (200...299).contains(http.statusCode) else {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No body"
                print("[PostService.fetchPosts] Non-2xx status:", http.statusCode)
                return completion(.failure(SimpleError("Fetch posts failed (\(http.statusCode)): \(body)")))
            }

            guard let data = data else {
                print("[PostService.fetchPosts] Missing response data")
                return completion(.failure(SimpleError("Missing response data")))
            }

            do {
                let decoded = try JSONDecoder().decode(APIResourceList<PostResponseItem>.self, from: data)
                print("[PostService.fetchPosts] Decoded posts count:", decoded.data.count)
                completion(.success(decoded.data))
            } catch {
                print("[PostService.fetchPosts] Decode error:", error.localizedDescription)
                completion(.failure(error))
            }
        }.resume()
    }


    func fetchPost(
        postId: String,
        completion: @escaping (Result<PostResponseItem, Error>) -> Void
    ) {
        guard let url = URL(string: "\(backendBaseURL)/posts/\(postId)") else {
            print("[PostService.fetchPost] Invalid post URL")
            return completion(.failure(SimpleError("Invalid post URL")))
        }

        let request: URLRequest
        switch authorizedRequest(url: url, method: "GET") {
        case .failure(let error):
            return completion(.failure(error))
        case .success(let built):
            request = built
        }

        logRequest(request, name: "FETCH POST")

        URLSession.shared.dataTask(with: request) { data, response, error in
            self.logResponse(data: data, response: response, error: error, name: "FETCH POST")

            if let error = error {
                return completion(.failure(error))
            }

            guard let http = response as? HTTPURLResponse else {
                return completion(.failure(SimpleError("Invalid response")))
            }

            guard (200...299).contains(http.statusCode) else {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No body"
                return completion(.failure(SimpleError("Fetch post failed (\(http.statusCode)): \(body)")))
            }

            guard let data = data else {
                return completion(.failure(SimpleError("Missing response data")))
            }

            do {
                let decoded = try JSONDecoder().decode(APIResource<PostResponseItem>.self, from: data)
                completion(.success(decoded.data))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }


    func createPost(
        title: String,
        description: String,
        archived: Bool = false,
        completion: @escaping (Result<PostResponseItem, Error>) -> Void
    ) {
        guard let url = URL(string: "\(backendBaseURL)/posts") else {
            print("[PostService.createPost] Invalid create post URL")
            return completion(.failure(SimpleError("Invalid create post URL")))
        }

        let payload = CreatePostRequest(
            title: title,
            description: description,
            archived: archived
        )

        let body: Data
        do {
            body = try JSONEncoder().encode(payload)
        } catch {
            print("[PostService.createPost] Encode error:", error.localizedDescription)
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

        logRequest(request, name: "CREATE POST")

        URLSession.shared.dataTask(with: request) { data, response, error in
            self.logResponse(data: data, response: response, error: error, name: "CREATE POST")

            if let error = error {
                print("[PostService.createPost] Network error:", error.localizedDescription)
                return completion(.failure(error))
            }

            guard let http = response as? HTTPURLResponse else {
                print("[PostService.createPost] Invalid response type")
                return completion(.failure(SimpleError("Invalid response")))
            }

            guard (200...299).contains(http.statusCode) else {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No body"
                print("[PostService.createPost] Non-2xx status:", http.statusCode)
                return completion(.failure(SimpleError("Create post failed (\(http.statusCode)): \(body)")))
            }

            guard let data = data else {
                print("[PostService.createPost] Missing response data")
                return completion(.failure(SimpleError("Missing response data")))
            }

            do {
                let decoded = try JSONDecoder().decode(APIResource<PostResponseItem>.self, from: data)
                print("[PostService.createPost] Decoded created post id:", decoded.data.id)
                completion(.success(decoded.data))
            } catch {
                print("[PostService.createPost] Decode error:", error.localizedDescription)
                completion(.failure(error))
            }
        }.resume()
    }


    func updatePost(
        postId: String,
        title: String?,
        description: String?,
        archived: Bool?,
        completion: @escaping (Result<PostResponseItem, Error>) -> Void
    ) {
        guard let url = URL(string: "\(backendBaseURL)/posts/\(postId)") else {
            print("[PostService.updatePost] Invalid update post URL")
            return completion(.failure(SimpleError("Invalid update post URL")))
        }

        let payload = UpdatePostRequest(
            title: title,
            description: description,
            archived: archived
        )

        let body: Data
        do {
            body = try JSONEncoder().encode(payload)
        } catch {
            print("[PostService.updatePost] Encode error:", error.localizedDescription)
            return completion(.failure(error))
        }

        let request: URLRequest
        switch authorizedRequest(
            url: url,
            method: "PATCH",
            body: body,
            contentType: "application/json"
        ) {
        case .failure(let error):
            return completion(.failure(error))
        case .success(let built):
            request = built
        }

        logRequest(request, name: "UPDATE POST")

        URLSession.shared.dataTask(with: request) { data, response, error in
            self.logResponse(data: data, response: response, error: error, name: "UPDATE POST")

            if let error = error {
                print("[PostService.updatePost] Network error:", error.localizedDescription)
                return completion(.failure(error))
            }

            guard let http = response as? HTTPURLResponse else {
                print("[PostService.updatePost] Invalid response type")
                return completion(.failure(SimpleError("Invalid response")))
            }

            guard (200...299).contains(http.statusCode) else {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No body"
                print("[PostService.updatePost] Non-2xx status:", http.statusCode)
                return completion(.failure(SimpleError("Update post failed (\(http.statusCode)): \(body)")))
            }

            guard let data = data else {
                print("[PostService.updatePost] Missing response data")
                return completion(.failure(SimpleError("Missing response data")))
            }

            do {
                let decoded = try JSONDecoder().decode(APIResource<PostResponseItem>.self, from: data)
                print("[PostService.updatePost] Decoded updated post id:", decoded.data.id)
                completion(.success(decoded.data))
            } catch {
                print("[PostService.updatePost] Decode error:", error.localizedDescription)
                completion(.failure(error))
            }
        }.resume()
    }


    func deletePost(
        postId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: "\(backendBaseURL)/posts/\(postId)") else {
            print("[PostService.deletePost] Invalid delete post URL")
            return completion(.failure(SimpleError("Invalid delete post URL")))
        }

        let request: URLRequest
        switch authorizedRequest(url: url, method: "DELETE") {
        case .failure(let error):
            return completion(.failure(error))
        case .success(let built):
            request = built
        }

        logRequest(request, name: "DELETE POST")

        URLSession.shared.dataTask(with: request) { data, response, error in
            self.logResponse(data: data, response: response, error: error, name: "DELETE POST")

            if let error = error {
                print("[PostService.deletePost] Network error:", error.localizedDescription)
                return completion(.failure(error))
            }

            guard let http = response as? HTTPURLResponse else {
                print("[PostService.deletePost] Invalid response type")
                return completion(.failure(SimpleError("Invalid response")))
            }

            guard (200...299).contains(http.statusCode) else {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No body"
                print("[PostService.deletePost] Non-2xx status:", http.statusCode)
                return completion(.failure(SimpleError("Delete post failed (\(http.statusCode)): \(body)")))
            }

            print("[PostService.deletePost] Delete succeeded for postId:", postId)
            completion(.success(()))
        }.resume()
    }
}
