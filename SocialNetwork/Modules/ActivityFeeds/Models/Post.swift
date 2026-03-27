
import Foundation
import CoreLocation
import StreamFeeds

struct Post: Identifiable, Equatable, Sendable {
    
    let id: String
    let text: String?
    let attachments: [Attachment]
    let createdAt: Date
    let updatedAt: Date?
    var likeCount: Int
    var commentCount: Int
    var shareCount: Int
    var ownReaction: String?
    
    //Relation
    var comments: [Comment]
}

extension Post {
    init(from activity: ActivityData) {
        self.init(
            id: activity.id,
            text: activity.text,
            attachments: activity.attachments,
            createdAt: activity.createdAt,
            updatedAt: activity.editedAt,
            likeCount: activity.reactionGroups["like"]?.count ?? 0,
            commentCount: activity.reactionGroups["comment"]?.count ?? 0,
            shareCount: activity.shareCount,
            ownReaction: activity.ownReactions.first?.type,
            comments: activity.comments.map { Comment(from: $0) }
        )
    }
}
