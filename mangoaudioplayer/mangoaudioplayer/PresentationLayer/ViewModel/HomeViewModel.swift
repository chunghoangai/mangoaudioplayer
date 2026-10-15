import Foundation
import Combine
import Observation

enum HomeViewModelAction {
	case trackSelected(AudioTrack)
}

@MainActor
@Observable
final class HomeViewModel {
	private(set) var tracks: [AudioTrack] = []
	private(set) var isLoading = false
	private(set) var errorMessage: String?
	private let actionsSubject = PassthroughSubject<HomeViewModelAction, Never>()
	var actions: AnyPublisher<HomeViewModelAction, Never> {
		actionsSubject.eraseToAnyPublisher()
	}

	private let audioRepository: AudioRepositoryProtocol

	init(audioRepository: AudioRepositoryProtocol) {
		self.audioRepository = audioRepository
	}

	func loadTracks() async {
		guard !isLoading else { return }

		isLoading = true
		errorMessage = nil
		defer { isLoading = false }

		do {
			tracks = try await audioRepository.fetchAudios()
		} catch {
			errorMessage = error.localizedDescription
		}
	}

	func selectTrack(_ track: AudioTrack) {
		actionsSubject.send(.trackSelected(track))
	}
}
