import MapKit
import SwiftUI
import ButtonKit
import Algorithms
import TinyStorage
import Dependencies

fileprivate let collapsedDetent: PresentationDetent = .height(80)

struct MainScreen: View {
	@Dependency(\.api) var api
	@Environment(LocationManager.self) var locationManager

	@State private var selectedPhoneId: Phone.ID? = nil
	@TinyStorageItem(.cachedPhones) private var phones: [Phone]? = nil

	@State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
	@State private var sheetPosition: PresentationDetent = collapsedDetent

	var selectedPhoneBinding: Binding<Phone>? {
		guard let phones = Binding($phones), let selectedPhoneId else { return nil }

		return phones.first(where: { $0.id == selectedPhoneId })
	}

	var selectedPhone: Phone? {
		get {
			selectedPhoneBinding?.wrappedValue
		} set {
			if let newValue { selectedPhoneBinding?.wrappedValue = newValue }
			else { selectedPhoneId = nil }
		}
	}

	var body: some View {
		map
			.navigationTitle("PayphoneGo")
			.navigationSubtitle("Gotta call 'em all!")
			.toolbarTitleDisplayMode(.inlineLarge)
			.task { await fetchPhones() }
			.onAppear { locationManager.requestAuthorization() }
			.onChange(of: locationManager.location) { _, location in
				if location != nil, position.camera != nil {
					position = .userLocation(fallback: position)
				}
			}
			.toolbar {
				ToolbarItem {
					NavigationButton(sheet: .leaderboard) {
						Label("Leaderboard", systemImage: "trophy")

					}
				}

				ToolbarSpacer(.fixed)

				ToolbarItem {
					NavigationButton(sheet: .settings) {
						Label("Settings", systemImage: "gear")

					}
				}
			}
			.overlay(alignment: .bottom) {
				if selectedPhoneId == nil {
					Button(action: navigateToClosest) {
						Label("Navigate to closest", systemImage: "location.fill")
							.font(.headline.weight(.medium))
							.padding(.horizontal, 20)
							.padding(.vertical, 12)
					}
					.glassEffect(.regular)
					.offset(y: -30)
				}
			}
			.sheet(isPresented: Binding($selectedPhoneId)) {
				NavigationStack {
					PhoneDetailSheet(phone: selectedPhone!)
						.environment(\.selectedPhone, selectedPhoneBinding)
				}
				.presentationDetents([collapsedDetent, .medium, .large], selection: $sheetPosition)
				.presentationBackgroundInteraction(.enabled(upThrough: .medium))
				.fullyGlassSheet()
			}
			.onChange(of: selectedPhone) { _, phone in
				guard let phone else { return }

				withAnimation {
					sheetPosition = phone.claimCount > 0 ? .medium : collapsedDetent
					position = .item(.init(location: CLLocation(latitude: phone.lat - 0.001, longitude: phone.lng), address: phone.address))
				}
			}
	}

	var map: some View {
		Map(
			position: $position,
			selection: $selectedPhoneId.animation()
		) {
			UserAnnotation()

			if let phones = phones?.uniqued(on: \.rawAddress) {
				ForEach(phones) { phone in
					Marker(phone.rawAddress, systemImage: "teletype", coordinate: phone.coordinate)
						.tag(phone.id)
						.tint(phone.claimCount == 0 ? .red : .gray)
				}
			}
		}
		.mapStyle(.standard(elevation: .realistic))
		.mapControls {
			if locationManager.location != nil {
				MapUserLocationButton()
			}

			MapCompass()
			MapScaleView()
		}
	}

	func navigateToClosest() {
		guard let location = locationManager.location, let phones,
		      let closestPhone = phones.min(by: { $0.location.distance(from: location) < $1.location.distance(from: location) }) else { return }

		closestPhone.navigate()
	}

	func fetchPhones() async {
		do {
			phones = try await api.phones()
		} catch {
			api.logger.error("Failed to get phones: \(error)")
		}
	}
}

#Preview {
	MainScreen()
		.withPreviewData()
}
