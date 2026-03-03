import MapKit
import Foundation
import MetaCodable
import TinyStorage
import HelperCoders

@Codable @CodingKeys(.snake_case) struct Phone: Identifiable, Equatable, Hashable, Sendable {
	var id: Int
	@CodedBy(ValueCoder<Double>()) var lat: Double
	@CodedBy(ValueCoder<Double>()) var lng: Double
	var rawAddress: String
	var city: String
	@CodedBy(ValueCoder<Int>()) var zip: Int
	var claimCount: Int
	var phonesAtLocation: Int
	var locationPhoneIds: [Int]

	var location: CLLocation {
		CLLocation(latitude: lat, longitude: lng)
	}

	var address: MKAddress? {
		MKAddress(fullAddress: rawAddress, shortAddress: nil)
	}

	var coordinate: CLLocationCoordinate2D {
		location.coordinate
	}

	func navigate() {
		let transportMethod = TinyStorage.retrieveWithFallback(type: TransportMethod.self, forKey: .transportMethod, fallback: .walking)

		MKMapItem(location: location, address: nil).openInMaps(launchOptions: [
			MKLaunchOptionsDirectionsModeKey: transportMethod.toPreferenceKey,
		])
	}
}

extension Phone {
	static var sampleData: Phone {
		Phone(id: 1420, lat: 37.4433600, lng: -122.1650680, rawAddress: "95 UNIVERSITY AVE", city: "PALO ALTO", zip: 94301, claimCount: 1, phonesAtLocation: 1, locationPhoneIds: [1420])
	}
}
