import SwiftUI

// MARK: - Post Model
struct FeedPost: Identifiable, Codable {
    let id: Int
    let title: String
    let content: String
    let is_public: Bool
    let password: String?
    let post_data: String
    let mood: String?
}

// MARK: - Feed Service
class FeedService {
    static let shared = FeedService()

    func fetchPosts() async throws -> [FeedPost] {
        guard let url = URL(string: "\(SUPABASE_URL)/rest/v1/posts?select=*&order=post_data.desc") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.setValue(SUPABASE_ANON_KEY, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(SUPABASE_ANON_KEY)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            print("Fetch error: \(body)")
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([FeedPost].self, from: data)
    }
}

// MARK: - Shared Badges
struct PublicBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "globe").font(.system(size: 10))
            Text("public").font(.system(size: 11))
        }
        .foregroundColor(Color(hex: "085041"))
        .padding(.horizontal, 8).padding(.vertical, 3)
        .background(Color(hex: "E1F5EE"))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "1D9E75"), lineWidth: 0.5))
    }
}

struct PrivateBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "lock").font(.system(size: 10))
            Text("private").font(.system(size: 11))
        }
        .foregroundColor(Color(hex: "26215C"))
        .padding(.horizontal, 8).padding(.vertical, 3)
        .background(Color(hex: "EEEDFE"))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "534AB7"), lineWidth: 0.5))
    }
}

// MARK: - Shared Helpers
func moodEmoji(_ mood: String) -> String? {
    let map: [String: String] = [
        "overwhelmed": "😵‍💫",
        "anxious": "😰",
        "burnt out": "🥵",
        "lost": "😶‍🌫️",
        "sad": "😔",
        "angry": "😤"
    ]
    return map[mood.lowercased()]
}

func formattedDate(_ isoString: String) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = formatter.date(from: isoString) {
        let display = RelativeDateTimeFormatter()
        display.unitsStyle = .short
        return display.localizedString(for: date, relativeTo: Date())
    }
    return isoString
}
