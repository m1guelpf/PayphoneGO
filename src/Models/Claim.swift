import MapKit
import Foundation
import MetaCodable
import HelperCoders

@Codable @CodingKeys(.snake_case) struct Claim: Equatable, Hashable, Sendable {
	var claimOrder: Int
	var pointsAwarded: Int
	var claimedAt: Date
	var voicemailUrl: URL?
	var displayName: String
}

extension Claim {
	static var sampleData: Claim {
		Claim(
			claimOrder: 1,
			pointsAwarded: 20,
			claimedAt: Date(),
			voicemailUrl: URL(string: "https://stfu.nyc3.digitaloceanspaces.com/payphone-go/voicemail-4-1772420491165.mp3")!,
			displayName: "tkanarsky"
		)
	}
}
