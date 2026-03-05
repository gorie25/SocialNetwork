import SwiftUI

struct PostItemView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: - Content (Text)
            if let text = post.text, !text.isEmpty {
                Text(text)
                    .font(.body)
            }
            
            // MARK: - Media 
            if let first = post.attachments.first {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay {
                        Text("Image")
                            .foregroundColor(.gray)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // MARK: - Actions (Like, Comment, Share)
            HStack(spacing: 20) {
                
                HStack(spacing: 4) {
                    Image(systemName: "heart")
                    Text("\(post.likeCount)")
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                    Text("\(post.commentCount)")
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "arrowshape.turn.up.forward")
                    Text("\(post.shareCount)")
                }
                
                Spacer()
            }
            .font(.subheadline)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 4)
        .padding(.horizontal)
    }
}
