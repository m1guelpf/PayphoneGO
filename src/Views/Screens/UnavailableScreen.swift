import SwiftUI

struct UnavailableScreen: View {
	var title: String? = nil

	var body: some View {
		ContentUnavailableView {
			Label("Nothing to see here... yet", systemImage: "bolt.horizontal")
		} description: {
			Text("I haven't quite had time to add support for this page yet. Hopefully soon!")
				.offset(y: 10)
		}
		.if(title != nil) { $0.navigationTitle(title!) }
	}
}

#Preview {
	UnavailableScreen()
		.withPreviewData()
}
