import MapKit
import Foundation

@MainActor @Observable
final class LocationManager {
	let manager = CLLocationManager()

	var location: CLLocation? {
		manager.location
	}

	func requestAuthorization() {
		manager.requestWhenInUseAuthorization()
	}
}
