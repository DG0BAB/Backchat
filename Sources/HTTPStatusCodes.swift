//
//  HTTPStatusCodes.swift
//
//  Created by Joachim Deelen on 12.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//
enum HTTPStatusCode {

	// MARK: - 1xx Informational

	/// 100: This means that the server has received the request headers, and that the client should proceed to send the request body (in the case of a request for which a body needs to be sent; for example, a POST request). If the request body is large, sending it to a server when a request has already been rejected based upon inappropriate headers is inefficient. To have a server check if the request could be accepted based on the request's headers alone, a client must send Expect: 100-continue as a header in its initial request and check if a 100 Continue status code is received in response before continuing (or receive 417 Expectation Failed and not continue).
	case `continue`(Int = 100)

	/// 101: This means the requester has asked the server to switch protocols and the server is acknowledging that it will do so.
	case switchingProtocols(Int = 101)

	/// 102: As a WebDAV request may contain many sub-requests involving file operations, it may take a long time to complete the request. This code indicates that the server has received and is processing the request, but no response is available yet.[3] This prevents the client from timing out and assuming the request was lost.
	case processing(Int = 102)

	static var informationalCodes: Range<Int> {
		return Range(100...102)
	}

	var isInformational: Bool {
		var code = 0
		switch self {
		case .`continue`(let value),
			 .switchingProtocols(let value),
			 .processing(let value):
			code = value
		default:
			break
		}
		return HTTPStatusCode.informationalCodes.contains(code)
	}

	static func isInformational(_ code: Int) -> Bool {
		return informationalCodes.contains(code)
	}
	// MARK: - 2xx Success

	/// 200: Standard response for successful HTTP requests. The actual response will depend on the request method used. In a GET request, the response will contain an entity corresponding to the requested resource. In a POST request, the response will contain an entity describing or containing the result of the action.
	case ok(Int = 200)

	/// 201: The request has been fulfilled and resulted in a new resource being created.
	case created(Int = 201)

	/// 202: The request has been accepted for processing, but the processing has not been completed. The request might or might not eventually be acted upon, as it might be disallowed when processing actually takes place.
	case accepted(Int = 202)

	/// 203: The server successfully processed the request, but is returning information that may be from another source.
	case nonAuthoritativeInformation(Int = 203)

	// 204: The server successfully processed the request, but is not returning any content.
	case noContent(Int = 204)

	/// 205: The server successfully processed the request, but is not returning any content. Unlike a 204 response, this response requires that the requester reset the document view.
	case resetContent(Int = 205)

	/// 206: The server is delivering only part of the resource (byte serving) due to a range header sent by the client. The range header is used by HTTP clients to enable resuming of interrupted downloads, or split a download into multiple simultaneous streams.
	case partialContent(Int = 206)

	/// 207: The message body that follows is an XML message and can contain a number of separate response codes, depending on how many sub-requests were made.[4]
	case multiStatus(Int = 207)

	/// 208: The members of a DAV binding have already been enumerated in a previous reply to this request, and are not being included again.
	case alreadyReported(Int = 208)

	/// 226: The server has fulfilled a request for the resource, and the response is a representation of the result of one or more instance-manipulations applied to the current instance.[5]case
	case imUsed(Int = 226)

	static var successCodes: Range<Int> {
		return Range(200...226)
	}

	var isSuccess: Bool {
		var code = 0
		switch self {
		case .ok(let value),
			 .created(let value),
			 .accepted(let value),
			 .nonAuthoritativeInformation(let value),
			 .noContent(let value),
			 .resetContent(let value),
			 .partialContent(let value),
			 .multiStatus(let value),
			 .alreadyReported(let value),
			 .imUsed(let value):
			code = value
		default:
			break
		}
		return HTTPStatusCode.successCodes.contains(code)
	}

	static func isSuccess(_ code: Int) -> Bool {
		return successCodes.contains(code)
	}

	// MARK: - 3xx Redirection

	/// 300: Indicates multiple options for the resource that the client may follow. It, for instance, could be used to present different format options for video, list files with different extensions, or word sense disambiguation.
	case multipleChoices(Int = 300)

	/// 301: This and all future requests should be directed to the given URI.
	case movedPermanently(Int = 301)

