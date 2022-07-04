import Foundation
@_exported import Fehlerteufel
import PromiseKit

/// A closure that checks if the given `Data` is valid data
/// in the context of the validator.
/// Returns `true` if the data is valid otherwise false
public typealias ResponseDataValidator = (Data) -> Bool

/**
A `WebserviceAdapter` ties a `WebserviceEndpoint` to a `NetworkService`.

Information from the endpoint can be used to create the request which can then
be send to the server using the `NetworkService`. The optional `ResponseDataValidator`
can be used to vaildate the data received from the server.

Because it depends on how your concrete implementation of a `WebserviceAdapter`
works, the description of this protocol is written in subjunctive form.

The default implementation of `data` does, what's written in the summary.
*/
public protocol WebServiceAdapter {

	/** Sends a request to a server and retrieves the data from the response.

	The default implementation takes the request from the endpoint, sends it
	to the server using the given `NetworkService` and validates the received
	data with the help of the given `ResponseDataValidator`. If validation
	succeeds or no validator was given, it fulfills the promise with the
	received data. In case of error the promise is rejected.
	*/
	var invokeOld: Promise<Data> { get }
	var invoke: Data { get async throws }

	var endpoint: WebServiceEndpoint { get }
	var networkService: NetworkService { get }
	var validator: ResponseDataValidator? { get }

	/// Create an instance from the given `WebserviceEndpoint`
	init(endpoint: WebServiceEndpoint, networkService: NetworkService, validator: ResponseDataValidator?)
}


public extension WebServiceAdapter {

	// Request-sending and response-handling - Default Impl
	var invokeOld: Promise<Data> {
		return Promise { seal in
			Task.detached {
				do {
					let responseData = try await networkService.sendRequest(endpoint.request)
					guard self.validator?(responseData.0) ?? true else {
						seal.reject(WebServiceAdapterError.invalidData { "Data received but validator refused to validate it!" })
						return
					}
					seal.fulfill(responseData.0)
				} catch {
					seal.reject(WebServiceAdapterError.invokingEndpoint(cause: error, recovery: "Check connection") { "Invoking \("method:", endpoint.httpMethod.method) on \("endpoint:", endpoint.path)"})
				}



				//			networkService.sendRequest(endpoint.request)
				//				.done { responseData in
				//					guard self.validator?(responseData.data) ?? true else {
				//						seal.reject(WebServiceAdapterError.invalidData { "Data received but validator refused to validate it!" })
				//						return
				//					}
				//					seal.fulfill(responseData.data)
				//				}
				//				.catch { error in
				//					seal.reject(WebServiceAdapterError.invokingEndpoint(cause: error, recovery: "Check connection") { "Invoking \("method:", endpoint.httpMethod.method) on \("endpoint:", endpoint.path)"})
				//				}
			}
		}
	}

	var invoke: Data {
		get async throws {
			do {
				let responseData = try await networkService.sendRequest(endpoint.request)
				guard self.validator?(responseData.0) ?? true else {
					throw WebServiceAdapterError.invalidData { "Data received but validator refused to validate it!" }
				}
				return responseData.0
			} catch {
				throw WebServiceAdapterError.invokingEndpoint(cause: error, recovery: "Check connection") { "Invoking \("method:", endpoint.httpMethod.method) on \("endpoint:", endpoint.path)"}
			}
		}
	}
}

/** A protocol that enable conforming types to provide a `WebServiceAdaper`

Models should conform to this protocol so they can be easily loaded by the
`WebServiceAdapter/Endpoint/NetworkService` architecture.

Either let your models conform to this protocol if you need handling the response
and/or the received data in a special way or use the `WebServiceDefaultAdapter`
*/
public protocol WebServiceAdapterProviding {
	/// Creates and returns a fully initialized `WebServiceAdapter`
	///
	/// - Parameter userInfo: Provides user data that might be needed to create the adapter and
	/// associated `WebServiceEndpoint`s
	/// - Returns: The ready to use `WebServiceAdapter`
	static func webServiceAdapter(_ userInfo: [String: Any]?) -> WebServiceAdapter?
}

/** A default `WebServiceAdapter` for your convenience

You can use this adapter if you don't need any special handling of the
response or the received data.

It uses the data from the given endpoint to create the request which is send
to the server using the given `NetworkService` when the `data` property is queried.
After the data is received, it's validated using the given, optional `ResponseDataValidator`.
If validation succeeds or no validator was given, the `data` is given to the inquirer.
*/
public struct WebServiceDefaultAdapter: WebServiceAdapter {

	public var endpoint: WebServiceEndpoint
	public var networkService: NetworkService
	public var validator: ResponseDataValidator?

	public init(endpoint: WebServiceEndpoint, networkService: NetworkService, validator: ResponseDataValidator? = nil) {
		self.endpoint = endpoint
		self.networkService = networkService
		self.validator = validator
	}
}

/** Errors thrown by `WebServiceAdapter`s

Your own, specialized `WebServiceAdapter`s, can easily extend this and
add specific errors.
*/
struct WebServiceAdapterError: FTLocalizedError {
	static var stringsFileName: String { return "WebServiceAdapterErrors" }
	static var bundle: Bundle { Bundle.module }

	let store: ErrorStoring

	static func invokingEndpoint(cause: Error? = nil, recovery: Clause? = nil, failure: FailureText? = nil) -> WebServiceAdapterError {
		return Error(name: #function, severity: .error, cause: cause, recovery: recovery, failure: failure)
	}
	static func invalidData(cause: Error? = nil, recovery: Clause? = nil, failure: FailureText? = nil) -> WebServiceAdapterError {
		return Error(name: #function, severity: .error, cause: cause, recovery: recovery, failure: failure)
	}
}
