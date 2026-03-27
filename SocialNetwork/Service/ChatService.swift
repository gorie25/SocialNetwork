//
//  ChatService.swift
//  SocialNetwork
//
//  Created by Tien on 17/3/26.
//
import Foundation
import StreamChat
import Combine
import SwiftUI

class ChatService {
    private let chatClient: ChatClient
    private var channelController: ChatChannelController?
    private var channelListController: ChatChannelListController?
    
    static let shared = ChatService()
    
    //init
    private init() {
        var config = ChatClientConfig(apiKey: .init("pbuqqsfrcybs"))
        config.isLocalStorageEnabled = true
        self.chatClient = ChatClient(config: config)
    }
    
    func connect() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            
            do {
                let token = try Token(rawValue: AppConfig.streamUserToken)
                
                chatClient.connectUser(
                    userInfo: .init(
                        id: AppConfig.streamUserId,
                        name: "Luke Skywalker",
                        imageURL: URL(string: "https://vignette.wikia.nocookie.net/starwars/images/2/20/LukeTLJ.jpg")!
                    ),
                    token: token
                ) { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
                
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    //Chat Channel List
    func setupChannelList() {
        let query = ChannelListQuery(
            filter: .containMembers(userIds: [chatClient.currentUserId ?? ""]),
            sort: [Sorting(key: .lastMessageAt, isAscending: false)],
            pageSize: 20
        )
        channelListController = chatClient.channelListController(query: query)
    }
    
    func loadChannels() async throws -> [ChannelModel] {
        return try await withCheckedThrowingContinuation { continuation in
            channelListController?.synchronize { [weak self] error in
                guard let self else {
                    continuation.resume(returning: [])
                    return
                }
                
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let channels = self.channelListController?.channels.map { channel in
                    ChannelModel(
                        id: channel.cid.description,
                        name: channel.name ?? "Unknown",
                        avatar: nil,
                        lastMessage: channel.latestMessages.first?.text ?? "No messages",
                        unreadCount: Int(channel.unreadCount.messages),
                        lastMessageTime: channel.lastMessageAt ?? channel.createdAt
                    )
                } ?? []
                
                continuation.resume(returning: channels)
            }
        }
    }
    
    
    
    //Chat Detail
    func loadMessages(for channel: ChannelModel) async throws -> [Message] {
        let channelId = ChannelId(type: .messaging, id: channel.id)
        channelController = chatClient.channelController(for: channelId)
        
        return try await withCheckedThrowingContinuation { continuation in
            channelController?.synchronize { [weak self] error in
                guard let self else {
                    continuation.resume(returning: [])
                    return
                }
                
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let messages = self.channelController?.messages.map { msg -> Message in
                    // Map reactions
                    var reactions: [ReactionType: Int] = [:]
                    msg.reactionScores.forEach { key, value in
                        if let type = ReactionType.from(key) {
                            reactions[type] = value
                        }
                    }
                    
                    // Map current user reactions
                    let currentUserReactions = Set(msg.currentUserReactions
                        .compactMap { ReactionType.from($0.type) })
                    
                    return Message(
                        id: msg.id,
                        text: msg.text,
                        imageUrl: msg.imageAttachments.first?.payload.imageURL.absoluteString,
                        sender: msg.author.name ?? msg.author.id,
                        timestamp: msg.createdAt,
                        isCurrentUser: msg.isSentByCurrentUser,
                        reactions: reactions,
                        currentUserReactions: currentUserReactions
                    )
                } ?? []
                
                continuation.resume(returning: messages)
            }
        }
    }
    
    
    func sendMessage(_ text: String) async throws {
        guard let channelController else {
            throw ChatServiceError.channelNotInitialized
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            channelController.createNewMessage(text: text) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // Reaction
    func sendReaction(type: ReactionType, messageId: String) async throws {
        let controller = chatClient.messageController(
            cid: channelController?.cid ?? ChannelId(type: .messaging, id: ""),
            messageId: messageId
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            controller.addReaction(type.streamType) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func removeReaction(type: ReactionType, messageId: String) async throws {
        let controller = chatClient.messageController(
            cid: channelController?.cid ?? ChannelId(type: .messaging, id: ""),
            messageId: messageId
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            controller.deleteReaction(type.streamType) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    // MARK: - Upload Image
    private func saveImageToTemp(_ data: Data) -> URL {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")
        try? data.write(to: tempURL)
        return tempURL
    }
    
    func sendImage(image: UIImage) async throws {
        guard let channelController else {
            throw ChatServiceError.channelNotInitialized
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ChatServiceError.invalidImage
        }
        
        ///Get local file Url
        let tempURL = saveImageToTemp(imageData)
        
        
        let attachment = try AnyAttachmentPayload(
            localFileURL: tempURL,
            attachmentType: .image
        )
        
        try await withCheckedThrowingContinuation { continuation in
            channelController.createNewMessage(
                text: "",
                attachments: [attachment],
            ) { result in
                switch result {
                case .success: continuation.resume()
                case .failure(let error): continuation.resume(throwing: error)
                }
            }
        }
    }
    
}

enum ChatServiceError: LocalizedError {
    case channelNotInitialized
    case invalidImage
    
    var errorDescription: String? {
        switch self {
        case .channelNotInitialized:
            return "Channel chưa được khởi tạo. Hãy gọi loadMessages trước."
        case .invalidImage:
            return "Lỗi khi chọn ảnh"
        }
    }
}

