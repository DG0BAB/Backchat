//
//  HTTPStatusCodes.swift
//
//  Created by Joachim Deelen on 12.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//
public enum HTTPStatusCode: Int {

	// MARK: - 1xx Informational

	/// 100: This means that the server has received the request headers, and that the client should proceed to send the request body (in the case of a request for which a body needs to be sent; for example, a POST request). If the request body is large, sending it to a server when a request has already been rejected based upon inappropriate headers is inefficient. To have a server check if the request could be accepted based on the request's headers alone, a client must send Expect: 100-continue as a header in its initial request and check if a 100 Continue status code is received in response before continuing (or receive 417 Expectation Failed and not continue).
	case `continue` = 100

	/// 101: This means the requester has asked the server to switch protocols and the server is acknowledging that it will do so.
	case switchingProtocols = 101

	/// 102: As a WebDAV request may contain many sub-requests involving file operations, it may take a long time to complete the request. This code indicates that the server has received and is processing the request, but no response is available yet.[3] This prevents the client from timing out and assuming the request was lost.
	case processing = 102

	private static var informationalCodes: Range<Int> {
		return Range(`continue`.rawValue...processing.rawValue)
	}

	var isInformational: Bool {
		switch self {
		case .`continue`, .switchingProtocols, .processing:
			return true
		default:
			return false
		}
	}

	static func isInformational(_ code: Int) -> Bool {
		return informationalCodes.contains(code)
	}
	// MARK: - 2xx Success

	/// 200: Standard response for successful HTTP requests. The actual response will depend on the request method used. In a GET request, the response will contain an entity corresponding to the requested resource. In a POST request, the response will contain an entity describing or containing the result of the action.
	case ok = 200

	/// 201: The request has been fulfilled and resulted in a new resource being created.
	case created = 201

	/// 202: The request has been accepted for processing, but the processing has not been completed. The request might or might not eventually be acted upon, as it might be disallowed when processing actually takes place.
	case accepted = 202

	/// 203: The server successfully processed the request, but is returning information that may be from another source.
	case nonAuthoritativeInformation = 203

	// 204: The server successfully processed the request, but is not returning any content.
	case noContent = 204

	/// 205: The server successfully processed the request, but is not returning any content. Unlike a 204 response, this response requires that the requester reset the document view.
	case resetContent = 205

	/// 206: The server is delivering only part of the resource (byte serving) due to a range header sent by the client. The range header is used by HTTP clients to enable resuming of interrupted downloads, or split a download into multiple simultaneous streams.
	case partialContent = 206

	/// 207: The message body that follows is an XML message and can contain a number of separate response codes, depending on how many sub-requests were made.[4]
	case multiStatus = 207

	/// 208: The members of a DAV binding have already been enumerated in a previous reply to this request, and are not being included again.
	case alreadyReported = 208

	/// 226: The server has fulfilled a request for the resource, and the response is a representation of the result of one or more instance-manipulations applied to the current instance.[5]case
	case imUsed = 226

	private static var successCodes: Range<Int> {
		return Range(ok.rawValue...imUsed.rawValue)
	}

	var isSuccess: Bool {
		switch self {
		case .ok,
			 .created,
			 .accepted,
			 .nonAuthoritativeInformation,
			 .noContent,
			 .resetContent,
			 .partialContent,
			 .multiStatus,
			 .alreadyReported,
			 .imUsed:
			return true
		default:
			return false
		}
	}

	static func isSuccess(_ code: Int) -> Bool {
		return successCodes.contains(code)
	}

	// MARK: - 3xx Redirection

	/// 300: Indicates multiple options for the resource that the client may follow. It, for instance, could be used to present different format options for video, list files with different extensions, or word sense disambiguation.
	case multipleChoices = 300

	/// 301: This and all future requests should be directed to the given URI.
	case movedPermanently = 301

	/// 302: This is an example of industry practice contradicting the standard. The HTTP/1.0 specification (RFC 1945 required the client to perform a temporary redirect (the original describing phrase was "Moved Temporarily"),[6] but popular browsers implemented 302 with the functionality of a 303 See Other. Therefore, HTTP/1.1 added status codes 303 and 307 to distinguish between the two behaviours.[7] However, some Web applications and frameworks use the 302 status code as if it were the 303.[8]
	case found = 302

	/// 303: The response to the request can be found under another URI using a GET method. When received in response to a POST (or PUT/DELETE), it should be assumed that the server has received the data and the redirect should be issued with a separate GET message.
	case seeOther = 303

	/// 304: Indicates that the resource has not been modified since the version specified by the request headers If-Modified-Since or If-None-Match. This means that there is no need to retransmit the resource, since the client still has a previously-downloaded copy.
	case notModified = 304

