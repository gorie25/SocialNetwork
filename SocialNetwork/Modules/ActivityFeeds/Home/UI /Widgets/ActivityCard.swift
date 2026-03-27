import SwiftUI

// MARK: - ActivityCard
struct ActivityCard: View {
    let post: Post
    let viewModel: FeedHomeViewModel
    
    @State private var likeAnimating: Bool = false
    @State private var likeCount: Int
    
    init(post: Post, viewModel: FeedHomeViewModel) {
        self.post = post
        self.viewModel = viewModel
        _likeCount = State(initialValue: post.likeCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // MARK: Header
            HStack(spacing: 12) {
                AvatarView(name: "Luke Skywalker")
                
                Text("Luke Skywalker")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    // menu action
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // MARK: Content
            Text(post.text ?? "")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.primary.opacity(0.85))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            
            // MARK: Stats row
            HStack(spacing: 0) {
                // Reaction bubbles
                HStack(spacing: -6) {
                    ReactionBubble(emoji: "👍", color: Color.blue)
                    ReactionBubble(emoji: "❤️", color: Color.red)
                }
                
                Text("\(likeCount) likes")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.leading, 10)
                
                Spacer()
                
                HStack(spacing: 12) {
                    if post.commentCount > 0 {
                        Text("\(post.commentCount) comments")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    if post.shareCount > 0 {
                        Text("\(post.shareCount) shares")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
            
            // MARK: Divider
            Divider()
                .padding(.horizontal, 16)
            
            // MARK: Action bar
            HStack(spacing: 0) {
                
                ReactionPickerButton(
                    onReact:  { reactionType in
                        Task{
                            await  viewModel.reactionPost(activityId: post.id, reactionType: reactionType)
                        }
                        
                    }, initialReaction: post.ownReaction
                )
                
                Divider()
                    .frame(height: 20)
                
                ActionButton(icon: "bubble.right", title: "Comment", color: .secondary) {
                    // comment action
                }
                
                Divider()
                    .frame(height: 20)
                
                ActionButton(icon: "arrowshape.turn.up.right", title: "Share", color: .secondary) {
                    // share action
                }
            }
            .padding(.vertical, 4)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.07), radius: 12, x: 0, y: 4)
        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
    }
}

// MARK: - AvatarView
struct AvatarView: View {
    let name: String
    
    private var initials: String {
        let parts = name.split(separator: " ")
        return parts.prefix(2).compactMap { $0.first.map(String.init) }.joined()
    }
    
    private var gradient: LinearGradient {
        LinearGradient(
            colors: [Color(hue: 0.6, saturation: 0.7, brightness: 0.9),
                     Color(hue: 0.75, saturation: 0.8, brightness: 0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ZStack {
            Circle().fill(gradient)
            Text(initials)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: 42, height: 42)
        .overlay(
            Circle()
                .stroke(Color.white, lineWidth: 2)
        )
        .shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 2)
    }
}

// MARK: - ReactionBubble
struct ReactionBubble: View {
    let emoji: String
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 22, height: 22)
            Text(emoji)
                .font(.system(size: 11))
        }
    }
}

// MARK: - ActionButton
struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    var scaleEffect: CGFloat = 1.0
    let action: () -> Void
    
    @State private var pressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .scaleEffect(scaleEffect)
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(pressed ? color.opacity(0.08) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        ._onButtonGesture(pressing: { isPressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                pressed = isPressing
            }
        }, perform: {})
    }
}

