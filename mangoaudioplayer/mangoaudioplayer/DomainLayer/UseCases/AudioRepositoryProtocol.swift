import Foundation

protocol AudioRepositoryProtocol {
	func fetchAudios() async throws -> [AudioTrack]
	func fetchMetadata(for trackId: UUID) async throws -> AudioTrackMetadata
	func fetchLyric(for trackId: UUID) async throws -> AudioLyric
}
