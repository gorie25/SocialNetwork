import SwiftUI

struct CommentItemView: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 10){
            
            
            //Avatar Field
            AsyncImage(url: URL(string: comment.userAvatar ?? "")){image in
                image
                    .resizable()
                    .scaledToFill()
                
            }
            placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
            }  .frame(width: 32, height: 32)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4){
                
                Text(comment.userName)
                    .font(.system(size: 13, weight: .semibold))
                
                Text(" \(comment.text)")
                    .font(.system(size: 13))
                
                Button("Trả lời") {
                    // reply
                }
                .font(.system(size: 11))
                .foregroundColor(.gray)
            }
            Spacer()
            
            //Reaction
            Button{
                
            } label:
            {
                Image(systemName: "heart")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
    }
}
