//
//  AppCoordinator.swift
//  mangoaudioplayer
//
//  Created by mango on 10/14/26.
//
import SwiftUI

@MainActor
final class AppCoordinator {
	private let rootFlowCoordinator: RootFlowCoordinator

	init() {
		let audioRepository = RemoteAudioRepository(httpClient: URLSessionHttpClient())
		let navigationCoordinator = NavigationStackCoordinator<AudioRoute>()
		rootFlowCoordinator = RootFlowCoordinator(
			audioRepository: audioRepository,
			navigationCoordinator: navigationCoordinator
		)
	}

	var rootView: some View {
		rootFlowCoordinator.view
	}
}
