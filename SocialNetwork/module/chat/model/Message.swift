//
//  Message.swift
//  SocialNetwork
//
//  Created by Tien on 15/3/26.
//
import Foundation

struct Message: Identifiable {
    let id: String
    let text: String
    let imageUrl: String? 
    let sender: String
    let timestamp: Date
    let isCurrentUser: Bool
    var reactions: [ReactionType: Int] = [:]
    var currentUserReactions: Set<ReactionType> = []
}
