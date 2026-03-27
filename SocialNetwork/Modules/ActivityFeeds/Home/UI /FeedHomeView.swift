import SwiftUI

struct FeedHomeView: View{
    @StateObject private var viewModel: FeedHomeViewModel
    
    init()
    {
        _viewModel = StateObject(wrappedValue: FeedHomeViewModel())
    }
    
    var body: some View{
        ScrollView(){
            LazyVStack (spacing: 0){
                
                //-Story Section-
                StorySection()
                
                //-List Post Section-
                ForEach(viewModel.posts){ post in
                ActivityCard(post: post, viewModel: viewModel)}
                
            }
        }.refreshable {
            Task{
                await viewModel.refresh()
            }
        }
    }
}

#Preview {
    FeedHomeView()
}
