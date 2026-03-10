//
//  APIConfiguration.swift
//  frontend-ios
//

import Foundation

enum APIConfiguration {
    static let baseURL: String = {
        let env = DotEnvLoader.values
        guard let raw = env["TIPICAL_API_BASE_URL"], !raw.isEmpty else {
            fatalError("Missing TIPICAL_API_BASE_URL in .env or process environment")
        }
        return normalizeBaseURL(raw)
    }()

    static func makeURL(path: String) -> URL? {
        let normalizedPath = path.hasPrefix("/") ? path : "/\(path)"
        return URL(string: "\(baseURL)\(normalizedPath)")
    }

    private static func normalizeBaseURL(_ value: String) -> String {
        var result = value.trimmingCharacters(in: .whitespacesAndNewlines)
        while result.hasSuffix("/") {
            result.removeLast()
        }
        return result
    }
}

private enum DotEnvLoader {
    static let values: [String: String] = {
        var parsed: [String: String] = [:]

        // Runtime environment (useful for CI and scheme overrides)
        for (key, value) in ProcessInfo.processInfo.environment where key.hasPrefix("TIPICAL_") {
            parsed[key] = value
        }

        guard let content = loadDotEnvContent() else {
            return parsed
        }

        for line in content.split(whereSeparator: \.isNewline) {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }

            let pair = trimmed.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            if pair.count != 2 { continue }

            let key = String(pair[0]).trimmingCharacters(in: .whitespacesAndNewlines)
            var value = String(pair[1]).trimmingCharacters(in: .whitespacesAndNewlines)
            if value.hasPrefix("\""), value.hasSuffix("\""), value.count >= 2 {
                value = String(value.dropFirst().dropLast())
            }

            if !key.isEmpty {
                parsed[key] = value
            }
        }

        return parsed
    }()

    private static func loadDotEnvContent() -> String? {
        if let url = Bundle.main.url(forResource: ".env", withExtension: nil),
           let content = try? String(contentsOf: url, encoding: .utf8) {
            return content
        }

        if let resourcePath = Bundle.main.resourcePath {
            let fallbackPath = "\(resourcePath)/.env"
            if let content = try? String(contentsOfFile: fallbackPath, encoding: .utf8) {
                return content
            }
        }

        return nil
    }
}
