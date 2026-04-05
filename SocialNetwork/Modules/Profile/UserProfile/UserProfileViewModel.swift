import Combine
import Foundation


@MainActor
class UserProfileViewModel:ObservableObject{
    private let chatService = ChatService.shared
    private let feedService = FeedService.shared
    @Published var posts: [Post] = []
    @Published var user: UserModel?
    
    let userId: String
    
    
    init(userId: String)
    {   self.userId = userId
        Task {
            await loadUser()
            await loadProfile()
        }
    }
    
    func loadProfile() async
    {
        do {
            posts =  try await feedService.loadMyPosts()
        } catch
        {
            ToastManager.shared.show(error.localizedDescription)
        }
    }
    
    func loadUser() async
    {
        do {
            user =  try await chatService.getUser(
                id:userId
            )
        } catch
        {
            ToastManager.shared.show(error.localizedDescription)
            
        }
    }
    
    
}
