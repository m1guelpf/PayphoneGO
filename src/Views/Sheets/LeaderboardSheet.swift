import SwiftUI
import CoreLocation
import Dependencies

struct LeaderboardSheet: View {
	@State private var entries: [API.LeaderboardEntry]? = nil

	@Dependency(\.api) var api

	var body: some View {
		List {
			if let entries {
				ForEach(entries.enumerated(), id: \.element.displayName) { i, entry in
					HStack(spacing: 6) {
						Text("\(i + 1).")
							.foregroundStyle(.secondary)

						Text(entry.displayName)
							.font(.headline.weight(.medium))

						Spacer()

						Text("\(entry.points)")
							.font(.headline)
					}
					.listRowInsets(.horizontal, 0)
					.listRowSeparator(i == 0 ? .hidden : .visible, edges: .top)
				}
			} else {
				ProgressView()
					.frame(maxWidth: .infinity, alignment: .center)
					.listRowInsets(.all, 0)
					.listRowSeparator(.hidden)
			}
		}
		.refreshable { await fetchLeaderboard() }
		.navigationTitle("Leaderboard")
		.listStyle(.plain)
		.safeAreaPadding()
		.navigationBarTitleDisplayMode(.inline)
		.task { await fetchLeaderboard() }
	}

	func fetchLeaderboard() async {
		do {
			let entries = try await api.leaderboard()
			withAnimation { self.entries = entries }
		} catch {
			api.logger.error("Failed to fetch leaderboard: \(error)")
		}
	}
}

#Preview {
	@Previewable @State var showing = true

	VStack {}
		.sheet(isPresented: $showing) {
			NavigationStack {
				Destination.Sheets.leaderboard.content
			}
			.presentationDetents([.medium, .large])
		}
		.withPreviewData()
}
