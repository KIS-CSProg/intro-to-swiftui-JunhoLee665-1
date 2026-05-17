import SwiftUI

// MARK: - Feed View
struct PostFeedView: View {
    @State private var posts: [FeedPost] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil

    // Navigation to detail
    @State private var selectedPost: FeedPost? = nil
    @State private var navigateToDetail: Bool = false

    // Password unlock
    @State private var unlockingPost: FeedPost? = nil
    @State private var passwordInput: String = ""
    @State private var wrongPassword: Bool = false
    @State private var showPasswordSheet: Bool = false

    // New post
    @State private var showNewPost: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("loading posts...")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }

                } else if let error = errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("try again") { Task { await loadPosts() } }
                            .font(.system(size: 14))
                    }
                    .padding()

                } else if posts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary)
                        Text("no posts yet.\nbe the first to share.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }

                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(posts) { post in
                                FeedRowCard(post: post) {
                                    handleTap(post)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
            }
            .navigationTitle("feed")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { Task { await loadPosts() } }) {
                        Image(systemName: "arrow.clockwise").font(.system(size: 14))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showNewPost = true }) {
                        Image(systemName: "plus").font(.system(size: 16, weight: .medium))
                    }
                }
            }
            .task { await loadPosts() }
            .navigationDestination(isPresented: $navigateToDetail) {
                if let post = selectedPost {
                    PostDetailView(post: post)
                }
            }
            .sheet(isPresented: $showPasswordSheet) {
                PasswordUnlockSheet(
                    post: unlockingPost,
                    passwordInput: $passwordInput,
                    wrongPassword: $wrongPassword
                ) { enteredPassword in
                    checkPassword(enteredPassword)
                }
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showNewPost, onDismiss: {
                Task { await loadPosts() }
            }) {
                AnonymousPostView()
            }
        }
    }

    func handleTap(_ post: FeedPost) {
        if post.is_public {
            selectedPost = post
            navigateToDetail = true
        } else {
            unlockingPost = post
            passwordInput = ""
            wrongPassword = false
            showPasswordSheet = true
        }
    }

    func checkPassword(_ entered: String) {
        guard let post = unlockingPost else { return }
        if entered == post.password {
            showPasswordSheet = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                selectedPost = post
                navigateToDetail = true
            }
        } else {
            wrongPassword = true
        }
    }

    func loadPosts() async {
        isLoading = true
        errorMessage = nil
        do {
            posts = try await FeedService.shared.fetchPosts()
        } catch {
            errorMessage = "couldn't load posts. check your connection."
        }
        isLoading = false
    }
}

// MARK: - Feed Row Card (title only)
struct FeedRowCard: View {
    let post: FeedPost
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Mood emoji circle or lock
                ZStack {
                    Circle()
                        .fill(post.is_public ? Color(.secondarySystemBackground) : Color(hex: "EEEDFE"))
                        .frame(width: 40, height: 40)
                    if post.is_public {
                        Text(moodEmoji(post.mood ?? "") ?? "💬")
                            .font(.system(size: 18))
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "534AB7"))
                    }
                }

                // Title + date
                VStack(alignment: .leading, spacing: 3) {
                    Text(post.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(post.is_public ? .primary : .secondary)
                        .lineLimit(1)
                    Text(formattedDate(post.post_data))
                        .font(.system(size: 12))
                        .foregroundColor(Color(.tertiaryLabel))
                }

                Spacer()

                // Badge
                if post.is_public {
                    PublicBadge()
                } else {
                    PrivateBadge()
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .padding(14)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Password Unlock Sheet
struct PasswordUnlockSheet: View {
    let post: FeedPost?
    @Binding var passwordInput: String
    @Binding var wrongPassword: Bool
    let onSubmit: (String) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("unlock post")
                    .font(.system(size: 17, weight: .medium))
                if let title = post?.title {
                    Text(""\(title)"")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                Text("enter the password to read this private post.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                SecureField("enter password...", text: $passwordInput)
                    .padding(.horizontal, 14).padding(.vertical, 11)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(wrongPassword ? Color.red : Color(.separator),
                                    lineWidth: wrongPassword ? 1 : 0.5)
                    )
                    .onChange(of: passwordInput) { _ in wrongPassword = false }

                if wrongPassword {
                    Text("incorrect password. try again.")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }

            HStack(spacing: 10) {
                Button("cancel") { dismiss() }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .foregroundColor(.primary)
                    .font(.system(size: 14))

                Button("unlock") { onSubmit(passwordInput) }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(passwordInput.isEmpty ? Color(.systemGray4) : Color(hex: "1D1D1B"))
                    .cornerRadius(8)
                    .foregroundColor(Color(hex: "F1EFE8"))
                    .font(.system(size: 14, weight: .medium))
                    .disabled(passwordInput.isEmpty)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(24)
    }
}

// MARK: - Preview
#Preview {
    PostFeedView()
}
