import SwiftUI
import Dependencies

#if DEBUG
import Atlantis

fileprivate struct WrappedInNavigationModifier: ViewModifier {
	func body(content: Content) -> some View {
		NavigationContainer(parentRouter: .previewRouter()) {
			content
		}
	}
}

extension View {
	func withPreviewData(wrapInNavigation: Bool = true) -> some View {
		Atlantis.start(hostName: "supernova.local.")

		@Dependency(\.appData) var appData

		return `if`(wrapInNavigation) { $0.modifier(WrappedInNavigationModifier()) }
			.task { await appData.load() }
			.environment(LocationManager())
	}
}
#else
extension View {
	func withPreviewData(wrapInNavigation _: Bool = true) -> some View {
		self
	}
}
#endif
