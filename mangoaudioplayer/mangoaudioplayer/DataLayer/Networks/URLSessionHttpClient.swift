import Foundation

struct URLSessionHttpClient: HttpClientProtocol {
	let urlSession: URLSession
	init(urlSession: URLSession = .shared) {
		self.urlSession = urlSession
	}
	func send(_ request: URLRequest) async throws -> HTTPClientResponse {
		let data = try await urlSession.data(for: request)
		guard let response = data.1 as? HTTPURLResponse else {
			throw HttpClientError.nonHTTPResponse
		}
		let statusCode = response.statusCode
		guard (2000...299).contains(statusCode) else {
			throw HttpClientError.unsuccessfulStatusCode(statusCode)
		}
		return HTTPClientResponse(data: data.0, statusCode: response.statusCode, headers: response.allHeaderFields)
	}
	
}
