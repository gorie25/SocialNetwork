
import SwiftUI

struct CreatePostBottomSheet: View {
    let user: UserModel
    
    @State private var content = ""
    @FocusState private var isFocused: Bool
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                if let urlString = user.imageURL,
                   let url = URL(string: urlString) {
                    
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 46, height: 46)
                    .clipShape(Circle())
                    
                    Text(user.name ?? "Unknown User")
                        .font(.headline)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
            
            ZStack(alignment: .topLeading) {
                if content.isEmpty {
                    Text("What are you thinking?")
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                        .padding(.leading, 16)
                }
                
                TextEditor(text: $content)
                    .focused($isFocused)
                    .frame(minHeight: 150)
                    .padding(5)
            }
        }
        .onAppear {
            isFocused = true
        }
        
        Spacer()
        HStack{
            Spacer()
            Button(action: {
                
            }){
                Text("Post")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 35)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        } .padding(.bottom, 20)
            .padding(.trailing, 16)
    }
}