	/// 305: The requested resource is only available through a proxy, whose address is provided in the response. Many HTTP clients (such as Mozilla[9] and Internet Explorer) do not correctly handle responses with this status code, primarily for security reasons.[10]
	case useProxy = 305

	/// 306: No longer used. Originally meant "Subsequent requests should use the specified proxy."[11]
	case switchProxy = 306

	/// 307: In this case, the request should be repeated with another URI; however, future requests should still use the original URI. In contrast to how 302 was historically implemented, the request method is not allowed to be changed when reissuing the original request. For instance, a POST request should be repeated using another POST request.[12]
	case temporaryRedirect = 307

	/// 308: **RFC:** The request, and all future requests should be repeated using another URI. 307 and 308 (as proposed) parallel the behaviours of 302 and 301, but do not allow the HTTP method to change. So, for example, submitting a form to a permanently redirected resource may continue smoothly.[13]
	///
	/// **Google:** This code is used in the Resumable HTTP Requests Proposal to resume aborted PUT or POST requests.[14]
	case permanentRedirect_ResumeIncomplete = 308

	static var redirectionCodes: Range<Int> {
		return Range(multipleChoices.rawValue...permanentRedirect_ResumeIncomplete.rawValue)
	}

	var isRedirection: Bool {
		switch self {
		case .multipleChoices,
			 .movedPermanently,
			 .found,
			 .seeOther,
			 .notModified,
			 .useProxy,
			 .switchProxy,
			 .temporaryRedirect,
			 .permanentRedirect_ResumeIncomplete:
			return true
		default:
			return false
		}
	}

	static func isRedirection(_ code: Int) -> Bool {
		return redirectionCodes.contains(code)
	}

	// MARK: - 4xx Client-Error

	/// 400: The server cannot or will not process the request due to something that is perceived to be a client error (e.g., malformed request syntax, invalid request message framing, or deceptive request routing).[15]
	case badRequest = 400

	/// 401: Similar to 403 Forbidden, but specifically for use when authentication is required and has failed or has not yet been provided. The response must include a WWW-Authenticate header field containing a challenge applicable to the requested resource. See Basic access authentication and Digest access authentication.
	case unauthorized = 401

	/// 402: Reserved for future use. The original intention was that this code might be used as part of some form of digital cash or micropayment scheme, but that has not happened, and this code is not usually used. YouTube uses this status if a particular IP address has made excessive requests, and requires the person to enter a CAPTCHA.[citation needed]
	case paymentRequired = 402

	/// 403: The request was a valid request, but the server is refusing to respond to it. Unlike a 401 Unauthorized response, authenticating will make no difference.
	case forbidden = 403

	/// 404: The requested resource could not be found but may be available again in the future. Subsequent requests by the client are permissible.
	case notFound = 404

	/// 405: A request was made of a resource using a request method not supported by that resource; for example, using GET on a form which requires data to be presented via POST, or using PUT on a read-only resource.
	case methodNotAllowed = 405

	/// 406: The requested resource is only capable of generating content not acceptable according to the Accept headers sent in the request.
	case notAcceptable = 406

	/// 407: The client must first authenticate itself with the proxy.
	case proxyAuthenticationRequired = 407

	/// 408: The server timed out waiting for the request. According to HTTP specifications: "The client did not produce a request within the time that the server was prepared to wait. The client MAY repeat the request without modifications at any later time."
	case requestTimeout = 408

	/// 409: Indicates that the request could not be processed because of conflict in the request, such as an edit conflict in the case of multiple updates.
	case conflict = 409

	/// 410: Indicates that the resource requested is no longer available and will not be available again. This should be used when a resource has been intentionally removed and the resource should be purged. Upon receiving a 410 status code, the client should not request the resource again in the future. Clients such as search engines should remove the resource from their indices.[16] Most use cases do not require clients and search engines to purge the resource, and a "404 Not Found" may be used instead.
	case gone = 410

	/// 411: The request did not specify the length of its content, which is required by the requested resource.
	case lengthRequired = 411

	/// 412: The server does not meet one of the preconditions that the requester put on the request.
	case preconditionFailed = 412

	/// 413: The request is larger than the server is willing or able to process. Called "Request Entity Too Large " previously.
	case payloadTooLarge = 413

	/// 414: The URI provided was too long for the server to process. Often the result of too much data being encoded as a query-string of a GET request, in which case it should be converted to a POST request.
	case requestURITooLong = 414

	/// 415: The request entity has a media type which the server or resource does not support. For example, the client uploads an image as image/svg+xml, but the server requires that images use a different format.
	case unsupportedMediaType = 415

	/// 416: The client has asked for a portion of the file (byte serving), but the server cannot supply that portion. For example, if the client asked for a part of the file that lies beyond the end of the file.
	case requestedRangeNotSatisfiable = 416

