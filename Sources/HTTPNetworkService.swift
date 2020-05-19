//
//  HTTPNetworkService.swift
//
//  Created by Joachim Deelen on 08.01.18.
//  Copyright © 2018 micabo-software UG. All rights reserved.
//

import Foundation
import PromiseKit

class HTTPNetworkService: NetworkService {

	struct NetworkServiceError: LocalizedError {
		static var tableName: String { return "NetworkServiceErrors" }

		let specifics: ErrorSpecifics
		init(_ specifics: ErrorSpecifics) { self.specifics = specifics }

		static func preparingRequest(_ code: String = "\(#function)", title: Clause? = nil, recovery: Clause? = nil, failure: FailureText? = nil) -> NetworkServiceError {
			return Error(code, .error, title: title, recovery: recovery, failure)
		}
		static func sendingRequest(_ code: String = "\(#function)", title: Clause? = nil, recovery: Clause? = nil, failure: FailureText? = nil) -> NetworkServiceError {
			return Error(code, .error, title: title, recovery: recovery, failure)
		}
		static func response(_ code: String = "\(#function)", title: Clause? = nil, recovery: Clause? = nil, failure: FailureText? = nil) -> NetworkServiceError {
			return Error(code, .error, title: title, recovery: recovery, failure)
		}
		static func cancelled(_ code: String = "\(#function)", title: Clause? = nil, recovery: Clause? = nil, failure: FailureText? = nil) -> NetworkServiceError {
			return Error(code, .info, title: title, recovery: recovery, failure)
		}
	}

	private let baseURL: URL
	private let urlSession: URLSession
	private let xHeaderFields: [String: String]
	private var currentTask: URLSessionDataTask?

	required init(baseURL: URL,
				  urlSession: URLSession = .default,
				  xHeaderFields: [String: String] = [:]) {
		self.baseURL = baseURL
		self.urlSession = urlSession
		self.xHeaderFields = xHeaderFields
	}

	convenience init?(baseURL: String) {
		guard let url = URL(string: baseURL) else { return nil}
		self.init(baseURL: url)
	}

	func sendRequest(_ request: URLRequest) -> NetworkServiceResponse {
		// Cancel any previous task
		currentTask?.cancel()

		return Promise { seal in

			// Make request mutatable
			var request = request

			// Check if relative URL exist
			guard let relativeUrl = request.url,
				let component = URLComponents(url: relativeUrl, resolvingAgainstBaseURL: true) else {
					seal.reject(NetworkServiceError.preparingRequest { "Missing relative path in request" })
					return
			}

			// Create and Check absolute URL
			guard let url = component.url(relativeTo: baseURL) else {
				seal.reject(NetworkServiceError.preparingRequest { "Couldn't create URL from given \("url:", component.url) and base \("base:", self.baseURL)." })
				return
			}
			request.url = url
			xHeaderFields.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
			
			// Create the task
			currentTask = urlSession.dataTask(with: request) { (data, responseReceived, error) in
				defer { self.currentTask = nil }

				// In case of error reject immediately
				guard error == nil else {
					let error = error!
					if error.isCancelled {
						seal.reject(NetworkServiceError.cancelled { "Request \("request:", request) was cancelled" })
					} else {
						seal.reject(NetworkServiceError.sendingRequest { "Got error \("error:", error.localizedDescription) after sending requst." })
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
					if HTTPStatusCode.isClientError(response.statusCode) {
						seal.reject(NetworkServiceError.response { "Received client error with statuc code \("code:", response.statusCode)" })
					} else if HTTPStatusCode.isServerError(response.statusCode) {
						seal.reject(NetworkServiceError.response { "Received server error with statuc code \("code:", response.statusCode)" })
					} else {
						seal.reject(NetworkServiceError.response { "Received response with status code \("code:", response.statusCode)" })
					}
					return
				}
				// Reject if no data was received
				guard let data = data,
					data.isNotEmpty else {
					seal.reject(NetworkServiceError.response { "No data received." })
					return
				}
				// All is well so fulfill the promise
				seal.fulfill((response, data))
			}
			// Start the task
			currentTask?.resume()
		}
	}
}

// MARK: - URLSession

private extension URLSession {
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
