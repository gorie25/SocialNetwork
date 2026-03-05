// AppConfig.swift

import Foundation
enum AppConfig {
    static var streamApiKey: String {
        value(for: "STREAM_API_KEY")
    }
    static var streamUserId: String {
        value(for: "STREAM_USER_ID")
    }
    static var streamUserToken: String {
        value(for: "STREAM_USER_TOKEN")
    }
    
    private static func value(for key: String) -> String {
        guard let value = Bundle.main.infoDictionary?[key] as? String else {
            fatalError("❌ Không tìm thấy key: \(key)")
        }
        return value
    }
}
