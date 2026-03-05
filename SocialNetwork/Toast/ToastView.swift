
import SwiftUI

// ToastView.swift
struct ToastView: View {
    let toast: ToastModel

    var body: some View {
        HStack(spacing: 8) {
            if let icon = toast.style.icon {
                Image(systemName: icon)
                    .foregroundColor(.white)
            }
            Text(toast.message)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(toast.style.backgroundColor)
        .clipShape(Capsule())
        .shadow(radius: 4)
    }
}
