/**
Available HTTP Methods
*/
public enum HttpMethod {
	case get
	case head
	case post
	case put
	case patch
	case delete

	/// Returns the name of the method to be used for the request
	var method: String {
		switch self {
		case .get:
			return "GET"
		case .head:
			return "HEAD"
		case .post:
			return "POST"
		case .put:
			return "PUT"
		case .patch:
			return "PATCH"
		case .delete:
			return "DELETE"
		}
	}
}
