import MapKit

enum TransportMethod: String, CaseIterable, Equatable, Hashable, Codable {
	case car
	case walking
	case biking
	case transit

	var icon: String {
		switch self {
			case .car: "car.fill"
			case .biking: "bicycle"
			case .transit: "tram.fill"
			case .walking: "figure.walk"
		}
	}

	var toPreferenceKey: String {
		switch self {
			case .car: MKLaunchOptionsDirectionsModeDriving
			case .biking: MKLaunchOptionsDirectionsModeCycling
			case .transit: MKLaunchOptionsDirectionsModeTransit
			case .walking: MKLaunchOptionsDirectionsModeWalking
		}
	}
}
