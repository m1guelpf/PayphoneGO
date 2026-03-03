import SwiftUI
import AVFoundation

struct ClaimRow: View {
	var claim: Claim

	@State private var player: AVPlayer?

	private var isPlaying: Bool {
		guard let player else { return false }
		return player.timeControlStatus == .playing
	}

	var body: some View {
		HStack {
			VStack(alignment: .leading, spacing: 6) {
				Text(claim.displayName)
					.font(.headline.weight(.medium))

				Text(claim.claimedAt, format: .dateTime.year().month().day().hour().minute())
					.font(.caption)
					.foregroundStyle(.secondary)
			}

			if let player {
				Spacer()

				if player.currentItem?.status == .readyToPlay {
					Button(action: togglePlayback) {
						Image(systemName: isPlaying ? "pause.fill" : "play.fill")
					}
				} else {
					ProgressView()
				}
			}
		}
		.onDisappear {
			guard isPlaying else { return }

			player?.pause()
		}
		.task {
			guard let url = claim.voicemailUrl else { return }

			player = AVPlayer(url: url)
		}
	}

	func togglePlayback() {
		guard let player else { return }

		if isPlaying { player.pause() }
		else { player.play() }
	}
}

#Preview {
	List {
		ClaimRow(claim: .sampleData)
	}
	.safeAreaPadding()
}
