import Foundation

enum AudioRoute: Hashable {
	case trackDetail(UUID)
}

@MainActor
protocol NavigationCoordinator: AnyObject {
	associatedtype Route: Hashable
	var path: [Route] { get set }
	func push(_ route: Route)
	func pop()
	func popToRoot()
}
