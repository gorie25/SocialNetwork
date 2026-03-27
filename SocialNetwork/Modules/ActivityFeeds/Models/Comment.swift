import StreamFeeds
import Foundation

struct Comment: Identifiable, Equatable, Sendable {
    let id: String
    let text: String
    let userId: String
    let userName: String
    let userAvatar: String?
    let createdAt: Date
    let parentId: String?
    var ownReactions: [FeedsReactionData]
}

extension Comment {
    init(from item: CommentData) {
        self.init(
            id: item.id,
            text: item.text ?? "",
            userId: item.user.id,
            userName: item.user.name ?? "Unknown",
            userAvatar: item.user.imageURL?.absoluteString,
            createdAt: item.createdAt,
            parentId: item.parentId,
            ownReactions: item.ownReactions
        )
    }
    
    init(from item: ThreadedCommentData) {
           self.init(
               id: item.id,
               text: item.text ?? "",
               userId: item.user.id,
               userName: item.user.name ?? "Unknown",
               userAvatar: item.user.imageURL?.absoluteString,
               createdAt: item.createdAt,
               parentId: item.parentId,
               ownReactions: item.ownReactions
           )
       }
}
