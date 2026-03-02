import MapKit
import SwiftUI
import PulseUI
import Dependencies

fileprivate typealias Tabs = Destination.Tabs

struct ContentView: View {
	@Environment(\.scenePhase) var scenePhase
	@Dependency(\.appData) private var appData

	@State private var locationManager = LocationManager()
	@State var router = Router(level: 0, identifierTab: nil)

	#if DEBUG
	@State private var showingPulse = false
	#endif

	var content: some View {
		NavigationContainer(parentRouter: router, tab: .home) {
			MainScreen()
		}
		.environment(locationManager)
	}

	var body: some View {
		Group {
			content
				.task { await appData.load() }
				.onChange(of: scenePhase) { _, phase in
					switch phase {
						case .active: Task { await appData.foreground() }
						case .background: Task { await appData.background() }
						default: break
					}
				}
		}
		.environment(locationManager)
		#if DEBUG
			.onShake { showingPulse.toggle() }
			.sheet(isPresented: $showingPulse) {
				NavigationStack {
					ConsoleView()
				}
			}
		#endif
	}
}

#Preview {
	ContentView()
}
