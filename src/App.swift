import SwiftUI
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
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
