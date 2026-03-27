import Foundation

struct UserModel: Identifiable, Sendable {
    
    let id: String
    let name: String?
    let imageURL: String?
    let originalName: String?
}
