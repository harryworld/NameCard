import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

// MARK: - Refresh Intent

struct RefreshContactIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Contact"
    static var description = IntentDescription("Load a new random contact")

    func perform() async throws -> some IntentResult {
        // Reload all Random Contact widgets
        WidgetCenter.shared.reloadTimelines(ofKind: "RandomContactWidget")
        return .result()
    }
}

// MARK: - Random Contact Widget

struct RandomContactEntry: TimelineEntry {
    let date: Date
    let contact: StoredContact?
}

struct RandomContactProvider: TimelineProvider {
    func placeholder(in context: Context) -> RandomContactEntry {
        RandomContactEntry(date: Date(), contact: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (RandomContactEntry) -> Void) {
        let entry = RandomContactEntry(
            date: Date(),
            contact: WidgetDataManager.shared.getRandomContact()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RandomContactEntry>) -> Void) {
        let currentDate = Date()
        let contact = WidgetDataManager.shared.getRandomContact()
        let entry = RandomContactEntry(date: currentDate, contact: contact)

        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }
}

struct RandomContactWidgetView: View {
    var entry: RandomContactEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let contact = entry.contact {
            switch family {
            case .systemSmall:
                SmallRandomContactView(contact: contact)
            case .systemMedium:
                MediumRandomContactView(contact: contact)
            case .systemLarge:
                LargeRandomContactView(contact: contact)
            default:
                SmallRandomContactView(contact: contact)
            }
        } else {
            EmptyContactView()
        }
    }
}

// MARK: - Small Widget View

struct SmallRandomContactView: View {
    let contact: StoredContact
    @Environment(\.widgetRenderingMode) var renderingMode

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundStyle(categoryColor)

                Spacer()

                Button {
                    // TODO: AppIntent
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text(contact.fullName)
                    .font(.headline)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                if !contact.organization.isEmpty {
                    Text(contact.organization)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if let category = contact.category {
                    Text(category.name)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(categoryColor.opacity(0.2))
                        .foregroundStyle(categoryColor)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(12)
        // TODO: DeepLink
    }

    private var categoryColor: Color {
        if let colorHex = contact.category?.colorHex {
            return Color(hex: colorHex)
        }
        return .gray
    }

    private var deepLinkURL: URL {
        URL(string: "namecard://contact/\(contact.id.uuidString)")!
    }
}

// MARK: - Medium Widget View

struct MediumRandomContactView: View {
    let contact: StoredContact

    var body: some View {
        HStack(spacing: 16) {
            VStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(categoryColor)

                if let category = contact.category {
                    Text(category.name)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(categoryColor.opacity(0.2))
                        .foregroundStyle(categoryColor)
                        .clipShape(Capsule())
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(contact.fullName)
                        .font(.headline)
                        .lineLimit(1)

                    Spacer()

                    Button(intent: RefreshContactIntent()) {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                if !contact.title.isEmpty {
                    Text(contact.title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if !contact.organization.isEmpty {
                    Text(contact.organization)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                HStack(spacing: 12) {
                    if !contact.email.isEmpty {
                        Label("", systemImage: "envelope.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }

                    if !contact.phone.isEmpty {
                        Label("", systemImage: "phone.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }

            Spacer()
        }
        .padding(12)
        .widgetURL(deepLinkURL)
    }

    private var categoryColor: Color {
        if let colorHex = contact.category?.colorHex {
            return Color(hex: colorHex)
        }
        return .gray
    }

    private var deepLinkURL: URL {
        URL(string: "namecard://contact/\(contact.id.uuidString)")!
    }
}

// MARK: - Large Widget View

struct LargeRandomContactView: View {
    let contact: StoredContact

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(categoryColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.fullName)
                        .font(.title2)
                        .fontWeight(.bold)

                    if !contact.title.isEmpty {
                        Text(contact.title)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let category = contact.category {
                        Text(category.name)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(categoryColor.opacity(0.2))
                            .foregroundStyle(categoryColor)
                            .clipShape(Capsule())
                    }
                }

                Spacer()

                Button(intent: RefreshContactIntent()) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                if !contact.organization.isEmpty {
                    InfoRow(icon: "building.2", text: contact.organization)
                }

                if !contact.email.isEmpty {
                    InfoRow(icon: "envelope", text: contact.email)
                }

                if !contact.phone.isEmpty {
                    InfoRow(icon: "phone", text: contact.phone)
                }

                if !contact.department.isEmpty {
                    InfoRow(icon: "person.2", text: contact.department)
                }
            }

            Spacer()
        }
        .padding(12)
        .widgetURL(deepLinkURL)
    }

    private var categoryColor: Color {
        if let colorHex = contact.category?.colorHex {
            return Color(hex: colorHex)
        }
        return .gray
    }

    private var deepLinkURL: URL {
        URL(string: "namecard://contact/\(contact.id.uuidString)")!
    }
}

struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            Text(text)
                .font(.subheadline)
                .lineLimit(1)
        }
    }
}

// MARK: - Empty State

struct EmptyContactView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No Contacts")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Add contacts to see them here")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Widget Configuration

struct RandomContactWidget: Widget {
    let kind: String = "RandomContactWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RandomContactProvider()) { entry in
            RandomContactWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Random Contact")
        .description("Display a random contact from your collection. Tap to view details or refresh for a new contact.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
