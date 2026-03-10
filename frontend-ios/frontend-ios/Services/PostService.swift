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

    private let backendBaseURL = "https://lenninsabogal.online/tipical"

    private var session: URLSession {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = HTTPCookieStorage.shared
        config.httpShouldSetCookies = true
        config.httpCookieAcceptPolicy = .always
        return URLSession(configuration: config)
    }

    // MARK: - Debug helpers

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

        if let url = request.url,
           let cookies = HTTPCookieStorage.shared.cookies(for: url),
           !cookies.isEmpty {
            print("Cookies for request URL:")
            for cookie in cookies {
                print("- \(cookie.name)=\(cookie.value); domain=\(cookie.domain); path=\(cookie.path)")
            }
        } else {
            print("Cookies for request URL: none")
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

        if let cookies = HTTPCookieStorage.shared.cookies, !cookies.isEmpty {
            print("All shared cookies after response:")
            for cookie in cookies {
                print("- \(cookie.name)=\(cookie.value); domain=\(cookie.domain); path=\(cookie.path)")
            }
        } else {
            print("All shared cookies after response: none")
        }

        print("=====================================")
    }

    // MARK: - Fetch posts

    func fetchPosts(
        limit: Int = 20,
        completion: @escaping (Result<[PostResponseItem], Error>) -> Void
    ) {
        guard let url = URL(string: "\(backendBaseURL)/posts?limit=\(limit)") else {
            print("[PostService.fetchPosts] Invalid posts URL")
            return completion(.failure(SimpleError("Invalid posts URL")))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.httpShouldHandleCookies = true

        logRequest(request, name: "FETCH POSTS")

        session.dataTask(with: request) { data, response, error in
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

    // MARK: - Create post

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

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpShouldHandleCookies = true
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            print("[PostService.createPost] Encode error:", error.localizedDescription)
            return completion(.failure(error))
        }

        logRequest(request, name: "CREATE POST")

        session.dataTask(with: request) { data, response, error in
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

    // MARK: - Update post

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

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.httpShouldHandleCookies = true
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            print("[PostService.updatePost] Encode error:", error.localizedDescription)
            return completion(.failure(error))
        }

        logRequest(request, name: "UPDATE POST")

        session.dataTask(with: request) { data, response, error in
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

    // MARK: - Delete post

    func deletePost(
        postId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: "\(backendBaseURL)/posts/\(postId)") else {
            print("[PostService.deletePost] Invalid delete post URL")
            return completion(.failure(SimpleError("Invalid delete post URL")))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.httpShouldHandleCookies = true

        logRequest(request, name: "DELETE POST")

        session.dataTask(with: request) { data, response, error in
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
