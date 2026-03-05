//
//  ReactionType.swift
//  SocialNetwork
//
//  Created by Tien on 17/3/26.
//
import Foundation
import StreamChat

enum ReactionType: String, CaseIterable {
    case like    = "like"
    case love    = "love"
    case haha    = "haha"
    case wow     = "wow"
    case sad     = "sad"
    case angry   = "angry"
    
    // Hiện emoji tương ứng trong UI
    var emoji: String {
        switch self {
        case .like:  return "👍"
        case .love:  return "❤️"
        case .haha:  return "😂"
        case .wow:   return "😮"
        case .sad:   return "😢"
        case .angry: return "😡"
        }
    }
    
    // Convert sang GetStream type
    var streamType: MessageReactionType {
        return .init(rawValue: self.rawValue)
    }
    
    // Convert từ GetStream type về enum
    static func from(_ streamType: MessageReactionType) -> ReactionType? {
        return ReactionType(rawValue: streamType.rawValue)
    }
}
