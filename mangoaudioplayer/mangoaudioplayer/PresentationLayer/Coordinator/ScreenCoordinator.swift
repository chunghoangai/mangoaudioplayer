import SwiftUI

@MainActor
protocol ScreenCoordinator {
	associatedtype Screen: View
	var screen: Screen { get }
}
