import SwiftUI
import Foundation
import TinyStorage
import Dependencies
import DependenciesMacros

@MainActor @Observable
final class AppData {
	var isReady = false

	func load() async {
		isReady = true

		// run on startup
	}

	func foreground() async {
		// run on foreground
	}

	func background() async {
		// run on app background
	}
}

extension AppData: DependencyKey {
	static let liveValue = AppData()
}

extension DependencyValues {
	var appData: AppData {
		get { self[AppData.self] }
		set { self[AppData.self] = newValue }
	}
}