	/// 302: This is an example of industry practice contradicting the standard. The HTTP/1.0 specification (RFC 1945) required the client to perform a temporary redirect (the original describing phrase was "Moved Temporarily"),[6] but popular browsers implemented 302 with the functionality of a 303 See Other. Therefore, HTTP/1.1 added status codes 303 and 307 to distinguish between the two behaviours.[7] However, some Web applications and frameworks use the 302 status code as if it were the 303.[8]
	case found(Int = 302)

	/// 303: The response to the request can be found under another URI using a GET method. When received in response to a POST (or PUT/DELETE), it should be assumed that the server has received the data and the redirect should be issued with a separate GET message.
	case seeOther(Int = 303)

	/// 304: Indicates that the resource has not been modified since the version specified by the request headers If-Modified-Since or If-None-Match. This means that there is no need to retransmit the resource, since the client still has a previously-downloaded copy.
	case notModified(Int = 304)

	/// 305: The requested resource is only available through a proxy, whose address is provided in the response. Many HTTP clients (such as Mozilla[9] and Internet Explorer) do not correctly handle responses with this status code, primarily for security reasons.[10]
	case useProxy(Int = 305)

	/// 306: No longer used. Originally meant "Subsequent requests should use the specified proxy."[11]
	case switchProxy(Int = 306)

	/// 307: In this case, the request should be repeated with another URI; however, future requests should still use the original URI. In contrast to how 302 was historically implemented, the request method is not allowed to be changed when reissuing the original request. For instance, a POST request should be repeated using another POST request.[12]
	case temporaryRedirect(Int = 307)

	/// 308: **RFC:** The request, and all future requests should be repeated using another URI. 307 and 308 (as proposed) parallel the behaviours of 302 and 301, but do not allow the HTTP method to change. So, for example, submitting a form to a permanently redirected resource may continue smoothly.[13]
	///
	/// **Google:** This code is used in the Resumable HTTP Requests Proposal to resume aborted PUT or POST requests.[14]
	case permanentRedirect_ResumeIncomplete(Int = 308)

	static var redirectionCodes: Range<Int> {
		return Range(300...308)
	}

	var isRedirection: Bool {
		var code = 0
		switch self {
		case .multipleChoices(let value),
			 .movedPermanently(let value),
			 .found(let value),
			 .seeOther(let value),
			 .notModified(let value),
			 .useProxy(let value),
			 .switchProxy(let value),
			 .temporaryRedirect(let value),
			 .permanentRedirect_ResumeIncomplete(let value):
			code = value
		default:
			break
		}
		return HTTPStatusCode.redirectionCodes.contains(code)
	}

	static func isRedirection(_ code: Int) -> Bool {
		return redirectionCodes.contains(code)
	}

	// MARK: - 4xx Client-Error

	/// 400: The server cannot or will not process the request due to something that is perceived to be a client error (e.g., malformed request syntax, invalid request message framing, or deceptive request routing).[15]
	case badRequest(Int = 400)

	/// 401: Similar to 403 Forbidden, but specifically for use when authentication is required and has failed or has not yet been provided. The response must include a WWW-Authenticate header field containing a challenge applicable to the requested resource. See Basic access authentication and Digest access authentication.
	case unauthorized(Int = 401)

	/// 402: Reserved for future use. The original intention was that this code might be used as part of some form of digital cash or micropayment scheme, but that has not happened, and this code is not usually used. YouTube uses this status if a particular IP address has made excessive requests, and requires the person to enter a CAPTCHA.[citation needed]
	case paymentRequired(Int = 402)

	/// 403: The request was a valid request, but the server is refusing to respond to it. Unlike a 401 Unauthorized response, authenticating will make no difference.
	case forbidden(Int = 403)

	/// 404: The requested resource could not be found but may be available again in the future. Subsequent requests by the client are permissible.
	case notFound(Int = 404)

	/// 405: A request was made of a resource using a request method not supported by that resource; for example, using GET on a form which requires data to be presented via POST, or using PUT on a read-only resource.
	case methodNotAllowed(Int = 405)

	/// 406: The requested resource is only capable of generating content not acceptable according to the Accept headers sent in the request.
	case notAcceptable(Int = 406)

