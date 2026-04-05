import Foundation
import OSLog
import Combine
import SwiftUI

class ChatDetailViewModel: NSObject, ObservableObject {
    let log = Logger(subsystem: "com.yourapp.SocialNetwork", category: "general")
    private let chatService = ChatService.shared
    private let channel: ChannelModel
    @Published var messages: [Message] = []
    @Published var errorMessage: String?
    
    init(channel: ChannelModel) {
        self.channel = channel
        super.init()
    }
    
    func loadMessages() async {
        log.info("Starting load")
       
        do {
            let result = try await chatService.loadMessages(for: channel)
            await MainActor.run { messages = result }
            print("📨 Số message: \(messages.count)")
            print("📢 Channel ID: \(channel.id)")
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }

        }
    }
    

    func sendMessage(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
               
               do {
                   try await chatService.sendMessage(text)
                   await loadMessages()
               } catch {
                   log.error("Send message failed: \(error)")
                   await MainActor.run { errorMessage = error.localizedDescription }
               }
           }
    
    
    func sendReaction(type: ReactionType, messageId: String) async {
        do {
            try await chatService.sendReaction(type: type, messageId: messageId)
            await loadMessages()
        } catch
        {
            log.error("Send reaction failed: \(error)")
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }
    
    
    func removeReaction(type: ReactionType, messageId: String) async {
        do {
            try await chatService.removeReaction(type: type, messageId: messageId)
            await loadMessages()
        } catch {
            log.error("Remove reaction failed: \(error)")
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }
    
    func sendImage(image: UIImage) async {
        do {
            print("Try to send Image")
            try await chatService.sendImage(image: image)
            print("Send success")
            await loadMessages()
        } catch {
            log.error("Send image failed: \(error)")
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }
    
}

