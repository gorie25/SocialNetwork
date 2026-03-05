import SwiftUI
import Combine

@MainActor
final class ToastManager: ObservableObject {
    static let shared = ToastManager()

    @Published var message: String?

    func show(_ message: String) {
        self.message = message

        Task {
            try? await Task.sleep(for: .seconds(2.5))
            self.message = nil
        }
    }
}