	/// 407: The client must first authenticate itself with the proxy.
	case proxyAuthenticationRequired(Int = 407)

	/// 408: The server timed out waiting for the request. According to HTTP specifications: "The client did not produce a request within the time that the server was prepared to wait. The client MAY repeat the request without modifications at any later time."
	case requestTimeout(Int = 408)

	/// 409: Indicates that the request could not be processed because of conflict in the request, such as an edit conflict in the case of multiple updates.
	case conflict(Int = 409)

	/// 410: Indicates that the resource requested is no longer available and will not be available again. This should be used when a resource has been intentionally removed and the resource should be purged. Upon receiving a 410 status code, the client should not request the resource again in the future. Clients such as search engines should remove the resource from their indices.[16] Most use cases do not require clients and search engines to purge the resource, and a "404 Not Found" may be used instead.
	case gone(Int = 410)

	/// 411: The request did not specify the length of its content, which is required by the requested resource.
	case lengthRequired(Int = 411)

	/// 412: The server does not meet one of the preconditions that the requester put on the request.
	case preconditionFailed(Int = 412)

	/// 413: The request is larger than the server is willing or able to process. Called "Request Entity Too Large " previously.
	case payloadTooLarge(Int = 413)

	/// 414: The URI provided was too long for the server to process. Often the result of too much data being encoded as a query-string of a GET request, in which case it should be converted to a POST request.
	case requestURITooLong(Int = 414)

	/// 415: The request entity has a media type which the server or resource does not support. For example, the client uploads an image as image/svg+xml, but the server requires that images use a different format.
	case unsupportedMediaType(Int = 415)

	/// 416: The client has asked for a portion of the file (byte serving), but the server cannot supply that portion. For example, if the client asked for a part of the file that lies beyond the end of the file.
	case requestedRangeNotSatisfiable(Int = 416)

	/// 417: The server cannot meet the requirements of the Expect request-header field.
	case expectationFailed(Int = 417)

	/// 418: This code was defined in 1998 as one of the traditional IETF April Fools' jokes, in RFC 2324, Hyper Text Coffee Pot Control Protocol, and is not expected to be implemented by actual HTTP servers. The RFC specifies this code should be returned by tea pots requested to brew coffee.
	case imATeapot(Int = 418)

	/// 419: Not a part of the HTTP standard, 419 Authentication Timeout denotes that previously valid authentication has expired. It is used as an alternative to 401 Unauthorized in order to differentiate from otherwise authenticated clients being denied access to specific server resources.[citation needed]
	case authenticationTimeout(Int = 419)

	/// 420: **Spring-Framework:** Not part of the HTTP standard, but defined by Spring in the HttpStatus class to be used when a method failed. This status code is deprecated by Spring.
	///
	/// **Twitter:** Not part of the HTTP standard, but returned by version 1 of the Twitter Search and Trends API when the client is being rate limited.[17] Other services may wish to implement the 429 Too Many Requests response code instead.
	case methodFailure_EnhanceYourCalm(Int = 420)

	/// 421: The request was directed at a server that is not able to produce a response (for example because a connection reuse).[18]
	case misdirectedRequest(Int = 421)

	/// 422: The request was well-formed but was unable to be followed due to semantic errors.[4]
	case unprocessableEntity(Int = 422)

	/// 423: The resource that is being accessed is locked.[4]
	case locked(Int = 423)

	/// 424: The request failed due to failure of a previous request (e.g., a PROPPATCH).[4]
	case failedDependency(Int = 424)

	/// 426: The client should switch to a different protocol such as TLS/1.0, given in the Upgrade header field.
	case upgradeRequired(Int = 426)

	/// 428: The origin server requires the request to be conditional. Intended to prevent "the 'lost update' problem, where a client GETs a resource's state, modifies it, and PUTs it back to the server, when meanwhile a third party has modified the state on the server, leading to a conflict."[19]
	case preconditionRequired(Int = 428)

	/// 429: The user has sent too many requests in a given amount of time. Intended for use with rate limiting schemes.[19]
	case tooManyRequests(Int = 429)

