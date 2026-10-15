import SwiftUI

@MainActor
final class TrackDetailCoordinator: ScreenCoordinator {
	private let track: AudioTrack
	private let viewModel: TrackDetailViewModel

	init(track: AudioTrack, audioRepository: AudioRepositoryProtocol) {
		self.track = track
		viewModel = TrackDetailViewModel(trackID: track.id, audioRepository: audioRepository)
	}

	var screen: TrackDetailView {
		TrackDetailView(track: track, viewModel: viewModel)
	}
}
