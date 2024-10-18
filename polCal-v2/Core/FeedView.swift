import SwiftUI

// MARK: - NewsAnnouncement Struct

struct NewsAnnouncement: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let content: String
    let image: Image?
}

// MARK: - NewsAnnouncementView

struct NewsAnnouncementView: View {
    let announcement: NewsAnnouncement

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let image = announcement.image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .cornerRadius(8)
            }

            Text(announcement.title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(announcement.date, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(announcement.content)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true) // Allows text to wrap properly
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - NewsFeedView

struct FeedView: View {
    let announcements: [NewsAnnouncement]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(announcements) { announcement in
                    NewsAnnouncementView(announcement: announcement)
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Preview

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleAnnouncements = [
            NewsAnnouncement(
                title: "Maintenance Downtime",
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                content: "Our service will undergo scheduled maintenance tomorrow between 2 AM and 4 AM UTC.",
                image: nil
            ),
            NewsAnnouncement(
                title: "Community Event",
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                content: "Join us for a live Q&A session with our development team. Your feedback is invaluable!",
                image: Image(systemName: "person.3.fill")
            )
        ]

        FeedView(announcements: sampleAnnouncements)
    }
}
