import Foundation

struct HTTPClientResponse {
	let data: Data
	let statusCode: Int
	let headers: [AnyHashable: Any]
}



enum HttpClientError: Error {
	case nonHTTPResponse
	case unsuccessfulStatusCode(Int)
	case unknowStatusCode
}

