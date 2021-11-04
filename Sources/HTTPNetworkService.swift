//
//  HTTPNetworkService.swift
//
//  Created by Joachim Deelen on 08.01.18.
//  Copyright © 2018 micabo-software UG. All rights reserved.
//

import Foundation
@_exported import Fehlerteufel
import PromiseKit


extension LocalizedErrorUserInfoKey {
	public static let responseKey: LocalizedErrorUserInfoKey = "responseUserInfoKey"
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
		static func sendingRequest(failure: FailureText? = nil) -> NetworkServiceError {
			return Error(name: #function, severity: .error, failure: failure)
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
	private let tokenHook: TokenHook?
	private var currentTask: URLSessionDataTask?

	/// Initialise a `HTTPNetworkService`
	/// - Parameters:
	///   - baseURL: The base `URL` of the server to talk to
	///   - urlSession: The `URLSession` to use. Defaults to a simple session with a default confguration
	///   - xHeaderFields: Additional header fields. Defaults to an empty array
	///   - tokenHook: Optional `TokenHook`. Defaults to nil
	public required init(baseURL: URL,
						 urlSession: URLSession = .default,
						 xHeaderFields: [String : String] = [:],
						 tokenHook: TokenHook? = nil) {
		self.baseURL = baseURL
		self.urlSession = urlSession
		self.xHeaderFields = xHeaderFields
		self.tokenHook = tokenHook
	}

	/// Initialise a `HTTPNetworkService` with just a base `URL` and default values otherwise
	convenience init?(baseURL: String) {
		guard let url = URL(string: baseURL) else { return nil}
		self.init(baseURL: url)
	}

	/// Sends the given `URLRequest` to the URL this `NetworkService` was initialised with.
	/// The `URLSession`, HeaderFields and `TokenHook` of this `NetworkService` are also taken into account
	/// - Parameter request: The `URLRequest` to send
	/// - Returns: A `NetworkServiceResponse` which basically is a Promise 
	public func sendRequest(_ request: URLRequest) -> NetworkServiceResponse {
		// Cancel any previous task
		currentTask?.cancel()

		return Promise { seal in

			let tokenHook = self.tokenHook ?? { return Promise<String?>.value(nil) }
			tokenHook()
					.done { (token) in
						// Make request mutatable
						var request = request
						
						guard var baseURLComponents = URLComponents(url: self.baseURL, resolvingAgainstBaseURL: false) else {
							seal.reject(NetworkServiceError.preparingRequest { "Malformed base URL" })
							return
						}
						
						// Check if relative URL exist
						guard let relativeUrl = request.url,
							let relativeComponents = URLComponents(url: relativeUrl, resolvingAgainstBaseURL: false) else {
								seal.reject(NetworkServiceError.preparingRequest { "Missing relative path in request" })
								return
						}
						
						baseURLComponents.path = baseURLComponents.path + relativeComponents.path
						if baseURLComponents.percentEncodedQueryItems != nil {
							baseURLComponents.percentEncodedQueryItems?.append(contentsOf: relativeComponents.percentEncodedQueryItems ?? [])
						} else {
							baseURLComponents.percentEncodedQueryItems = relativeComponents.percentEncodedQueryItems
						}
						// Create and Check absolute URL
						guard let url = baseURLComponents.url(relativeTo: baseURLComponents.url) else {
							seal.reject(NetworkServiceError.preparingRequest { "Couldn't create URL from given \("url:", relativeComponents.url) and base \("base:", self.baseURL)." })
							return
						}
						request.url = url
						self.xHeaderFields.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
						if let token = token {
							request.setValue(token, forHTTPHeaderField: "Authorization")
						}
						// Create the task
						self.currentTask = self.urlSession.dataTask(with: request) { (data, responseReceived, error) in
							defer { self.currentTask = nil }
							
							// In case of error reject immediately
							guard error == nil else {
								let error = error!
								if error.isCancelled {
									seal.reject(NetworkServiceError.cancelled { "Request \("request:", request) was cancelled" })
								} else {
									seal.reject(NetworkServiceError.sendingRequest { "Got error \("error:", error.localizedDescription) after sending request." })
								}
								return
							}
							
							// Reject if not a HTTPRespone
							guard let response = responseReceived as? HTTPURLResponse else {
								seal.reject(NetworkServiceError.response { "Received illegal response \("response:", responseReceived)" })
								return
							}
							
							// Reject, if status code is not OK
							guard HTTPStatusCode.isSuccess(response.statusCode) else {
								let userInfo: [LocalizedErrorUserInfoKey : Any] = [.responseKey : response]
								if HTTPStatusCode.isClientError(response.statusCode) {
									seal.reject(NetworkServiceError.response(userInfo: userInfo) { "Received client error with status code \("code:", response.statusCode)" })
								} else if HTTPStatusCode.isServerError(response.statusCode) {
									seal.reject(NetworkServiceError.response(userInfo: userInfo) { "Received server error with status code \("code:", response.statusCode)" })
								} else {
									seal.reject(NetworkServiceError.response(userInfo: userInfo) { "Received response with status code \("code:", response.statusCode)" })
								}
								return
							}
							// Reject if no data was received
							guard let data = data,
								!data.isEmpty else {
									seal.reject(NetworkServiceError.response { "No data received." })
									return
							}
							// All is well so fulfill the promise
							Log.info("Request an \(request.url!) erfolgreich gesendet und Response verarbeitet.")
							seal.fulfill((response, data))
						}
						// Start the task
						self.currentTask?.resume()
					}
					.catch { error in
						seal.reject(NetworkServiceError.preparingRequest { "TokenHook got no token" })
						return
					}
		}
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
