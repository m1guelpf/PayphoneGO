import MapKit

extension MKCoordinateRegion {
	static var california: MKCoordinateRegion {
		MKCoordinateRegion(
			center: CLLocationCoordinate2D(latitude: 38.72527, longitude: -9.15000),
			latitudinalMeters: 25000,
			longitudinalMeters: 25000
		)
	}
}
