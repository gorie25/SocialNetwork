import Combine
import Foundation

class ProfileViewModel:ObservableObject{
    private let feedService = FeedService.shared
    @Published var posts: [Post] = []
    @Published var user: UserModel?
    
    
    init()
    {
        Task {
            await loadCurrentUser()
            await loadProfile()
        }
    }
    
    func loadProfile() async
    {
        do {
            try posts = await feedService.loadMyPosts()
        } catch
        {
            ToastManager.shared.show(error.localizedDescription)
        }
    }
    
    func loadCurrentUser() async
    {
        do {
            try user = await feedService.getCurrentUser()
        } catch
        {
            ToastManager.shared.show(error.localizedDescription)

        }
    }
}
