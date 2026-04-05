import Foundation
import Combine

@MainActor
class CommentViewModel: ObservableObject {
    
    
    @Published var comments: [Comment] = []
    private let feedService = FeedService.shared
    private let activityId: String
    
    init(activityId: String) {
        self.activityId = activityId
        setup()
    }
    
    
    private func setup() {
        Task {
            await loadComments()
        }
    }
    
    func loadComments() async {
        
        do {
            comments = try await feedService.loadComments(activityId: self.activityId )
        } catch {
            print("❌ Load comments failed: \(error)")
        }
    }
    
    func addComment(content: String) async {
        
        do {
            try await feedService.addComment(activityId: self.activityId, text: content)
           await loadComments()
        } catch {
            print("❌ Send comment failed \(error)")
        }
    }
    
}
