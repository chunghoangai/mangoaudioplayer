import Foundation

protocol HttpClientProtocol {
	func send(_ request: URLRequest) async throws -> HTTPClientResponse
}
