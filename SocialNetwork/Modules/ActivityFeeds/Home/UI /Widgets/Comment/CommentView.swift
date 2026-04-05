import SwiftUI

struct CommentView: View {
    let activityId: String
    @State private var comment: String = ""
    @StateObject private var viewModel: CommentViewModel
    @FocusState private var isFocused: Bool
    
    init(activityId: String){
        self.activityId = activityId
        _viewModel = StateObject(
            wrappedValue: CommentViewModel(activityId: activityId)
        )
        
    }
    var body: some View {
        VStack(){
            Text("Bình luận")
                .font(.system(size: 16, weight: .semibold))
            
            if !viewModel.comments.isEmpty {
                ScrollView{
                    LazyVStack(alignment: .leading, spacing: 16)
                    {
                        ForEach(viewModel.comments) { comment in
                            CommentItemView(comment: comment)
                        }
                    }
                }
            } else
            {
                Text("Bài viết chưa có bình luận nào!")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.leading)
            }
            
            Divider()
            
            HStack{
                TextField("Thêm bình luận", text: $comment)
                    .textFieldStyle(.roundedBorder)
                    .focused($isFocused)
                Button {
                    Task{
                        await viewModel.addComment( content: comment)
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                        .foregroundColor(comment.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .blue)
                    
                }
            }
          
        }.padding(.vertical, 16)
        .padding(.horizontal, 16)
    }
}
