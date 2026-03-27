//
//  ChatDetailView.swift
//  SocialNetwork
//
//  Created by Tien on 13/3/26.
//

import SwiftUI

struct ChannelDetailView: View {
    let channel: ChannelModel
    
    @State private var messageText = ""
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @StateObject private var viewModel: ChatDetailViewModel
    
    init(channel: ChannelModel) {
        self.channel = channel
        _viewModel = StateObject(
            wrappedValue: ChatDetailViewModel(channel: channel)
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            HStack {
                Text(channel.avatar ?? "💬")
                    .font(.system(size: 24))
                
                VStack(alignment: .leading) {
                    Text(channel.name)
                        .font(.headline)
                    Text("Online")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Button(action: {
                    print("Info button tapped — channel: \(channel.name)")
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
            
            // Messages
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message) { reactionType in
                            Task {
                                if message.currentUserReactions.contains(reactionType) {
                                    await viewModel.removeReaction(
                                        type: reactionType,
                                        messageId: message.id
                                    )
                                } else {
                                    await viewModel.sendReaction(
                                        type: reactionType,
                                        messageId: message.id
                                    )
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            }
            
            Divider()
            
            // Input
            HStack(spacing: 12) {
                Button(action: {
                    showImagePicker = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                }
                
                TextField("Message", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: {
                    Task {
                        await viewModel.sendMessage(messageText)
                        messageText = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                }
                .disabled(messageText.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        } .sheet(isPresented: $showImagePicker)
        {
            ImagePicker(image: $selectedImage).onDisappear {
                if let image = selectedImage {
                    Task{
                        await viewModel.sendImage(image: image)
                    }
                }
            }
        }
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .onAppear {
            Task {
                print("ChannelDetailView appeared — \(channel.name)")
                await viewModel.loadMessages()
            }
        }
        .onDisappear {
            print("ChannelDetailView disappeared — \(channel.name)")
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: Message
    var onReact: ((ReactionType) -> Void)?
    
    @State private var showReactionPicker = false
    
    var body: some View {
        ZStack(alignment: message.isCurrentUser ? .topTrailing : .topLeading) {
            
            VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 4) {
                
                // Message text bubble
                HStack {
                    if message.isCurrentUser { Spacer() }
                    
                    if let imageUrl = message.imageUrl, let url = URL(string: imageUrl)
                    {
                        AsyncImage(url: url) {
                            phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 200, height: 150)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 200)
                                    .cornerRadius(16)
                            case .failure(let error):
                                Image(systemName: "photo.fill")
                                    .foregroundColor(.gray)
                                    .frame(width: 200, height: 150)
                            @unknown default:
                                EmptyView()
                                
                            }
                        }
                    }
                    
                    
                    else
                    {
                        Text(message.text)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                message.isCurrentUser ? Color.blue : Color.gray.opacity(0.2)
                            )
                            .foregroundColor(message.isCurrentUser ? .white : .primary)
                            .cornerRadius(16)
                            .onLongPressGesture {
                                withAnimation(.spring()) {
                                    showReactionPicker = true
                                }
                            }
                    }
                    
                    
                    
                    if !message.isCurrentUser { Spacer() }
                }
                
                // Reactions summary
                if !message.reactions.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(Array(message.reactions.keys), id: \.self) { type in
                            let isReacted = message.currentUserReactions.contains(type)
                            
                            Button(action: { onReact?(type) }) {
                                HStack(spacing: 2) {
                                    Text(type.emoji)
                                        .font(.system(size: 12))
                                    Text("\(message.reactions[type] ?? 0)")
                                        .font(.system(size: 11))
                                        .fontWeight(isReacted ? .bold : .regular)
                                        .foregroundColor(isReacted ? .blue : .secondary)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(isReacted ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(isReacted ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1)
                                        )
                                )
                                .scaleEffect(isReacted ? 1.05 : 1.0)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                
                // Reaction Picker
                if showReactionPicker {
                    reactionPicker
                        .offset(y: -44)
                        .zIndex(1)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                }
            }
        }
        .onTapGesture {
            withAnimation(.spring()) {
                showReactionPicker = false
            }
        }
    }
    
    // MARK: - Reaction Picker
    private var reactionPicker: some View {
        HStack(spacing: 8) {
            ForEach(ReactionType.allCases, id: \.self) { type in
                Button(action: {
                    onReact?(type)
                    withAnimation(.spring()) {
                        showReactionPicker = false
                    }
                }) {
                    Text(type.emoji)
                        .font(.system(size: 22))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
        )
    }
}
