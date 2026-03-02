import SwiftUI

struct SkeletonModifier: ViewModifier {
	var active: Bool

	@State private var isAnimating = false
	@Environment(\.colorScheme) private var colorScheme

	var animation: Animation {
		.easeInOut(duration: 1.5).repeatForever(autoreverses: false)
	}

	func body(content: Content) -> some View {
		content
			.disabled(active)
			.selectionDisabled(active)
			.redacted(reason: active ? .placeholder : [])
			.overlay {
				if active {
					GeometryReader { geometry in
						let size = geometry.size
						let blurRadius = max(size.width / 4, 30)

						Rectangle()
							.fill(.white)
							.frame(width: size.width / 2, height: size.height * 2)
							.frame(height: size.height)
							.blur(radius: blurRadius)
							.rotationEffect(.degrees(5))
							.offset(
								x: isAnimating ? (size.width + size.width / 2 + blurRadius * 2) : -(size.width / 2 + blurRadius * 2)
							)
							.animation(animation, value: isAnimating)
					}
					.mask { content.redacted(reason: .placeholder) }
					.blendMode(.softLight)
					.onAppear { isAnimating = true }
					.onDisappear { isAnimating = false }
					.transaction { transaction in
						guard transaction.animation != animation else { return }

						transaction.animation = .none
					}
				}
			}
	}
}

extension View {
	func skeleton(isLoading: Bool) -> some View {
		modifier(SkeletonModifier(active: isLoading))
	}
}

@MainActor protocol PlaceholderAware {
	var redactionReasons: RedactionReasons { get }

	var isPlaceholder: Bool { get }
}

extension PlaceholderAware {
	var isPlaceholder: Bool {
		redactionReasons.contains(.placeholder)
	}
}

@MainActor protocol WithPlaceholder: View, PlaceholderAware {
	associatedtype Content: View
	associatedtype Placeholder: View

	@MainActor var content: Content { get }
	@MainActor var placeholder: Placeholder { get }
}

extension WithPlaceholder {
	var body: some View {
		Group {
			if isPlaceholder { placeholder }
			else { content }
		}
	}
}
