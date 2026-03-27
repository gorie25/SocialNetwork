import Combine
import Foundation


@MainActor
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
            posts =  try await feedService.loadMyPosts()
        } catch
        {
            ToastManager.shared.show(error.localizedDescription)
        }
    }
    
    func loadCurrentUser() async
    {
        do {
            user =  try await feedService.getCurrentUser()
        } catch
        {
            ToastManager.shared.show(error.localizedDescription)
            
        }
    }
    
    func createPost(content: String) async {
        do {
            try await feedService.createPost(text: content)
        } catch
        {
            ToastManager.shared.show(error.localizedDescription)
            
        }
    }
}
