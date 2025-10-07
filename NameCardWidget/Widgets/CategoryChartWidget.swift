import WidgetKit
import SwiftUI
import Charts

// MARK: - Category Chart Widget

struct CategoryChartEntry: TimelineEntry {
    let date: Date
    let distribution: [CategoryDistributionData]
    let totalContacts: Int
}

struct CategoryChartProvider: TimelineProvider {
    func placeholder(in context: Context) -> CategoryChartEntry {
        CategoryChartEntry(
            date: Date(),
            distribution: [],
            totalContacts: 0
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CategoryChartEntry) -> Void) {
        let distribution = WidgetDataManager.shared.getCategoryDistribution()
        let total = WidgetDataManager.shared.getTotalContactCount()

        let entry = CategoryChartEntry(
            date: Date(),
            distribution: distribution,
            totalContacts: total
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CategoryChartEntry>) -> Void) {
        let currentDate = Date()
        let distribution = WidgetDataManager.shared.getCategoryDistribution()
        let total = WidgetDataManager.shared.getTotalContactCount()

        let entry = CategoryChartEntry(
            date: currentDate,
            distribution: distribution,
            totalContacts: total
        )

        // Update every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }
}

struct CategoryChartWidgetView: View {
    var entry: CategoryChartEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if entry.distribution.isEmpty {
            EmptyCategoryView()
        } else {
            switch family {
            case .systemSmall:
                SmallCategoryChartView(entry: entry)
            case .systemMedium:
                MediumCategoryChartView(entry: entry)
            case .systemLarge:
                LargeCategoryChartView(entry: entry)
            default:
                SmallCategoryChartView(entry: entry)
            }
        }
    }
}

// MARK: - Small Widget View

struct SmallCategoryChartView: View {
    let entry: CategoryChartEntry

    var body: some View {
        VStack(spacing: 8) {
            Text("Categories")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Chart(entry.distribution) { item in
                SectorMark(
                    angle: .value("Count", item.count),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(Color(hex: item.colorHex))
            }
            .chartLegend(.hidden)

            Text("\(entry.totalContacts)")
                .font(.title2)
                .fontWeight(.bold)

            Text("Contacts")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .widgetURL(URL(string: "namecard://statistics"))
    }
}

// MARK: - Medium Widget View

struct MediumCategoryChartView: View {
    let entry: CategoryChartEntry

    var body: some View {
        HStack(spacing: 16) {
            // Chart
            Chart(entry.distribution) { item in
                SectorMark(
                    angle: .value("Count", item.count),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(Color(hex: item.colorHex))
            }
            .chartLegend(.hidden)
            .frame(width: 120, height: 120)

            // Legend
            VStack(alignment: .leading, spacing: 8) {
                Text("Distribution")
                    .font(.headline)

                ForEach(entry.distribution.prefix(4)) { item in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: item.colorHex))
                            .frame(width: 8, height: 8)

                        Text(item.name)
                            .font(.caption)
                            .lineLimit(1)

                        Spacer()

                        Text("\(item.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }

                if entry.distribution.count > 4 {
                    Text("+\(entry.distribution.count - 4) more")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .widgetURL(URL(string: "namecard://statistics"))
    }
}

// MARK: - Large Widget View

struct LargeCategoryChartView: View {
    let entry: CategoryChartEntry

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Category Distribution")
                        .font(.headline)

                    Text("\(entry.totalContacts) total contacts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            // Chart
            Chart(entry.distribution) { item in
                SectorMark(
                    angle: .value("Count", item.count),
                    innerRadius: .ratio(0.5),
                    angularInset: 2.0
                )
                .foregroundStyle(Color(hex: item.colorHex))
                .annotation(position: .overlay) {
                    Text("\(item.count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
            .chartLegend(.hidden)
            .frame(height: 180)

            // Detailed Legend
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(entry.distribution) { item in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: item.colorHex))
                            .frame(width: 10, height: 10)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.caption)
                                .fontWeight(.medium)
                                .lineLimit(1)

                            Text("\(item.count) (\(Int(item.percentage(of: entry.totalContacts)))%)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                }
            }
        }
        .padding(12)
        .widgetURL(URL(string: "namecard://statistics"))
    }
}

// MARK: - Empty State

struct EmptyCategoryView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.pie")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No Categories")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Add contacts with categories")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Widget Configuration

struct CategoryChartWidget: Widget {
    let kind: String = "CategoryChartWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CategoryChartProvider()) { entry in
            CategoryChartWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Category Distribution")
        .description("View your contacts distributed across categories. Tap to view detailed statistics.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}
