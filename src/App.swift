import SwiftUI
import AVFoundation

#if DEBUG
import Pulse
import Atlantis
import PulseProxy
#endif

@main
struct PayphoneGoApp: App {
	init() {
		#if DEBUG
		Atlantis.start(hostName: "supernova.local.")
		NetworkLogger.enableProxy()
		#endif

		AVPlayer.isObservationEnabled = true
	}

	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}