	/// 431: The server is unwilling to process the request because either an individual header field, or all the header fields collectively, are too large.[19]
	case requestHeaderFieldsTooLarge(Int = 431)

	/// 440: A Microsoft extension. Indicates that your session has expired.[20]
	case loginTimeout(Int = 440)

	/// 444: Used in Nginx logs to indicate that the server has returned no information to the client and closed the connection (useful as a deterrent for malware).
	case noResponse(Int = 444)

	/// 449: A Microsoft extension. The request should be retried after performing the appropriate action.[21]
	case retryWith(Int = 449)

	/// 450: A Microsoft extension. This error is given when Windows Parental Controls are turned on and are blocking access to the given webpage.[22]
	case blockedByWindowsParentalControls(Int = 450)

	/// 451: Defined in the internet draft "A New HTTP Status Code for Legally-restricted Resources".[23] Intended to be used when resource access is denied for legal reasons, e.g. censorship or government-mandated blocked access. A reference to the 1953 dystopian novel Fahrenheit 451, where books are outlawed.[24]
	///
	/// **Microsoft:** Used in Exchange ActiveSync if there either is a more efficient server to use or the server cannot access the users' mailbox.[25] The client is supposed to re-run the HTTP Autodiscovery protocol to find a better suited server.[26]
	case unavailableForLegalReasons_Redirect(Int = 451)

	/// 494: Nginx internal code similar to 431 but it was introduced earlier in version 0.9.4 (on January 21, 2011).[27][original research?]
	case requestHeaderTooLarge(Int = 494)

	/// 495: Nginx internal code used when SSL client certificate error occurred to distinguish it from 4XX in a log and an error page redirection.
	case certError(Int = 495)

	/// 496: Nginx internal code used when client didn't provide certificate to distinguish it from 4XX in a log and an error page redirection.
	case noCert(Int = 496)

	/// 497: Nginx internal code used for the plain HTTP requests that are sent to HTTPS port to distinguish it from 4XX in a log and an error page redirection.
	case httpToHTTPS(Int = 497)

	/// 498: Returned by ArcGIS for Server. A code of 498 indicates an expired or otherwise invalid token.[28]
	case tokenExpiredOrIsInvalid(Int = 498)

	/// 499: **Nginx:** Used in Nginx logs to indicate when the connection has been closed by client while the server is still processing its request, making server unable to send a status code back.[29]
	///
	/// **Esri:** Returned by ArcGIS for Server. A code of 499 indicates that a token is required (if no token was submitted).[28]
	case clientClosedRequest_TokenRequired(Int = 499)

	static var clientErrorCodes: Range<Int> {
		return Range(400...499)
	}

	var isClientError: Bool {
		var code = 0
		switch self {
		case .badRequest(let value),
			 .unauthorized(let value),
			 .paymentRequired(let value),
			 .forbidden(let value),
			 .notFound(let value),
			 .methodNotAllowed(let value),
			 .notAcceptable(let value),
			 .proxyAuthenticationRequired(let value),
			 .requestTimeout(let value),
			 .conflict(let value),
			 .gone(let value),
			 .lengthRequired(let value),
			 .preconditionFailed(let value),
			 .payloadTooLarge(let value),
			 .requestURITooLong(let value),
			 .unsupportedMediaType(let value),
			 .requestedRangeNotSatisfiable(let value),
			 .expectationFailed(let value),
			 .imATeapot(let value),
			 .authenticationTimeout(let value),
			 .methodFailure_EnhanceYourCalm(let value),
			 .misdirectedRequest(let value),
			 .unprocessableEntity(let value),
			 .locked(let value),
			 .failedDependency(let value),
			 .upgradeRequired(let value),
			 .preconditionRequired(let value),
			 .tooManyRequests(let value),
			 .requestHeaderFieldsTooLarge(let value),
			 .loginTimeout(let value),
			 .noResponse(let value),
			 .retryWith(let value),
			 .blockedByWindowsParentalControls(let value),
			 .unavailableForLegalReasons_Redirect(let value),
			 .requestHeaderTooLarge(let value),
			 .certError(let value),
			 .noCert(let value),
			 .httpToHTTPS(let value),
			 .tokenExpiredOrIsInvalid(let value),
			 .clientClosedRequest_TokenRequired(let value):
			code = value
		default:
			break
		}
		return HTTPStatusCode.clientErrorCodes.contains(code)
	}

