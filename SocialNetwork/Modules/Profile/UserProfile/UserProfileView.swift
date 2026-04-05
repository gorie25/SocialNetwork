import SwiftUI

struct UserProfileView: View {
    let userId: String
    @StateObject private var viewModel:UserProfileViewModel
    @State private var showSheet = false
    
    init(userId: String) {
        self.userId = userId
        _viewModel = StateObject(
            wrappedValue: UserProfileViewModel(userId: userId)
        )
    }
    
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                
                //  Profile Header Section
                if let user = viewModel.user {
                    ProfileHeaderView(user: user)
                }
                
                
                
                if(!viewModel.posts.isEmpty)
                {    // MARK: - Divider + Title
                    HStack {
                        Text("All posts")
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
                
                else
                {
                    VStack {
                        Text("Chưa có bài post nào!")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .task {
            await viewModel.loadUser()
        }
    }
}
