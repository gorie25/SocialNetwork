import SwiftUI

enum AppTab: String, CaseIterable {
    
    case home = "Home"
    case history = "History"
    case chat = "Chat"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .home:    return "house"
        case .history: return "clock"
        case .chat:    return "message"
        case .profile: return "person"
        }
    }
 
    var iconSelected: String {
        switch self {
        case .home:    return "house.fill"
        case .history: return "clock.fill"
        case .chat:    return "message.fill"
        case .profile: return "person.fill"
        }
    }
}

struct RootView: View {
    @State private var  selectedTab: AppTab = .home
    
    var body: some View {
            TabView(selection: $selectedTab) {

                       FeedHomeView()
                           .tag(AppTab.home)
                           .tabItem {
                               Label("Home", systemImage: selectedTab == .home ? "house.fill" : "house")
                           }

                        CustomChannelList()
                           .tag(AppTab.chat)
                           .tabItem {
                               Label("Chat", systemImage: selectedTab == .chat ? "message.fill" : "message")
                           }

                       ProfileView()
                           .tag(AppTab.profile)
                           .tabItem {
                               Label("Profile", systemImage: selectedTab == .profile ? "person.fill" : "person")
                           }
                   }
                   .tint(.primary)
                   .tableStyle(.automatic)               
        }
    }
    



