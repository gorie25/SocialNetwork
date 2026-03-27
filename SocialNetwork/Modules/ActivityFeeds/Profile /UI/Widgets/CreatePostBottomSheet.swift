import SwiftUI

struct CreatePostBottomSheet: View {
    let user: UserModel
    
    @State private var content = ""
    @State private var selectedPrivacy: Privacy = .everyone
    @State private var isPosting = false
    @FocusState private var isFocused: Bool
    @ObservedObject var viewModel: ProfileViewModel
    
    private let maxCharacters = 500
    private var remaining: Int { maxCharacters - content.count }
    private var progress: Double { Double(content.count) / Double(maxCharacters) }
    private var isOverLimit: Bool { content.count > maxCharacters }
    private var canPost: Bool { !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isOverLimit }
    
    enum Privacy: String, CaseIterable {
        case everyone = "Everyone"
        case followers = "Followers"
        case friends = "Friends only"
        
        var icon: String {
            switch self {
            case .everyone: return "globe"
            case .followers: return "person.2"
            case .friends: return "lock"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Drag Handle
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 8)
            
            // MARK: - Header
            HStack {
                Button(action: { /* dismiss */ }) {
                    Text("Cancel")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("New Post")
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                // Placeholder to balance layout
                Text("Cancel")
                    .font(.system(size: 16))
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 0) {
                    
                    // MARK: - User Info Row
                    HStack(alignment: .top, spacing: 12) {
                        ZStack(alignment: .bottomTrailing) {
                            if let urlString = user.imageURL, let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Circle().fill(Color(.systemGray5))
                                        .overlay(ProgressView())
                                }
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color(.systemGray5))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.gray)
                                    )
                            }
                            
                            // Online indicator
                            Circle()
                                .fill(Color.green)
                                .frame(width: 12, height: 12)
                                .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name ?? "Unknown User")
                                .font(.system(size: 15, weight: .semibold))
                            
                            // Privacy Picker
                            Menu {
                                ForEach(Privacy.allCases, id: \.self) { option in
                                    Button(action: { selectedPrivacy = option }) {
                                        Label(option.rawValue, systemImage: option.icon)
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: selectedPrivacy.icon)
                                        .font(.system(size: 10, weight: .semibold))
                                    Text(selectedPrivacy.rawValue)
                                        .font(.system(size: 12, weight: .medium))
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 9, weight: .bold))
                                }
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Capsule())
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // MARK: - Text Editor
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("What's on your mind?")
                                .foregroundColor(Color(.tertiaryLabel))
                                .font(.system(size: 16))
                                .padding(.top, 12)
                                .padding(.leading, 20)
                        }
                        
                        TextEditor(text: $content)
                            .focused($isFocused)
                            .font(.system(size: 16))
                            .frame(minHeight: 120)
                            .padding(.horizontal, 16)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                    }
                    .padding(.top, 4)
                }
            }
            
            // MARK: - Bottom Bar
            VStack(spacing: 0) {
                Divider()
                
                // Toolbar
                HStack(spacing: 20) {
                    ToolbarButton(icon: "photo.on.rectangle", label: "Photo")
                    ToolbarButton(icon: "camera", label: "Camera")
                    ToolbarButton(icon: "at", label: "Mention")
                    ToolbarButton(icon: "number", label: "Hashtag")
                    ToolbarButton(icon: "face.smiling", label: "Emoji")
                    
                    Spacer()
                    
                    // Character Count Ring
                    CharacterCountRing(
                        progress: progress,
                        remaining: remaining,
                        isOverLimit: isOverLimit
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                
                Divider()
                
                // Post Button Row
                HStack {
                    Text(isOverLimit ? "\(abs(remaining)) over limit" : "")
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                        .animation(.easeInOut, value: isOverLimit)
                    
                    Spacer()
                    
                    Button(action: handlePost) {
                        HStack(spacing: 6) {
                            if isPosting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isPosting ? "Posting..." : "Post")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 28)
                        .padding(.vertical, 11)
                        .background(
                            canPost
                            ? LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [Color(.systemGray4), Color(.systemGray4)], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                        .shadow(color: canPost ? Color.blue.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                    }
                    .disabled(!canPost || isPosting)
                    .animation(.spring(response: 0.3), value: canPost)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 24)
            }
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .onAppear { isFocused = true }
    }
    
    private func handlePost() {
           guard canPost else { return }
           isPosting = true
           Task {
               await viewModel.createPost(content: content)
               isPosting = false
           }
       }
}

// MARK: - Toolbar Button
struct ToolbarButton: View {
    let icon: String
    let label: String
    
    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(.secondaryLabel))
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Character Count Ring
struct CharacterCountRing: View {
    let progress: Double
    let remaining: Int
    let isOverLimit: Bool
    
    private var ringColor: Color {
        if isOverLimit { return .red }
        if progress > 0.8 { return .orange }
        return .blue
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 2.5)
            
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(ringColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.2), value: progress)
            
            if progress > 0.7 {
                Text(isOverLimit ? "-\(abs(remaining))" : "\(remaining)")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(ringColor)
                    .animation(.easeInOut, value: isOverLimit)
            }
        }
        .frame(width: 28, height: 28)
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
