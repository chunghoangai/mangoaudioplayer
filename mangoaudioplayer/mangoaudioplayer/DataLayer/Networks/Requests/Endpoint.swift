import Foundation

struct Endpoint {
	let path: String
	let method: HTTPMethod
	let queryItems: [URLQueryItem] = []
	let body: Data? = nil
	let headers: [String: String] = [:]

	enum HTTPMethod: String {
		case get = "GET"
		case post = "POST"
	}
}

