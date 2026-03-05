import Foundation
import SwiftUI
// ToastModel.swift
struct ToastModel: Equatable {
    let message: String
    var duration: Double = 2.5
    var style: ToastStyle = .default
}

enum ToastStyle {
    case `default`, success, error, warning

    var backgroundColor: Color {
        switch self {
        case .default:  return .black.opacity(0.75)
        case .success:  return .green
        case .error:    return .red
        case .warning:  return .orange
        }
    }

    var icon: String? {
        switch self {
        case .default:  return nil
        case .success:  return "checkmark.circle.fill"
        case .error:    return "xmark.circle.fill"
        case .warning:  return "exclamationmark.triangle.fill"
        }
    }
}
