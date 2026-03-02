import SwiftUI
import Foundation
@_exported import NavigationKit

enum Destination: NavigationDestination {
	enum Tabs: String, TabRepresentable {
		case home
		case leaderboard
	}

	enum Pages: PageRepresentable {
		case comingSoon(title: String)

		@ViewBuilder var view: some View {
			switch self {
				case let .comingSoon(title): UnavailableScreen(title: title)
			}
		}
	}

	enum Sheets: Identifiable, SheetRepresentable {
		case browser(url: URL)
		case phoneDetail(phone: Phone)

		var id: String {
			switch self {
				case let .phoneDetail(phone): "phone-\(phone.id)"
				case let .browser(url): "browser-\(url.absoluteString)"
			}
		}

		var detents: Set<PresentationDetent> {
			switch self {
				case .browser: [.large]
				default: [.medium, .large]
			}
		}

		@ViewBuilder var content: some View {
			switch self {
				case let .browser(url): BrowserSheet(url: url)
				case let .phoneDetail(phone): PhoneDetailSheet(phone: phone)
			}
		}
	}

	enum FullScreen: Identifiable, FullScreenRepresentable {
		case browser(url: URL)

		var id: String {
			switch self {
				case let .browser(url): url.absoluteString
			}
		}

		@ViewBuilder var content: some View {
			switch self {
				case let .browser(url): BrowserSheet(url: url)
			}
		}
	}
}

typealias Router = NavigationKit.Router<Destination>
typealias NavigationButton<Content: View> = NavigationKit.NavigationButton<Content, Destination>
typealias NavigationContainer<Content: View> = NavigationKit.NavigationContainer<Content, Destination>
