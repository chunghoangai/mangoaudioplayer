//
//  HomeCoordinator.swift
//  mangoaudioplayer
//
//  Created by mango on 10/14/26.
//
import SwiftUI
import Combine

enum HomeCoordinatorAction {
	case trackSelected(AudioTrack)
}

@MainActor
final class HomeCoordinator: ScreenCoordinator {
	private let viewModel: HomeViewModel
	private let actionsSubject = PassthroughSubject<HomeCoordinatorAction, Never>()
	private var cancellables = Set<AnyCancellable>()
	var actions: AnyPublisher<HomeCoordinatorAction, Never> {
		actionsSubject.eraseToAnyPublisher()
	}

	init(audioRepository: AudioRepositoryProtocol) {
		let viewModel = HomeViewModel(audioRepository: audioRepository)
		self.viewModel = viewModel

		viewModel.actions
			.sink { [weak self] action in
				switch action {
				case .trackSelected(let track):
					self?.actionsSubject.send(.trackSelected(track))
				}
			}
			.store(in: &cancellables)
	}

	var screen: HomeView {
		HomeView(viewModel: viewModel)
	}
}
