import SwiftUI
import SafariServices

struct BrowserSheet: View {
	let url: URL

	var body: some View {
		InAppBrowser(url: url)
			.edgesIgnoringSafeArea(.all)
			.transition(.opacity.animation(.easeInOut(duration: 0.2)))
	}
}

struct InAppBrowser: UIViewControllerRepresentable {
	let url: URL

	func makeUIViewController(context _: Context) -> SFSafariViewController {
		return SFSafariViewController(url: url)
	}

	func updateUIViewController(_: SFSafariViewController, context _: Context) {}
}
