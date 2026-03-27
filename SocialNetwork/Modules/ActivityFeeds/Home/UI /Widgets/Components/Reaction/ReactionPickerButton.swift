import SwiftUI
struct ReactionPickerButton: View {
    
    let onReact: (String?) -> Void
    let initialReaction: String?
    
    @State private var selectedReaction: ReactionItem? = nil
    @State private var showPicker: Bool = false
    private var isSelected: Bool { selectedReaction != nil }
    
    private func selectReaction(_ reaction: ReactionItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            selectedReaction = reaction
            showPicker = false
        }
        onReact(reaction.type)
        
    }
    
    private func reactionColor(_ type: String?) -> Color {
        switch type {
        case "like":          return .blue
        case "love":          return .red
        case "haha", "wow":   return .orange
        case "sad", "angry":  return .orange
        default:              return .blue
        }
    }
    var body: some View {
        
        ZStack(alignment: .bottomLeading){
            
            if showPicker{
                HStack(spacing: 4){
                    ForEach (availableReactions) {
                        reaction in
                        VStack (spacing: 3){
                            Text(reaction.emoji)
                                .font(.system(size: 26))
                            
                            Circle()
                                .fill(selectedReaction?.type == reaction.type ? Color.gray.opacity(0.6) : Color.clear)
                                .frame(width: 5, height: 5)
                            
                        }.onTapGesture {
                            if selectedReaction?.type == reaction.type {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    selectedReaction = nil
                                    showPicker = false
                                }
                                onReact(nil)
                            } else {
                                selectReaction(reaction)
                            }
                            
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .fixedSize()
                .background(
                    Capsule()
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
                )
                .offset(y: -52)
                .transition(.scale(scale: 0.7, anchor: .bottomLeading).combined(with: .opacity))
                .zIndex(1)
            }
            
            Button {
            } label: {
                HStack(spacing: 6){
                    if isSelected {
                        Text(selectedReaction?.emoji ?? "")
                            .font(.system(size: 15))
                        Text( selectedReaction?.label ?? "")
                            .font(.system(size: 13, weight: .medium))
                    } else {
                        Image(systemName: "hand.thumbsup")
                            .font(.system(size: 15, weight: .medium))
                        Text( "Like")
                            .font(.system(size: 13, weight: .medium))
                    }
                }
                .foregroundColor(isSelected ? reactionColor(selectedReaction?.type) : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)            }
            .buttonStyle(PlainButtonStyle())
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.4)
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            showPicker = true
                        }
                        Task {
                            try? await Task.sleep(nanoseconds: 4_000_000_000)
                            withAnimation { showPicker = false }
                        }
                    })
        }.onAppear{
            selectedReaction = availableReactions.first { $0.type == initialReaction }
            
        }
        .onChange(of: initialReaction) { _, newValue in
            selectedReaction = availableReactions.first { $0.type == newValue }
        }
    }
    
    
    
}
