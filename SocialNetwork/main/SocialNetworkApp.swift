import SwiftUI
import StreamChat
import Foundation

@main
struct SocialNetworkApp: App {
    
    @State private var toast: ToastModel?
    
    var body: some Scene {
        WindowGroup {
            ProfileView()
                .toastManager()     
        }
    }
}
