import MapKit

extension MKCoordinateRegion {
	func contains(_ c: CLLocationCoordinate2D) -> Bool {
		let halfLat = span.latitudeDelta / 2
		let halfLon = span.longitudeDelta / 2

		return (center.latitude - halfLat)...(center.latitude + halfLat) ~= c.latitude &&
			(center.longitude - halfLon)...(center.longitude + halfLon) ~= c.longitude
	}
}
