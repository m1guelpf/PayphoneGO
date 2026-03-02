import SwiftUI

@propertyWrapper
struct Animated<Value>: DynamicProperty {
	private let animation: Animation?

	@State private var value: Value

	init(wrappedValue: Value, _ animation: Animation? = .default) {
		value = wrappedValue
		self.animation = animation
	}

	var wrappedValue: Value {
		get { value }
		nonmutating set {
			withAnimation(animation) {
				value = newValue
			}
		}
	}

	var projectedValue: Binding<Value> { $value.animation(animation) }
}
