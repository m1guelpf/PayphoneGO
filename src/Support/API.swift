import SwiftUI
import Foundation
import MetaCodable
import Dependencies
import HelperCoders

@MainActor
struct API: Sendable {
	enum Error: Equatable, Swift.Error {
		case requestFailed(URLResponse)

		var localizedDescription: String {
			switch self {
				case let .requestFailed(response): "Request failed: \(response)"
			}
		}
	}

	private let baseURL = URL(string: "https://walzr.com/payphone-go/api")!

	var logger: Logger {
		Logger(category: "API")
	}
}

// API Endpoints
extension API {
	func phones() async throws -> [Phone] {
		return try await get(baseURL.appending(path: "phones"), as: [Phone].self)
	}

	func phone(id: Int) async throws -> PhoneDetails {
		return try await get(baseURL.appending(path: "phone/\(id)"), as: PhoneDetails.self)
	}

	func leaderboard() async throws -> [LeaderboardEntry] {
		return try await get(baseURL.appending(path: "leaderboard"), as: [LeaderboardEntry].self)
	}
}

// API Types
extension API {
	struct PhoneDetails: Equatable, Hashable, Codable {
		struct PhoneData: Identifiable, Equatable, Hashable, Codable {
			var id: Int
		}

		var payphone: PhoneData
		var claims: [Claim]
		var totalClaims: Int
	}

	@Codable @CodingKeys(.snake_case) struct LeaderboardEntry: Equatable, Hashable {
		var displayName: String
		@CodedBy(ValueCoder<Int>()) var points: Int
		var claims: Int
	}
}

/// HTTP Requests
extension API {
	enum Method: String {
		case get = "GET"
		case put = "PUT"
		case post = "POST"
		case patch = "PATCH"
		case delete = "DELETE"
	}

	func get<T: Decodable>(_ url: URL, headers: [String: String] = [:], as _: T.Type, expects statusCode: Int = 200) async throws -> T {
		try await send(url, method: .get, headers: headers, as: T.self, expects: statusCode)
	}

	func get(_ url: URL, headers: [String: String] = [:], expects statusCode: Int = 200) async throws {
		_ = try await send(url, method: .get, headers: headers, as: String?.self, expects: statusCode)
	}

	func post<T: Decodable>(_ url: URL, headers: [String: String] = [:], body: (any Encodable)? = nil, as _: T.Type, expects statusCode: Int = 200) async throws -> T {
		try await send(url, method: .post, headers: headers, body: body, as: T.self, expects: statusCode)
	}

	func post(_ url: URL, headers: [String: String] = [:], body: (any Encodable)? = nil, expects statusCode: Int = 200) async throws {
		_ = try await send(url, method: .post, headers: headers, body: body, as: String?.self, expects: statusCode)
	}

	func put<T: Decodable>(_ url: URL, headers: [String: String] = [:], body: (any Encodable)? = nil, as _: T.Type, expects statusCode: Int = 200) async throws -> T {
		try await send(url, method: .put, headers: headers, body: body, as: T.self, expects: statusCode)
	}

	func put(_ url: URL, headers: [String: String] = [:], body: (any Encodable)? = nil, expects statusCode: Int = 200) async throws {
		_ = try await send(url, method: .put, headers: headers, body: body, as: String?.self, expects: statusCode)
	}

	func delete<T: Decodable>(_ url: URL, headers: [String: String] = [:], body: (any Encodable)? = nil, as _: T.Type, expects statusCode: Int = 200) async throws -> T {
		try await send(url, method: .delete, headers: headers, body: body, as: T.self, expects: statusCode)
	}

	func delete(_ url: URL, headers: [String: String] = [:], body: (any Encodable)? = nil, expects statusCode: Int = 200) async throws {
		_ = try await send(url, method: .delete, headers: headers, body: body, as: String?.self, expects: statusCode)
	}

	private func send(_ url: URL, method: Method = .get, headers: [String: String] = [:], body: (any Encodable)? = nil, expects statusCode: Int = 200, isAuthRetry _: Bool = false) async throws -> Data {
		let (data, response) = try await URLSession.shared.data(for: tap(URLRequest(url: url)) { request in
			request.httpMethod = method.rawValue

			request.setValue("application/json", forHTTPHeaderField: "Accept")
			request.setValue("PayphoneGO iOS (m1guelpf)", forHTTPHeaderField: "User-Agent")

			for (key, value) in headers {
				request.setValue(value, forHTTPHeaderField: key)
			}

			if let body {
				request.httpBody = try JSONEncoder.default.encode(body)
				request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			}
		})

		guard let response = response as? HTTPURLResponse else {
			throw Error.requestFailed(response)
		}

		if response.statusCode == statusCode {
			return data
		}

		throw Error.requestFailed(response)
	}

	private func send<T: Decodable>(_ url: URL, method: Method = .get, headers: [String: String] = [:], body: (any Encodable)? = nil, as _: T.Type, expects statusCode: Int = 200) async throws -> T {
		var data = try await send(url, method: method, headers: headers, body: body, expects: statusCode)

		if data.isEmpty { data = Data("null".utf8) }
		return try JSONDecoder.default.decode(T.self, from: data)
	}
}

extension API: DependencyKey {
	static let liveValue = API()
}

extension DependencyValues {
	var api: API {
		get { self[API.self] }
		set { self[API.self] = newValue }
	}
}
