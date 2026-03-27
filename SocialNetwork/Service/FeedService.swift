import StreamFeeds
import Foundation

actor FeedService {
    
    static let shared = FeedService()
    
    private let client: FeedsClient
    
    private(set) var userFeed: Feed?
    private(set) var timelineFeed: Feed?
    
    private var connectTask: Task<Void, Error>?
    
    private init() {
        self.client = FeedsClient(
            apiKey: APIKey(AppConfig.streamApiKey),
            user: User(
                id: AppConfig.streamUserId,
                name: "Kaka",
                imageURL: URL(string: "https://vignette.wikia.nocookie.net/starwars/images/2/20/LukeTLJ.jpg")!
            ),
            token: UserToken(rawValue: AppConfig.streamUserToken)
        )
    }
    
    // MARK: - CONNECT
    func connect() async throws {
        if let existing = connectTask {
            try await existing.value
            return
        }
        
        let task = Task<Void, Error> {
            try await client.connect()
            let userId = client.user.id
            userFeed     = client.feed(group: "user", id: userId)
            timelineFeed = client.feed(group: "timeline", id: userId)
            try await userFeed?.getOrCreate()
            try await timelineFeed?.getOrCreate()
        }
        
        connectTask = task
        do {
            try await task.value
        } catch {
            connectTask = nil
            throw error
        }
    }
    
    // MARK: - LOAD MY POSTS
    func loadMyPosts() async throws -> [Post] {
        let query = FeedQuery(group: "user", id: client.user.id, activityLimit: 20)
        let feed = client.feed(for: query)
        try await feed.getOrCreate()
        let activities = await feed.state.activities
        return activities.map { Post(from: $0) } // ✅
    }
    
    // MARK: - GET CURRENT USER
    func getCurrentUser() async throws -> UserModel {
        let streamUser = client.user
        return UserModel(
            id: streamUser.id,
            name: streamUser.name,
            imageURL: streamUser.imageURL?.absoluteString,
            originalName: streamUser.originalName ?? ""
        )
    }
    
    // MARK: - CREATE POST
    func createPost(text: String) async throws -> Post {
        guard let userFeed else { throw FeedError.notInitialized }
        let created = try await userFeed.addActivity(
            request: .init(
                text: text.trimmingCharacters(in: .whitespacesAndNewlines),
                type: "post"
            )
        )
        return Post(from: created)
    }
    
    // MARK: - LOAD TIMELINE
    func loadTimeline() async throws -> [Post] {
        guard let timelineFeed else { throw FeedError.notInitialized }
        try await timelineFeed.getOrCreate()
        let activities = await timelineFeed.state.activities
        return activities.map { Post(from: $0) }
    }
    
    // MARK: - FOLLOW USER
    func followUser(targetUserId: String) async throws {
        guard let timelineFeed else { throw FeedError.notInitialized }
        try await timelineFeed.follow(FeedId(group: "user", id: targetUserId))
    }
    
    // MARK: - REACT POST
    @discardableResult
    func reactPost(activityId: String, reactionType: String) async throws -> Bool {
        guard let userFeed else { throw FeedError.notInitialized }
        let activities = await userFeed.state.activities
        let alreadyReacted = activities.first { $0.id == activityId }?.ownReactions.contains { $0.type == reactionType } ?? false
        
        if alreadyReacted {
            _ = try await userFeed.deleteReaction(activityId: activityId, type: reactionType)
            return false
        } else {
            _ = try await userFeed.addReaction(activityId: activityId, request: .init(type: reactionType))
            return true
        }
    }
    
    // MARK: - ADD COMMENT
    func addComment(activityId: String, text: String) async throws -> Comment {
        guard let userFeed else { throw FeedError.notInitialized }
        let result = try await userFeed.addComment(
            request: .init(comment: text, objectId: activityId, objectType: "activity")
        )
        return await Comment(from: result)
    }
    
    // MARK: - LOAD COMMENTS
    func loadComments(activityId: String) async throws -> [Comment] {
        let commentList = client.activityCommentList(
            for: .init(objectId: activityId, objectType: "activity", depth: 1, limit: 20)
        )
        let results = try await commentList.get()
        return results.map { Comment(from: $0) }
    }
    
    // MARK: - ADD REPLY
    func addReply(parentCommentId: String, activityId: String, text: String) async throws -> Comment {
        guard let userFeed else { throw FeedError.notInitialized }
        let result = try await userFeed.addComment(
            request: .init(comment: text, objectId: activityId, objectType: "activity", parentId: parentCommentId)
        )
        return await Comment(from: result)
    }
    
    // MARK: - DELETE COMMENT
    func deleteComment(commentId: String) async throws {
        guard let userFeed else { throw FeedError.notInitialized }
        try await userFeed.deleteComment(commentId: commentId)
    }
}

// MARK: - Error
enum FeedError: LocalizedError {
    case notInitialized
    var errorDescription: String? {
        switch self {
        case .notInitialized: return "Feed chưa được khởi tạo"
        }
    }
}
