import SwiftUI
import CoreLocation
import Dependencies

struct PhoneDetailSheet: View {
	var phone: Phone

	@State private var details: API.PhoneDetails? = nil

	@Dependency(\.api) var api
	@Environment(\.selectedPhone) var selectedPhone
	@Environment(LocationManager.self) var locationManager

	var distanceUnit: UnitLength {
		switch Locale.current.measurementSystem {
			case .metric: .meters
			case .us, .uk: .miles
			default: .miles
		}
	}

	var body: some View {
		List {
			if phone.claimCount == 0 {
				ContentUnavailableView("Unclaimed", systemImage: "phone.down", description: Text("Maybe you could be the first?"))
					.listRowInsets(.all, 0)
					.listRowSeparator(.hidden)
			} else if let details {
				ForEach(details.claims.enumerated(), id: \.element.claimOrder) { i, claim in
					VStack(alignment: .leading, spacing: 6) {
						Text(claim.displayName)
							.font(.headline.weight(.medium))

						Text(claim.claimedAt, format: .dateTime.year().month().day().hour().minute())
							.font(.caption)
							.foregroundStyle(.secondary)
					}
					.listRowInsets(.horizontal, 0)
					.listRowSeparator(i == 0 ? .hidden : .visible, edges: .top)
					.overlay(alignment: .topLeading) {
						if i == 0 {
							Text("\(phone.claimCount) Claim\(phone.claimCount == 1 ? "" : "s")")
								.font(.headline.weight(.medium).smallCaps())
								.foregroundStyle(.secondary)
								.frame(maxWidth: .infinity, alignment: .leading)
								.offset(y: -25)
						}
					}
				}

			} else {
				ProgressView()
					.frame(maxWidth: .infinity, alignment: .center)
					.listRowInsets(.all, 0)
					.listRowSeparator(.hidden)
			}
		}
		.listStyle(.plain)
		.safeAreaPadding()
		.toolbarTitleDisplayMode(.inlineLarge)
		.toolbar {
			ToolbarItem(placement: .title) {
				ZStack(alignment: .topLeading) {
					Text("AAAAAAAAAAAAAAAAAAAAA")
						.font(.title2.weight(.bold))
						.lineLimit(1)
						.hidden()

					Text(phone.rawAddress)
						.font(.title2.weight(.bold))
						.lineLimit(1)
				}
			}

			ToolbarItem(placement: .subtitle) {
				HStack {
					Text("\(phone.city), CA \(phone.zip.formatted(.number.grouping(.never)))")
						.foregroundStyle(.secondary)
						.font(.headline.weight(.medium).smallCaps())

					if let userLocation = locationManager.location {
						let distance = Measurement(value: phone.location.distance(from: userLocation), unit: distanceUnit)

						Text(distance, format: .measurement(width: .abbreviated))
							.font(.caption2)
							.foregroundStyle(.secondary)
							.fontWeight(.semibold)
							.padding(.horizontal, 10)
							.padding(.vertical, 4)
							.glassEffect(.clear)
							.offset(y: 2)
					}
				}
			}

			ToolbarItem(placement: .primaryAction) {
				Button("Navigate", systemImage: "location.fill") {
					phone.navigate()
				}
				.buttonStyle(.glassProminent)
			}
		}
		.task(id: phone.id) { await fetchPhoneDetails() }
		.onChange(of: details?.totalClaims) { _, totalClaims in
			guard let totalClaims, let selectedPhone else { return }

			if selectedPhone.claimCount.wrappedValue != totalClaims {
				selectedPhone.claimCount.wrappedValue = totalClaims
			}
		}
	}

	func fetchPhoneDetails() async {
		do {
			let details = try await api.phone(id: phone.id)
			withAnimation { self.details = details }
		} catch {
			api.logger.error("Failed to fetch phone details for phone \(phone.id): \(error)")
		}
	}
}

#Preview {
	@Previewable @State var showing = true

	VStack {}
		.sheet(isPresented: $showing) {
			NavigationStack {
				Destination.Sheets.phoneDetail(phone: .sampleData).content
			}
			.presentationDetents([.medium, .large])
		}
		.withPreviewData()
}
