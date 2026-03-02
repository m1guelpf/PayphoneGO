import SwiftUI
import ObfuscateMacro

public extension View {
	func fullyGlassSheet() -> some View {
		modifier(FullyGlassSheetModifier())
	}
}

fileprivate struct FullyGlassSheetModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.background(SetLargeBackgroundOnSheet())
	}
}

extension UISheetPresentationController {
	func _setLargeBackground(_ view: _UIViewGlass) {
		let selector = NSSelectorFromString(#ObfuscatedString("_setLargeBackground:"))
		if responds(to: selector) {
			perform(selector, with: view)
		}
	}
}

fileprivate struct SetLargeBackgroundOnSheet: UIViewControllerRepresentable {
	@MainActor final class DummyViewController: UIViewController {
		override func viewDidLoad() {
			super.viewDidLoad()
			view.backgroundColor = .clear
			view.isUserInteractionEnabled = false
		}

		override func didMove(toParent parent: UIViewController?) {
			super.didMove(toParent: parent)
			guard let parent, let sheetController = sheetPresentationController, let glass = _UIViewGlass(variant: 0) else { return }

			glass.flexible = true

			sheetController._setLargeBackground(glass)
		}
	}

	func makeUIViewController(context _: Context) -> DummyViewController {
		DummyViewController()
	}

	func updateUIViewController(_: DummyViewController, context _: Context) {}
}
