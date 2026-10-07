import SwiftUI

@main
struct MoleApp: App {
    var body: some Scene {
        WindowGroup("Mole") {
            MoleRootView()
                .frame(
                    minWidth: MoleTokens.minWindowWidth,
                    minHeight: MoleTokens.minWindowHeight
                )
        }
        .defaultSize(width: MoleTokens.windowWidth, height: MoleTokens.windowHeight)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
    }
}
