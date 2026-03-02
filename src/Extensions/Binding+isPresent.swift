import SwiftUI

public extension Binding {
	init<V>(_ base: Binding<V?>) where Value == Bool {
		self = base._isPresent
	}
}

fileprivate extension Optional {
	var _isPresent: Bool {
		get { self != nil }
		set {
			guard !newValue else { return }
			self = nil
		}
	}
}
