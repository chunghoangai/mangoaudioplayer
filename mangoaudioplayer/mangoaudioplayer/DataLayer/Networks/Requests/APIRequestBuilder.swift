//
//  APIRequestBuilder.swift
//  mangoaudioplayer
//
//  Created by mango on 10/12/26.
//
import Foundation

struct APIRequestBuilder {
	private let baseURL: URL
	init(baseURL: URL) {
		self.baseURL = baseURL
	}
	
	init() {
		baseURL = URL(string: "")!
	}
	
	func makeRequest(for endpoint: Endpoint) throws -> URLRequest {
		let url = baseURL.appending(path: endpoint.path)
		var request = URLRequest(url: url)
		request.httpMethod = endpoint.method.rawValue
		if let body = endpoint.body {
			request.httpBody = body
		}
		let headers = endpoint.headers
		if !headers.isEmpty {
			for header in headers {
				request.setValue(header.value, forHTTPHeaderField: header.key)
			}
			
		}
		return request
		
	}
}
