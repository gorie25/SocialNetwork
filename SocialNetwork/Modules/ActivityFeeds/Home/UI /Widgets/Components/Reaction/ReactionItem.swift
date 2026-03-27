import Foundation


struct ReactionItem: Identifiable {
    let id = UUID()
    let type: String
    let emoji: String
    let label: String
}

let availableReactions: [ReactionItem] = [
    .init(type: "like",  emoji: "👍", label: "Like"),
    .init(type: "love",  emoji: "❤️", label: "Love"),
    .init(type: "haha",  emoji: "😂", label: "Haha"),
    .init(type: "wow",   emoji: "😮", label: "Wow"),
    .init(type: "sad",   emoji: "😢", label: "Sad"),
    .init(type: "angry", emoji: "😡", label: "Angry"),
]