	/// 417: The server cannot meet the requirements of the Expect request-header field.
	case expectationFailed = 417

	/// 418: This code was defined in 1998 as one of the traditional IETF April Fools' jokes, in RFC 2324, Hyper Text Coffee Pot Control Protocol, and is not expected to be implemented by actual HTTP servers. The RFC specifies this code should be returned by tea pots requested to brew coffee.
	case imATeapot = 418

	/// 419: Not a part of the HTTP standard, 419 Authentication Timeout denotes that previously valid authentication has expired. It is used as an alternative to 401 Unauthorized in order to differentiate from otherwise authenticated clients being denied access to specific server resources.[citation needed]
	case authenticationTimeout = 419

	/// 420: **Spring-Framework:** Not part of the HTTP standard, but defined by Spring in the HttpStatus class to be used when a method failed. This status code is deprecated by Spring.
	///
	/// **Twitter:** Not part of the HTTP standard, but returned by version 1 of the Twitter Search and Trends API when the client is being rate limited.[17] Other services may wish to implement the 429 Too Many Requests response code instead.
	case methodFailure_EnhanceYourCalm = 420

	/// 421: The request was directed at a server that is not able to produce a response (for example because a connection reuse).[18]
	case misdirectedRequest = 421

	/// 422: The request was well-formed but was unable to be followed due to semantic errors.[4]
	case unprocessableEntity = 422

	/// 423: The resource that is being accessed is locked.[4]
	case locked = 423

	/// 424: The request failed due to failure of a previous request (e.g., a PROPPATCH).[4]
	case failedDependency = 424

	/// 426: The client should switch to a different protocol such as TLS/1.0, given in the Upgrade header field.
	case upgradeRequired = 426

	/// 428: The origin server requires the request to be conditional. Intended to prevent "the 'lost update' problem, where a client GETs a resource's state, modifies it, and PUTs it back to the server, when meanwhile a third party has modified the state on the server, leading to a conflict."[19]
	case preconditionRequired = 428

	/// 429: The user has sent too many requests in a given amount of time. Intended for use with rate limiting schemes.[19]
	case tooManyRequests = 429

	/// 431: The server is unwilling to process the request because either an individual header field, or all the header fields collectively, are too large.[19]
	case requestHeaderFieldsTooLarge = 431

	/// 440: A Microsoft extension. Indicates that your session has expired.[20]
	case loginTimeout = 440

	/// 444: Used in Nginx logs to indicate that the server has returned no information to the client and closed the connection (useful as a deterrent for malware).
	case noResponse = 444

	/// 449: A Microsoft extension. The request should be retried after performing the appropriate action.[21]
	case retryWith = 449

	/// 450: A Microsoft extension. This error is given when Windows Parental Controls are turned on and are blocking access to the given webpage.[22]
	case blockedByWindowsParentalControls = 450

	/// 451: Defined in the internet draft "A New HTTP Status Code for Legally-restricted Resources".[23] Intended to be used when resource access is denied for legal reasons, e.g. censorship or government-mandated blocked access. A reference to the 1953 dystopian novel Fahrenheit 451, where books are outlawed.[24]
	///
	/// **Microsoft:** Used in Exchange ActiveSync if there either is a more efficient server to use or the server cannot access the users' mailbox.[25] The client is supposed to re-run the HTTP Autodiscovery protocol to find a better suited server.[26]
	case unavailableForLegalReasons_Redirect = 451

	/// 494: Nginx internal code similar to 431 but it was introduced earlier in version 0.9.4 (on January 21, 2011.[27][original research?]
	case requestHeaderTooLarge = 494

	/// 495: Nginx internal code used when SSL client certificate error occurred to distinguish it from 4XX in a log and an error page redirection.
	case certError = 495

	/// 496: Nginx internal code used when client didn't provide certificate to distinguish it from 4XX in a log and an error page redirection.
	case noCert = 496

	/// 497: Nginx internal code used for the plain HTTP requests that are sent to HTTPS port to distinguish it from 4XX in a log and an error page redirection.
	case httpToHTTPS = 497

	/// 498: Returned by ArcGIS for Server. A code of 498 indicates an expired or otherwise invalid token.[28]
	case tokenExpiredOrIsInvalid = 498

	/// 499: **Nginx:** Used in Nginx logs to indicate when the connection has been closed by client while the server is still processing its request, making server unable to send a status code back.[29]
	///
	/// **Esri:** Returned by ArcGIS for Server. A code of 499 indicates that a token is required (if no token was submitted).[28]
	case clientClosedRequest_TokenRequired = 499

	private static var clientErrorCodes: Range<Int> {
		return Range(badRequest.rawValue...clientClosedRequest_TokenRequired.rawValue)
	}

