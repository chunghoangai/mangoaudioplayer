import Foundation

extension Endpoint {
	static let audioTracks = Endpoint(
		path: "audio/v1/tracks",
		method: .get
	)
	static func trackMetadata(for trackID: UUID) -> Endpoint {
		Endpoint(
			path: String(format: "audio/v1/%@/metadata", trackID.uuidString),
			method: .get
		)
	}

	static func fetchLyric(for trackID: UUID) -> Endpoint {
		Endpoint(
			path: String(format: "audio/v1/%@/lyric", trackID.uuidString),
			method: .get
		)
	}
}
