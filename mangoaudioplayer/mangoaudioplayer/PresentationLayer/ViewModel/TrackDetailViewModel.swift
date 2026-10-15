import Foundation
import Observation

@MainActor
@Observable
final class TrackDetailViewModel {
	private(set) var metadata: AudioTrackMetadata?
	private(set) var lyric: AudioLyric?
	private(set) var isLoading = false
	private(set) var errorMessage: String?

	private let trackID: UUID
	private let audioRepository: AudioRepositoryProtocol

	init(trackID: UUID, audioRepository: AudioRepositoryProtocol) {
		self.trackID = trackID
		self.audioRepository = audioRepository
	}

	func loadDetails() async {
		guard !isLoading else { return }
		isLoading = true
		errorMessage = nil
		defer { isLoading = false }

		do {
			metadata = try await audioRepository.fetchMetadata(for: trackID)
			lyric = try await audioRepository.fetchLyric(for: trackID)
		} catch {
			errorMessage = error.localizedDescription
		}
	}
}
