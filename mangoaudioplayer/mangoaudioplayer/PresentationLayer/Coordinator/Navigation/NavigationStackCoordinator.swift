import SwiftUI
import Observation

@MainActor
@Observable
final class NavigationStackCoordinator<Route: Hashable>: NavigationCoordinator {
	var path: [Route] = []

	func push(_ route: Route) {
		path.append(route)
	}

	func pop() {
		guard !path.isEmpty else { return }
		path.removeLast()
	}

	func popToRoot() {
		path.removeAll()
	}

	func view<Root: View, Destination: View>(
		@ViewBuilder root: () -> Root,
		@ViewBuilder destination: @escaping (Route) -> Destination
	) -> some View {
		NavigationStackContainer<Route, Root, Destination>(
			coordinator: self,
			root: root(),
			destination: destination
		)
	}
}

private struct NavigationStackContainer<Route: Hashable, Root: View, Destination: View>: View {
	@Bindable private var coordinator: NavigationStackCoordinator<Route>
	let root: Root
	let destination: (Route) -> Destination

	init(
		coordinator: NavigationStackCoordinator<Route>,
		root: Root,
		destination: @escaping (Route) -> Destination
	) {
		_coordinator = Bindable(coordinator)
		self.root = root
		self.destination = destination
	}

	var body: some View {
		NavigationStack(path: $coordinator.path) {
			root.navigationDestination(for: Route.self, destination: destination)
		}
	}
}
