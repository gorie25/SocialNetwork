import Foundation
import StreamChat
import Combine

@MainActor
class FeedHomeViewModel: ObservableObject{
    
    @Published var posts: [Post] = []
    private let feedService = FeedService.shared
    
    init() {
        setup()
    }
    
    private func setup() {
        Task {
            await loadPosts()
        }
    }
    func refresh() async {
        await loadPosts()
        
    }
    
    func loadPosts() async {
        do {
            posts = try await feedService.loadTimeline()
        } catch {
            print("❌ Load posts failed: \(error)")
        }
    }
    
    
    func reactionPost(activityId: String, reactionType: String?) async {
        guard let reactionType else {return}
        do {
            try await feedService.reactPost(activityId: activityId, reactionType: reactionType)
            await loadPosts()
        } catch {
            print("❌ Reaction Failed: \(error)")
        }
    }
}
