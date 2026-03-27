//
//  ChannelRowComponent.swift
//  SocialNetwork
//
//  Created by Tien on 13/3/26.
//
import SwiftUI

struct ChannelRowView: View {
    let channel: ChannelModel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Avatar
                Text(channel.avatar ?? "💬")
                    .font(.system(size: 32))
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(25)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(channel.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if let time = channel.lastMessageTime {
                            Text(formatTime(time))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text(channel.lastMessage ?? "No messages")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Unread badge
                if channel.unreadCount > 0 {
                    Text("\(channel.unreadCount)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(10)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .day]
        formatter.unitsStyle = .abbreviated
        
        return formatter.string(from: date, to: Date()) ?? ""
    }
}

#Preview {
    ChannelRowView(
        channel: ChannelModel(
            id: "1",
            name: "General",
            avatar: "👥",
            lastMessage: "Hello everyone!",
            unreadCount: 2,
            lastMessageTime: Date()
        ),
        isSelected: false,
        onTap: {}
    )
}
