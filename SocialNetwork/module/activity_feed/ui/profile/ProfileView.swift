import SwiftUI

struct ProfileView: View {
    
    @StateObject private var viewModel: ProfileViewModel
    @State private var showSheet = false
    init() {
        _viewModel = StateObject(
            wrappedValue: ProfileViewModel()
        )
    }
    
    var body: some View {
        ScrollView{
            //User info
            VStack(spacing: 16){
                if let user = viewModel.user {
                    ProfileHeaderView(user: user)
                }
            }
            
            // Create post
            VStack(alignment: .leading, spacing: 12){
                Text("All your posts").font(.headline).padding(.leading, 20)
                Text("What are you thinking?").foregroundColor(.gray)
                    .padding(.leading, 25)
                    .onTapGesture {
                        showSheet = true
                    }.sheet(isPresented: $showSheet)
                {
                    if let user = viewModel.user {
                       CreatePostBottomSheet(user: user)
                    }
                    
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
            //My post
            LazyVStack(spacing: 50)
            {
                ForEach(viewModel.posts)
                {
                    post in PostItemView(post: post)
                }
            }
        }
        .task {
            await viewModel.loadProfile()
        }
    }
}
struct ProfileHeaderView: View {
    let user: UserModel
    var body: some View{
        
        VStack(){
            if let urlString = user.imageURL,
               let url = URL(string: urlString) {
                
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            }
        }
        Text(user.name ?? "Unknown User")
            .font(.headline)
        
    }
    
}