	var isClientError: Bool {
		switch self {
		case .badRequest,
			 .unauthorized,
			 .paymentRequired,
			 .forbidden,
			 .notFound,
			 .methodNotAllowed,
			 .notAcceptable,
			 .proxyAuthenticationRequired,
			 .requestTimeout,
			 .conflict,
			 .gone,
			 .lengthRequired,
			 .preconditionFailed,
			 .payloadTooLarge,
			 .requestURITooLong,
			 .unsupportedMediaType,
			 .requestedRangeNotSatisfiable,
			 .expectationFailed,
			 .imATeapot,
			 .authenticationTimeout,
			 .methodFailure_EnhanceYourCalm,
			 .misdirectedRequest,
			 .unprocessableEntity,
			 .locked,
			 .failedDependency,
			 .upgradeRequired,
			 .preconditionRequired,
			 .tooManyRequests,
			 .requestHeaderFieldsTooLarge,
			 .loginTimeout,
			 .noResponse,
			 .retryWith,
			 .blockedByWindowsParentalControls,
			 .unavailableForLegalReasons_Redirect,
			 .requestHeaderTooLarge,
			 .certError,
			 .noCert,
			 .httpToHTTPS,
			 .tokenExpiredOrIsInvalid,
			 .clientClosedRequest_TokenRequired:
			return true
		default:
			return false
		}
	}

	static func isClientError(_ code: Int) -> Bool {
		return clientErrorCodes.contains(code)
	}

	// MARK: - 5xx Server-Error

	/// 500: A generic error message, given when an unexpected condition was encountered and no more specific message is suitable.
	case internalServerError = 500

	/// 501: The server either does not recognize the request method, or it lacks the ability to fulfill the request. Usually this implies future availability (e.g., a new feature of a web-service API).
	case notImplemented = 501

	/// 502: The server was acting as a gateway or proxy and received an invalid response from the upstream server.
	case badGateway = 502

	/// 503: The server is currently unavailable (because it is overloaded or down for maintenance). Generally, this is a temporary state.
	case serviceUnavailable = 503

	/// 504: The server was acting as a gateway or proxy and did not receive a timely response from the upstream server.
	case gatewayTimeout = 504

	/// 505:  The server does not support the HTTP protocol version used in the request.
	case httpVersionNotSupported = 505

	/// 506: Transparent content negotiation for the request results in a circular reference.[30]
	case variantAlsoNegotiates = 506

	/// 507: The server is unable to store the representation needed to complete the request.[4]
	case insufficientStorage = 507

	/// 508: The server detected an infinite loop while processing the request (sent in lieu of 208 Already Reported).
	case loopDetected = 508

	/// 509: This status code is not specified in any RFCs. Its use is unknown.
	case bandwidthLimitExceeded = 509

	/// 510: Further extensions to the request are required for the server to fulfil it.[32]
	case notExtended = 510

	/// 511: The client needs to authenticate to gain network access. Intended for use by intercepting proxies used to control access to the network (e.g., "captive portals" used to require agreement to Terms of Service before granting full Internet access via a Wi-Fi hotspot).[19]
	case networkAuthenticationRequired = 511

	/// 520: This status code is not specified in any RFC and is returned by certain services, for instance Microsoft Azure and CloudFlare servers: "The 520 error is essentially a “catch-all” response for when the origin server returns something unexpected or something that is not tolerated/interpreted (protocol violation or empty response)."[33]
	case unknownError = 520

	/// 522: This status code is not specified in any RFCs, but is used by CloudFlare's reverse proxies to signal that a server connection timed out.
	case originConnectionTimeOut = 522

	/// 598: This status code is not specified in any RFCs, but is used by Microsoft HTTP proxies to signal a network read timeout behind the proxy to a client in front of the proxy.[citation needed]
	case networkReadTimeoutError = 598

	/// 599: This status code is not specified in any RFCs, but is used by Microsoft HTTP proxies to signal a network connect timeout behind the proxy to a client in front of the proxy.[citation needed]
	case networkConnectTimeoutError = 599

	private static var serverErrorCodes: Range<Int> {
		return Range(internalServerError.rawValue...networkConnectTimeoutError.rawValue)
	}

	var isServerError: Bool {
		switch self {
		case .internalServerError,
			 .notImplemented,
			 .badGateway,
			 .serviceUnavailable,
			 .gatewayTimeout,
			 .httpVersionNotSupported,
			 .variantAlsoNegotiates,
			 .insufficientStorage,
			 .loopDetected,
			 .bandwidthLimitExceeded,
			 .notExtended,
			 .networkAuthenticationRequired,
			 .unknownError,
			 .originConnectionTimeOut,
			 .networkReadTimeoutError,
			 .networkConnectTimeoutError:
			return true
		default:
			return false
		}
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
