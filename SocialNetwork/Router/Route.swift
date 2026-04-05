import Foundation

enum Route: Hashable {
    
    // MARK: - Chats
    case chatList
    case chatDetail(id: String)
    
    // MARK: - Profile
    case myProfile
    case userProfile(userId: String)
    
    // MARK: - Activity
    case activity
}

extension Route {
    
    var path: String {
        switch self {
        case .chatList:
            return "/chats"
            
        case .chatDetail(let id):
            return "/chats/\(id)"
            
        case .myProfile:
            return "/profile"
            
        case .userProfile(let userId):
            return "/users/\(userId)"
            
        case .activity:
            return "/activity"
        }
    }
}
