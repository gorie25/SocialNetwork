//
//  ChannelListViewModel.swift
//  SocialNetwork
//
//  Created by Tien on 13/3/26.
//

import Foundation
import StreamChat
import Combine

@MainActor
class ChannelListViewModel: ObservableObject {
    @Published var channels: [ChannelModel] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedChannel: ChannelModel?
    
    private let chatService = ChatService.shared
    
    init() {
        setupChannelList()
    }

    private func setupChannelList() {
        chatService.setupChannelList()
        Task {
            await loadChannels()
        }
    }
    
    func loadChannels() async {
        isLoading = true
        do {
            channels = try await chatService.loadChannels()
            print("✅ Loaded \(channels.count) channels")
        } catch {
            print("❌ Load channels failed: \(error)")
        }
        isLoading = false
    }
    
    var filteredChannels: [ChannelModel] {
        if searchText.isEmpty { return channels }
        return channels.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}
