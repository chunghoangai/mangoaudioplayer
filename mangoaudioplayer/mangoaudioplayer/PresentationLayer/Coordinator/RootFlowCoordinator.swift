import SwiftUI
import Combine

@MainActor
final class RootFlowCoordinator {
	private let audioRepository: AudioRepositoryProtocol
	private let navigationCoordinator: NavigationStackCoordinator<AudioRoute>
	private let homeCoordinator: HomeCoordinator
	private var trackDetailCoordinators: [UUID: TrackDetailCoordinator] = [:]
	private var cancellables = Set<AnyCancellable>()

	init(
		audioRepository: AudioRepositoryProtocol,
		navigationCoordinator: NavigationStackCoordinator<AudioRoute>
	) {
		self.audioRepository = audioRepository
		self.navigationCoordinator = navigationCoordinator
		homeCoordinator = HomeCoordinator(audioRepository: audioRepository)

		homeCoordinator.actions
			.sink { [weak self] action in
				guard case .trackSelected(let track) = action else { return }
				self?.showTrackDetails(for: track)
			}
			.store(in: &cancellables)
	}

	var view: some View {
		navigationCoordinator.view(root: { homeCoordinator.screen }) { [weak self] route in
			switch route {
			case .trackDetail(let trackID):
				if let coordinator = self?.trackDetailCoordinators[trackID] {
					coordinator.screen
				} else {
					ContentUnavailableView("Track Not Found", systemImage: "music.note")
				}
			}
		}
		.onChange(of: navigationCoordinator.path) { [weak self] _, path in
			guard let self else { return }
			let visibleTrackIDs = Set<UUID>(path.compactMap { route in
				guard case .trackDetail(let trackID) = route else { return nil }
				return trackID
			})
			trackDetailCoordinators = trackDetailCoordinators.filter {
				visibleTrackIDs.contains($0.key)
			}
		}
	}

	private func showTrackDetails(for track: AudioTrack) {
		trackDetailCoordinators[track.id] = TrackDetailCoordinator(
			track: track,
			audioRepository: audioRepository
		)
		navigationCoordinator.push(.trackDetail(track.id))
	}
}
