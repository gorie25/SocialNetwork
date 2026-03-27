import SwiftUI
import StreamChat
import Foundation

@main
struct SocialNetworkApp: App {
    
    @State private var isReady = false
    @State private var error: String?
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isReady {
                    RootView()
                        .toastManager()
                } else {
                    VStack {
                        ProgressView("Connecting...")
                        if let error {
                            Text("Error: \(error)")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .task {
                await setup()
            }
        }
    }
    
    // MARK: - Setup
    private func setup() async {
        do {
            print("Setting up Services")
            try await FeedService.shared.connect()
            try await ChatService.shared.connect()
            isReady = true
            
        } catch {
            self.error = error.localizedDescription
        }
    }
}
