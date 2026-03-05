import Foundation
import SwiftUI
import Combine

struct ToastModifier: ViewModifier {
    @ObservedObject var manager = ToastManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if let message = manager.message {
                VStack {
                    Spacer()
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.75))
                        .clipShape(Capsule())
                        .padding(.bottom, 20)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: manager.message)
    }
}
    
    
    extension View {
        func toastManager() -> some View {
            self.modifier(ToastModifier())
        }
    }
    

