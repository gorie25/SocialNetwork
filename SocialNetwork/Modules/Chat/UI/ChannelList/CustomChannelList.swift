import SwiftUI
import StreamChat

struct CustomChannelList: View {

    @StateObject private var viewModel: ChannelListViewModel
    
    init() {
        _viewModel = StateObject(
            wrappedValue: ChannelListViewModel()
        )
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading channels...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredChannels.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No channels found")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.filteredChannels, id: \.id) { channel in
                        ChannelRowView(
                            channel: channel,
                            isSelected: viewModel.selectedChannel?.id == channel.id,
                            onTap: {
                                log.info("ChannelDetailView appeared — channel: \(channel.name)")
                                viewModel.selectedChannel = channel
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.loadChannels()
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search channels")
            .navigationTitle("Messages")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .background(
                NavigationLink(
                    destination: destinationView(),
                    isActive: Binding(
                        get: { viewModel.selectedChannel != nil },
                        set: { if !$0 { viewModel.selectedChannel = nil } }
                    )
                ) {
                    EmptyView()
                }
            )
        }
    }

    @ViewBuilder
    private func destinationView() -> some View {
        if let channel = viewModel.selectedChannel {
            ChannelDetailView(
                channel: channel,
            ).onAppear {
                log.info("Creating ChannelDetailView for: \(channel.name)")
            }
        }
    }
}
