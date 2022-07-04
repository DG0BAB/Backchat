//
//  HTTPNetworkService.swift
//
//  Created by Joachim Deelen on 08.01.18.
//  Copyright © 2018 micabo-software UG. All rights reserved.
//

import Foundation
@_exported import Fehlerteufel

extension LocalizedErrorUserInfoKey {
	public static let responseKey: LocalizedErrorUserInfoKey = "responseUserInfoKey"
}

public extension Notification.Name {
	static let SpecialHTTPStatusCodeReceivedNotification = Notification.Name("SpecialHTTPStatusCodeReceivedNotification")
}

/// HTTP implementation of a `NetworkService`
open class HTTPNetworkService: NetworkService {

	struct NetworkServiceError: FTLocalizedError {
		static var stringsFileName: String { "NetworkServiceErrors" }
		static var bundle: Bundle { Bundle.module }

		let store: ErrorStoring

		static func preparingRequest(failure: FailureText? = nil) -> NetworkServiceError {
			return Error(name: #function, severity: .error, failure: failure)
		}
		static func sendingRequest(cause: Error? = nil, failure: FailureText? = nil) -> NetworkServiceError {
			return Error(name: #function, severity: .error, cause: cause, failure: failure)
		}
		static func response(userInfo: [LocalizedErrorUserInfoKey : Any]? = nil, failure: FailureText? = nil) -> NetworkServiceError {
			return Error(name: #function, severity: .error, userInfo: userInfo, failure: failure)
		}
		static func cancelled(failure: FailureText? = nil) -> NetworkServiceError {
			return Error(name: #function, severity: .info, failure: failure)
		}
	}
	
	private let baseURL: URL
	private let urlSession: URLSession
	private let xHeaderFields: [String: String]
	private let specialStatusCode: HTTPStatusCode?
	private let tokenHook: TokenHook?
	private var currentTask: URLSessionDataTask?

	/// Initialise a `HTTPNetworkService`
	/// - Parameters:
	///   - baseURL: The base `URL` of the server to talk to
	///   - urlSession: The `URLSession` to use. Defaults to a simple session with a default confguration
	///   - xHeaderFields: Additional header fields. Defaults to an empty array
	///   - specialHTTPStatusCode: A HTTP status code that, when received,
	/// 	leads to the sending of the `BackchatSpecialHTTPStatusCodeReceivedNotification`
	///   - tokenHook: Optional `TokenHook`. Defaults to nil
	public required init(baseURL: URL,
						 urlSession: URLSession = .default,
						 xHeaderFields: [String : String] = [:],
						 specialHTTPStatusCode: HTTPStatusCode? = nil,
						 tokenHook: TokenHook? = nil) {
		self.baseURL = baseURL
		self.urlSession = urlSession
		self.xHeaderFields = xHeaderFields
		self.specialStatusCode = specialHTTPStatusCode
		self.tokenHook = tokenHook
	}

	/// Initialise a `HTTPNetworkService` with just a base `URL` and default values otherwise
	convenience init?(baseURL: String) {
		guard let url = URL(string: baseURL) else { return nil}
		self.init(baseURL: url)
	}

	/// Asynchronously sends the given `URLRequest` to the URL this `NetworkService` was initialised with.
	/// The `URLSession`, HeaderFields and `TokenHook` of this `NetworkService` are also taken into account
	/// - Parameter request: The `URLRequest` to send
	/// - Returns: A `NetworkServiceResponse` which is the following tupple (Date, HTTPURLResponse)
	public func sendRequest(_ request: URLRequest) async throws -> NetworkServiceResponse {

		// Make request mutatable
		var request = request

		guard var baseURLComponents = URLComponents(url: self.baseURL, resolvingAgainstBaseURL: false) else {
			throw NetworkServiceError.preparingRequest { "Malformed base URL" }
		}

		// Check if relative URL exist
		guard let relativeUrl = request.url,
			  let relativeComponents = URLComponents(url: relativeUrl, resolvingAgainstBaseURL: false) else {
			throw NetworkServiceError.preparingRequest { "Missing relative path in request" }
		}

		baseURLComponents.path = baseURLComponents.path + relativeComponents.path
		if baseURLComponents.percentEncodedQueryItems != nil {
			baseURLComponents.percentEncodedQueryItems?.append(contentsOf: relativeComponents.percentEncodedQueryItems ?? [])
		} else {
			baseURLComponents.percentEncodedQueryItems = relativeComponents.percentEncodedQueryItems
		}
		// Create and Check absolute URL
		guard let url = baseURLComponents.url(relativeTo: baseURLComponents.url) else {
			throw NetworkServiceError.preparingRequest { "Couldn't create URL from given \("url:", relativeComponents.url) and base \("base:", self.baseURL)." }
		}
		request.url = url
		self.xHeaderFields.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

		let _tokenHook: TokenHook = self.tokenHook ?? { _ in return nil }
		
		var tryCount = 0
		var receivedResponse: NetworkServiceResponse

		repeat {
			print("This is try: \(tryCount) with \(String(describing: _tokenHook))")
			if let token = await _tokenHook(tryCount == 1) {
				print("Got \(tryCount == 0 ? "current token" : "new token")")
				request.setValue(token, forHTTPHeaderField: "Authorization")
			} else {
				print("Got no token for try \(tryCount)")
				tryCount += 1
			}
			do {
				let (data, response) = try await self.urlSession.data(for: request)

				guard let response = response as? HTTPURLResponse else {
					throw NetworkServiceError.response { "Received illegal response \("response:", response)" }
				}

				receivedResponse.0 = data
				receivedResponse.1 = response

				// Error Handling if status code is not OK (200)
				guard HTTPStatusCode.isSuccess(response.statusCode) else {
					let userInfo: [LocalizedErrorUserInfoKey : Any] = [.responseKey : response]
					if HTTPStatusCode.isClientError(response.statusCode) {
						if let specialStatusCode = self.specialStatusCode?.rawValue,
						   response.statusCode == specialStatusCode  {
							await MainActor.run {
								NotificationCenter.default.post(name: .SpecialHTTPStatusCodeReceivedNotification, object: self, userInfo: userInfo)
							}
						} else if response.statusCode == HTTPStatusCode.unauthorized.rawValue && tryCount == 0 {
							tryCount += 1
							print("Unauthorized! Trying to get new token with try count: \(tryCount)")
							continue
						}
						throw NetworkServiceError.response(userInfo: userInfo) { "Received client error with status code \("code:", response.statusCode)" }
					} else if HTTPStatusCode.isServerError(response.statusCode) {
						throw NetworkServiceError.response(userInfo: userInfo) { "Received server error with status code \("code:", response.statusCode)" }
					} else {
						throw NetworkServiceError.response(userInfo: userInfo) { "Received response with status code \("code:", response.statusCode)" }
					}
				}
				// All is well so fulfill the promise
				Log.info("Request an \(request.url!) erfolgreich gesendet und Response verarbeitet.")
				break
			} catch {
				throw NetworkServiceError.sendingRequest(cause: error) { "Got error \("error:", error.localizedDescription) after sending request." }
			}

		} while tryCount < 2
		return receivedResponse
	}
}

// MARK: - URLSession

public extension URLSession {
	static var `default`: URLSession {
		let configuration = URLSessionConfiguration.default
		configuration.httpMaximumConnectionsPerHost = 1
		configuration.requestCachePolicy = .reloadRevalidatingCacheData
		let result = URLSession(configuration: configuration)
		return result
	}
}

// Make URL useable for LoaclizedError
extension URL: PlaceholderValuePairing {
	public var placeholder: String { return "%@" }
	public var value: CVarArg { return self.description }
}

// Make URLRequest useable for LoaclizedError
extension URLRequest: PlaceholderValuePairing {
	public var placeholder: String { return "%@" }
	public var value: CVarArg { return self.description }
}

// Make URLResponse useable for LoaclizedError
extension URLResponse: PlaceholderValuePairing {
	public var placeholder: String { return "%@" }
	public var value: CVarArg { return self.description }
}