	static func isClientError(_ code: Int) -> Bool {
		return clientErrorCodes.contains(code)
	}

	// MARK: - 5xx Server-Error

	/// 500: A generic error message, given when an unexpected condition was encountered and no more specific message is suitable.
	case internalServerError(Int = 500)

	/// 501: The server either does not recognize the request method, or it lacks the ability to fulfill the request. Usually this implies future availability (e.g., a new feature of a web-service API).
	case notImplemented(Int = 501)

	/// 502: The server was acting as a gateway or proxy and received an invalid response from the upstream server.
	case badGateway(Int = 502)

	/// 503: The server is currently unavailable (because it is overloaded or down for maintenance). Generally, this is a temporary state.
	case serviceUnavailable(Int = 503)

	/// 504: The server was acting as a gateway or proxy and did not receive a timely response from the upstream server.
	case gatewayTimeout(Int = 504)

	/// 505:  The server does not support the HTTP protocol version used in the request.
	case httpVersionNotSupported(Int = 505)

	/// 506: Transparent content negotiation for the request results in a circular reference.[30]
	case variantAlsoNegotiates(Int = 506)

	/// 507: The server is unable to store the representation needed to complete the request.[4]
	case insufficientStorage(Int = 507)

	/// 508: The server detected an infinite loop while processing the request (sent in lieu of 208 Already Reported).
	case loopDetected(Int = 508)

	/// 509: This status code is not specified in any RFCs. Its use is unknown.
	case bandwidthLimitExceeded(Int = 509)

	/// 510: Further extensions to the request are required for the server to fulfil it.[32]
	case notExtended(Int = 510)

	/// 511: The client needs to authenticate to gain network access. Intended for use by intercepting proxies used to control access to the network (e.g., "captive portals" used to require agreement to Terms of Service before granting full Internet access via a Wi-Fi hotspot).[19]
	case networkAuthenticationRequired(Int = 511)

	/// 520: This status code is not specified in any RFC and is returned by certain services, for instance Microsoft Azure and CloudFlare servers: "The 520 error is essentially a “catch-all” response for when the origin server returns something unexpected or something that is not tolerated/interpreted (protocol violation or empty response)."[33]
	case unknownError(Int = 520)

	/// 522: This status code is not specified in any RFCs, but is used by CloudFlare's reverse proxies to signal that a server connection timed out.
	case originConnectionTimeOut(Int = 522)

	/// 598: This status code is not specified in any RFCs, but is used by Microsoft HTTP proxies to signal a network read timeout behind the proxy to a client in front of the proxy.[citation needed]
	case networkReadTimeoutError(Int = 598)

	/// 599: This status code is not specified in any RFCs, but is used by Microsoft HTTP proxies to signal a network connect timeout behind the proxy to a client in front of the proxy.[citation needed]
	case networkConnectTimeoutError(Int = 599)

	static var serverErrorCodes: Range<Int> {
		return Range(500...599)
	}

	var isServerError: Bool {
		var code = 0
		switch self {
		case .internalServerError(let value),
			 .notImplemented(let value),
			 .badGateway(let value),
			 .serviceUnavailable(let value),
			 .gatewayTimeout(let value),
			 .httpVersionNotSupported(let value),
			 .variantAlsoNegotiates(let value),
			 .insufficientStorage(let value),
			 .loopDetected(let value),
			 .bandwidthLimitExceeded(let value),
			 .notExtended(let value),
			 .networkAuthenticationRequired(let value),
			 .unknownError(let value),
			 .originConnectionTimeOut(let value),
			 .networkReadTimeoutError(let value),
			 .networkConnectTimeoutError(let value):
			code = value
		default:
			break
		}
		return HTTPStatusCode.serverErrorCodes.contains(code)
	}

	static func isServerError(_ code: Int) -> Bool {
		return serverErrorCodes.contains(code)
	}
}
extension Range {
	var startValue: Bound {
		return self.lowerBound
	}
	var endValue: Bound {
		return self.upperBound
	}
}

