import StreamFeeds
import Foundation
import Combine

@MainActor
class FeedService: ObservableObject {
    
    static let shared = FeedService()
    
    private let client: FeedsClient
    private var isSetupDone = false
    
    // 2 feed chính
    private(set) var userFeed: Feed?
    private(set) var timelineFeed: Feed?
    
    private init() {
        self.client = FeedsClient(
            apiKey: APIKey(AppConfig.streamApiKey),
            user: User(
                id: AppConfig.streamUserId,
                name: "Luke Skywalker",
                imageURL: URL(string: "https://vignette.wikia.nocookie.net/starwars/images/2/20/LukeTLJ.jpg")!
            ),
            token: UserToken(
                rawValue: AppConfig.streamUserToken
            )
        )
    }
    
    
    private func ensureSetup() async throws {
        guard !isSetupDone else {
            print("✅ [FeedService] Feed đã được khởi tạo, bỏ qua setup")
            return
        }
        try await client.connect()
        
        let userId = client.user.id
        userFeed     = client.feed(group: "user",     id: userId)
        timelineFeed = client.feed(group: "timeline", id: userId)
        
        
        try await userFeed?.getOrCreate()
        try await timelineFeed?.getOrCreate()
        
        isSetupDone = true
        print("✅ [FeedService] Setup hoàn tất!")
    }
    
    
    // MARK: - Load My Posts
    func loadMyPosts() async throws -> [Post] {
        try await ensureSetup()
        
        let query = FeedQuery(
            group: "user",
            id: client.user.id,
            activityLimit: 20
        )
        
        let feed = client.feed(for: query)
        try await feed.getOrCreate()
        
        let activities = feed.state.activities
        
        print("✅ [FeedService] Load xong \(activities.count) bài của mình")
        
        let posts: [Post] = activities.map { activity in
            
            let likeCount = activity.reactionGroups["like"]?.count ?? 0
            
            return Post(
                id: activity.id,
                text: activity.text,
                attachments: activity.attachments,
                createdAt: activity.createdAt,
                updatedAt: activity.editedAt,
                likeCount: likeCount,
                commentCount: activity.commentCount,
                shareCount: activity.shareCount
            )
        }
        
        return posts
    }
    
    // MARK: - Get Current User
    func getCurrentUser() async throws -> UserModel {
        try await ensureSetup()
        
        let streamUser = client.user
        
        let bio: String? = {
            if let raw = streamUser.customData["bio"] {
                return raw.stringValue
            }
            return nil
        }()
        
        let user = UserModel(
            id: streamUser.id,
            name: streamUser.name ?? "",
            imageURL: streamUser.imageURL?.absoluteString,
            originalName: streamUser.originalName ?? "",
            
        )
        
        return user
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
