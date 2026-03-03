import SwiftUI
import TinyStorage
import CoreLocation

struct SettingsSheet: View {
	@TinyStorageItem(.transportMethod)
	var transportMethod: TransportMethod = .walking

	@Environment(\.dismiss) var dismiss

	var appVersion: String {
		let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
		let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

		return "\(version) (\(build))"
	}

	var body: some View {
		Form {
			Section {
				HStack {
					VStack(alignment: .leading) {
						Text("Transport Method")
							.font(.callout)
							.fontWeight(.medium)

						Text("Used when navigating with Apple Maps")
							.font(.caption)
							.foregroundStyle(.secondary)
					}

					Spacer()

					Menu {
						Picker(selection: $transportMethod) {
							ForEach(TransportMethod.allCases, id: \.rawValue) { method in
								Label(method.rawValue.capitalized, systemImage: method.icon)
									.imageScale(.small)
									.tag(method)
							}
						} label: {
							Text("Transport Method")
						}
					} label: {
						Text(transportMethod.rawValue.capitalized)
							.font(.callout)
							.foregroundStyle(.secondary)

						Image(systemName: "chevron.up.chevron.down")
							.imageScale(.small)
							.foregroundStyle(.secondary)
					}
					.foregroundStyle(.primary)
				}
			}
			.listSectionSpacing(20)

			VStack {
				Text("PayphoneGo \(appVersion)")
				Text("A game by Riley Waltz")
			}
			.font(.footnote)
			.foregroundStyle(.secondary)
			.frame(maxWidth: .infinity)
			.listRowBackground(Color.clear)
		}
		.padding(.top, -30)
		.listStyle(.insetGrouped)
		.navigationTitle("Settings")
		.navigationBarTitleDisplayMode(.inline)
	}
}

#Preview {
	@Previewable @State var showing = true

	VStack {}
		.sheet(isPresented: $showing) {
			NavigationStack {
				Destination.Sheets.settings.content
			}
			.presentationDetents([.medium, .large])
		}
		.withPreviewData()
}
