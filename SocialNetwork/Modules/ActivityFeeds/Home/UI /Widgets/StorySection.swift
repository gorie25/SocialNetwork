import SwiftUI

// MARK: - Model

struct StoryItem: Identifiable {
    let id = UUID()
    let username: String
    let color: Color
    var isSeen: Bool = false
}

// MARK: - Mock Data

private let mockStories: [StoryItem] = [
    StoryItem(username: "alice",   color: .red),
    StoryItem(username: "bob",     color: .blue),
    StoryItem(username: "charlie", color: .green),
    StoryItem(username: "david",   color: .orange),
    StoryItem(username: "emma",    color: .purple),
    StoryItem(username: "frank",   color: .pink),
    StoryItem(username: "grace",   color: .teal),
    StoryItem(username: "henry",   color: .indigo),
    StoryItem(username: "iris",    color: .yellow),
    StoryItem(username: "jack",    color: .cyan),
]

// MARK: - Story Row (Horizontal Scroll)

struct StorySection: View {

    @State private var stories: [StoryItem] = mockStories
    @State private var selectedIndex: Int? = nil

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                // My Story
                MyStoryBubble()

                // Others
                ForEach(Array(stories.enumerated()), id: \.element.id) { index, story in
                    StoryBubble(story: story)
                        .onTapGesture {
                            selectedIndex = index
                        }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .fullScreenCover(item: Binding(
            get: {
                selectedIndex.map { SelectedStory(index: $0) }
            },
            set: { val in
                selectedIndex = val?.index
                // đánh dấu đã xem
                if let idx = val?.index {
                    stories[idx].isSeen = true
                }
            }
        )) { selected in
            StoryViewer(
                stories: stories,
                startIndex: selected.index
            ) { idx in
                stories[idx].isSeen = true
            }
        }
    }
}

// Helper để dùng với fullScreenCover(item:)
private struct SelectedStory: Identifiable {
    let id = UUID()
    let index: Int
}

// MARK: - My Story Bubble

private struct MyStoryBubble: View {
    var body: some View {
        VStack(spacing: 5) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 64, height: 64)

                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32)
                    .foregroundStyle(.gray)
                    .frame(width: 64, height: 64)

                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.blue)
                    .background(Circle().fill(.white).padding(-2))
            }

            Text("Your story")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(width: 68)
        }
    }
}

// MARK: - Story Bubble

struct StoryBubble: View {

    let story: StoryItem

    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                // Ring gradient (chưa xem) hoặc xám (đã xem)
                Circle()
                    .strokeBorder(
                        story.isSeen
                            ? AnyShapeStyle(Color(.systemGray4))
                            : AnyShapeStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange, .pink, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            ),
                        lineWidth: 2.5
                    )
                    .frame(width: 70, height: 70)

                // Avatar (dùng màu mock)
                Circle()
                    .fill(story.color.opacity(0.85))
                    .frame(width: 62, height: 62)
                    .overlay {
                        Text(story.username.prefix(1).uppercased())
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                    }
            }

            Text(story.username)
                .font(.system(size: 11))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .frame(width: 70)
        }
    }
}

// MARK: - Story Viewer (Fullscreen)

struct StoryViewer: View {

    let stories: [StoryItem]
    let startIndex: Int
    var onSeen: (Int) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex: Int = 0
    @State private var progress: CGFloat = 0
    @State private var timer: Timer? = nil

    private let duration: Double = 4.0

    var body: some View {
        ZStack {
            // Background
            stories[currentIndex].color
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Progress bars ────────────────────────────
                HStack(spacing: 4) {
                    ForEach(0..<stories.count, id: \.self) { i in
                        ProgressBar(
                            filled: i < currentIndex ? 1 :
                                    i == currentIndex ? progress : 0
                        )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 56)
                .padding(.bottom, 10)

                // ── Header ───────────────────────────────────
                HStack(spacing: 10) {
                    Circle()
                        .fill(stories[currentIndex].color)
                        .frame(width: 36, height: 36)
                        .overlay {
                            Text(stories[currentIndex].username.prefix(1).uppercased())
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 1))

                    Text(stories[currentIndex].username)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)

                    Text(timeAgo())
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.7))

                    Spacer()

                    Button { dismissViewer() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal, 14)

                Spacer()

                // ── Content ──────────────────────────────────
                Text(stories[currentIndex].username)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(radius: 4)

                Spacer()

                // ── Reply bar ────────────────────────────────
                HStack(spacing: 12) {
                    Capsule()
                        .stroke(.white.opacity(0.6), lineWidth: 1)
                        .overlay(
                            Text("Reply to \(stories[currentIndex].username)…")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.7))
                                .padding(.horizontal, 16),
                            alignment: .leading
                        )
                        .frame(height: 44)

                    Button { } label: {
                        Image(systemName: "heart")
                            .font(.system(size: 24))
                            .foregroundStyle(.white)
                    }

                    Button { } label: {
                        Image(systemName: "paperplane")
                            .font(.system(size: 24))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 40)
            }

            // ── Tap zones (trái / phải) ───────────────────────
            HStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { prevStory() }

                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { nextStory() }
            }
        }
        .onAppear {
            currentIndex = startIndex
            startProgress()
        }
        .onDisappear {
            stopTimer()
        }
    }

    // MARK: - Progress

    private func startProgress() {
        stopTimer()
        progress = 0
        onSeen(currentIndex)

        withAnimation(.linear(duration: duration)) {
            progress = 1
        }

        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            nextStory()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func nextStory() {
        if currentIndex < stories.count - 1 {
            currentIndex += 1
            startProgress()
        } else {
            dismissViewer()
        }
    }

    private func prevStory() {
        if currentIndex > 0 {
            currentIndex -= 1
            startProgress()
        }
    }

    private func dismissViewer() {
        stopTimer()
        dismiss()
    }

    private func timeAgo() -> String { "2m ago" }
}

// MARK: - Progress Bar

private struct ProgressBar: View {
    let filled: CGFloat  // 0...1

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.35))

                Capsule()
                    .fill(.white)
                    .frame(width: geo.size.width * min(filled, 1))
            }
        }
        .frame(height: 3)
    }
}

// MARK: - Preview

#Preview("Story Row") {
    VStack {
        StorySection()
        Spacer()
    }
}

#Preview("Story Viewer") {
    StoryViewer(stories: mockStories, startIndex: 0) { _ in }
}
