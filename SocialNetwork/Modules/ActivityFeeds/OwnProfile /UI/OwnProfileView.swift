import SwiftUI

struct OwnProfileView: View {
    
    @StateObject private var viewModel: OwnProfileViewModel
    @State private var showSheet = false
    
    init() {
        _viewModel = StateObject(wrappedValue: OwnProfileViewModel())
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                
                // MARK: - Profile Header Section
                if let user = viewModel.user {
                    ProfileHeaderView(user: user)
                }
                
                // MARK: - Create Post Section
                CreatePostSection(showSheet: $showSheet)
                    .sheet(isPresented: $showSheet) {
                        if let user = viewModel.user {
                            CreatePostBottomSheet(
                                user: user,
                                viewModel: viewModel
                            )
                        }
                    }
                
                // MARK: - Divider + Title
                HStack {
                    Text("All your posts")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(viewModel.posts.count) posts")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 12)
                
                // MARK: - Posts List
                LazyVStack(spacing: 1) {
                    ForEach(viewModel.posts) { post in
                        PostItemView(post: post)
                            .background(Color(.systemBackground))
                        
                        Divider()
                            .padding(.leading, 20)
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .background(Color(.systemGroupedBackground))
        .task {
            await viewModel.loadProfile()
        }
    }
}

// MARK: - Profile Header
struct ProfileHeaderView: View {
    let user: UserModel
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Cover gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.7),
                    Color.indigo.opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 110)
            .overlay(
                GeometryReader { geo in
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.07))
                            .frame(width: 160)
                            .offset(x: geo.size.width - 60, y: -40)
                        
                        Circle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 100)
                            .offset(x: 30, y: 10)
                    }
                }
            )
            
            // Avatar + Info
            VStack(spacing: 8) {
                Group {
                    if let urlString = user.imageURL,
                       let url = URL(string: urlString) {
                        
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Circle()
                                .fill(Color(.systemGray5))
                                .overlay(ProgressView())
                        }
                        
                    } else {
                        Circle()
                            .fill(Color(.systemGray5))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .frame(width: 84, height: 84)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(.systemBackground), lineWidth: 4)
                )
                .shadow(
                    color: .black.opacity(0.12),
                    radius: 8,
                    x: 0,
                    y: 4
                )
                .offset(y: -42)
                .padding(.bottom, -42)
                
                Text(user.name ?? "Unknown User")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 17, weight: .bold))
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Create Post Section
struct CreatePostSection: View {
    
    @Binding var showSheet: Bool
    
    var body: some View {
        Button(action: {
            showSheet = true
        }) {
            HStack(spacing: 12) {
                
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                    .frame(width: 36, height: 36)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                Text("What are you thinking?")
                    .font(.system(size: 15))
                    .foregroundColor(Color(.tertiaryLabel))
                
                Spacer()
                
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 17))
                    .foregroundColor(Color(.secondaryLabel))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(.separator), lineWidth: 0.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
    }
}

