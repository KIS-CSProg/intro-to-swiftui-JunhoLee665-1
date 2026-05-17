import SwiftUI

// MARK: - Post Detail View
struct PostDetailView: View {
    let post: FeedPost

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Header card
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        if let emoji = moodEmoji(post.mood ?? "") {
                            Text(emoji).font(.system(size: 24))
                        }
                        if post.is_public {
                            PublicBadge()
                        } else {
                            PrivateBadge()
                        }
                        Spacer()
                        Text(formattedDate(post.post_data))
                            .font(.system(size: 12))
                            .foregroundColor(Color(.tertiaryLabel))
                    }

                    Text(post.title)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.primary)

                    if let mood = post.mood {
                        Text(mood)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(20)
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))

                // Content card
                VStack(alignment: .leading, spacing: 8) {
                    Text("their words")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(post.content)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .lineSpacing(6)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))

                // Cheer-up response
                CheerUpResponseView(post: post)
            }
            .padding(16)
        }
        .navigationTitle("post")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Cheer Up Response View
struct CheerUpResponseView: View {
    let post: FeedPost
    @State private var isLoading: Bool = false
    @State private var response: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "D4537E"))
                Text("a little cheer for you")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "D4537E"))
            }

            if isLoading {
                HStack(spacing: 8) {
                    ProgressView().scaleEffect(0.8)
                    Text("thinking of something kind...")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color(hex: "FBEAF0"))
                .cornerRadius(10)

            } else if let msg = response {
                VStack(alignment: .leading, spacing: 10) {
                    Text(msg)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "4B1528"))
                        .lineSpacing(5)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action: { response = nil }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise").font(.system(size: 11))
                            Text("generate another").font(.system(size: 12))
                        }
                        .foregroundColor(Color(hex: "D4537E"))
                    }
                    .buttonStyle(.plain)
                }
                .padding(14)
                .background(Color(hex: "FBEAF0"))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "D4537E").opacity(0.3), lineWidth: 0.5))

            } else {
                Button(action: generateCheerUp) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles").font(.system(size: 13))
                        Text("get a cheer-up message")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "4B1528"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color(hex: "FBEAF0"))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "D4537E").opacity(0.4), lineWidth: 0.5))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))
    }

    func generateCheerUp() {
        // TODO: Replace with your real cheer-up API call
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isLoading = false
            response = "Hey, it takes real courage to put your feelings into words. Whatever you're going through right now, you're not alone in it. Take it one breath at a time — you've got this. 💛"
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PostDetailView(post: FeedPost(
            id: 1,
            title: "finals week is destroying me",
            content: "I have 3 exams in 2 days and I haven't slept properly in a week. I feel like no matter how hard I study it's never enough. I just needed somewhere to say this out loud.",
            is_public: true,
            password: nil,
            post_data: ISO8601DateFormatter().string(from: Date()),
            mood: "overwhelmed"
        ))
    }
}
