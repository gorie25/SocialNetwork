
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
    

    
}
