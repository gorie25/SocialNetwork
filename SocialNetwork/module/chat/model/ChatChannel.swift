//
//  ChatChannel.swift
//  SocialNetwork
//
//  Created by Tien on 13/3/26.
//

import Foundation

struct ChannelModel: Identifiable {
    let id:String
    let name: String
    let avatar: String?
    let lastMessage: String?
    let unreadCount: Int
    let lastMessageTime: Date?
}
