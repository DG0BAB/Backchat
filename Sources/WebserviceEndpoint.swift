/**
Defines an endpoint for a WebService

Endpoints usualy require at least a `path` and a `httpMethod`.
The `path` is appended to a baseURL which is normally provided
by a `NetWorkService`. The HTTPMethod defines how this path is
accessed. Depennding on the HTTPMethod, their might be Data
in the request-body. The optional `contentType` defines the
type of this data. The path is suffixed by the `queryParameter`
if given.
*/
import Foundation
@_exported import Fehlerteufel

public protocol WebServiceEndpoint {
	/// The path to the Endpoint of the WebService
	/// including the leading "/". i.e. "/details"
	/// __Required.__
	var path: String { get }

	/// The HTTP Method used for the request
	/// __Required.__
	var httpMethod: HttpMethod { get }

	/// Type of the content that might be in the Request-Body
	/// Nowadays it's likely to contain "application/json"
	/// It's considered a programming error specifying body
	/// data without a `contentType`
	/// Defaults to nil
	var contentType: String? { get }

	/// Body-Data of type `contentType` that is send to the
	/// endpoint. If given, `contentType` must also contain
	/// a value.
	/// Defaults to nil
	var body: Data? { get }

	/// String with query parameter(s) that get appended to `path`
	/// The concrete endpoint must create this string including the leading "?"
	/// if parameters are needed
	/// Defaults to nil
	var queryParameter: String? { get }

	/// Additional header values that will be used in the Request
	/// Defaults to nil
	var additionalHeaderFields: [String : String]? { get }
	
	/// An `URLRequest` constructed from the values of this endpoint.
	var request: URLRequest { get }
}

public extension WebServiceEndpoint {
	var contentType: String? { return nil }
	var body: Data? { return nil }
	var queryParameter: String? { return nil }
	var additionalHeaderFields: [String : String]? { return nil }
	
	var request: URLRequest {
		var components = URLComponents()
		components.path = path
		components.query = queryParameter
		guard let url = components.url else { fatalError("Couldn't create URL for Endpoint \(self)") }
		var result = URLRequest(url: url)
		result.httpMethod = httpMethod.method
		if let additionalHeaderFields = additionalHeaderFields {
			result.allHTTPHeaderFields = result.allHTTPHeaderFields != nil
				? result.allHTTPHeaderFields!.merging(additionalHeaderFields) { $1 }
				: additionalHeaderFields
		}
		if let body = body,
			!body.isEmpty {
			guard let contentType = contentType else { fatalError("Body specified but missing contentType for Endpoint \(self)") }
			result.setValue(contentType, forHTTPHeaderField: "Content-Type")
			result.httpBody = body
		}
		return result
	}
}
