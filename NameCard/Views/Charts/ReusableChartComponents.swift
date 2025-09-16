import SwiftUI
import Charts

// MARK: - Reusable Chart Container
struct ChartContainer<Content: View>: View {
    let title: String
    let subtitle: String?
    let content: Content

    init(title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            content
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Compact Chart Container
struct CompactChartContainer<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)

            content
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Reusable Pie Chart
struct ReusablePieChart: View {
    let data: [CategoryData]
    let innerRadius: Double

    init(data: [CategoryData], innerRadius: Double = 0.4) {
        self.data = data
        self.innerRadius = innerRadius
    }

    var body: some View {
        Group {
            if data.isEmpty {
                ContentUnavailableView(
                    "No Data",
                    systemImage: "chart.pie",
                    description: Text("Data will appear here when available")
                )
                .frame(height: 200)
            } else {
                Chart(data) { item in
                    SectorMark(
                        angle: .value("Count", item.count),
                        innerRadius: .ratio(innerRadius),
                        angularInset: 1.5
                    )
                    .foregroundStyle(Color(hex: item.color))
                    .opacity(0.8)
                }
                .frame(height: 200)
                .chartLegend(position: .bottom, alignment: .center)
//                .chartAngleSelection(value: .constant(nil))
            }
        }
    }
}

// MARK: - Reusable Bar Chart
struct ReusableBarChart: View {
    let data: [FieldCompletenessData]
    let color: Color
    let isHorizontal: Bool

    init(data: [FieldCompletenessData], color: Color = .cyan, isHorizontal: Bool = true) {
        self.data = data
        self.color = color
        self.isHorizontal = isHorizontal
    }

    var body: some View {
        Group {
            if data.isEmpty || data.allSatisfy({ $0.totalCount == 0 }) {
                ContentUnavailableView(
                    "No Data",
                    systemImage: "chart.bar.horizontal",
                    description: Text("Chart data will appear here")
                )
                .frame(height: 150)
            } else {
                Chart(data) { item in
                    if isHorizontal {
                        BarMark(
                            x: .value("Percentage", item.percentage),
                            y: .value("Field", item.field)
                        )
                        .foregroundStyle(color.gradient)
                    } else {
                        BarMark(
                            x: .value("Field", item.field),
                            y: .value("Percentage", item.percentage)
                        )
                        .foregroundStyle(color.gradient)
                    }
                }
                .frame(height: 150)
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if isHorizontal, let percentage = value.as(Double.self) {
                                Text("\(Int(percentage))%")
                                    .font(.caption)
                            } else {
                                Text(verbatim: "\(value)")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if !isHorizontal, let percentage = value.as(Double.self) {
                                Text("\(Int(percentage))%")
                                    .font(.caption)
                            } else {
                                Text(verbatim: "\(value)")
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Reusable Line Chart
struct ReusableLineChart: View {
    let data: [TimeSeriesData]
    let color: Color
    let showPoints: Bool

    init(data: [TimeSeriesData], color: Color = .blue, showPoints: Bool = true) {
        self.data = data
        self.color = color
        self.showPoints = showPoints
    }

    var body: some View {
        Group {
            if data.isEmpty {
                ContentUnavailableView(
                    "No Timeline Data",
                    systemImage: "chart.line.uptrend.xyaxis",
                    description: Text("Timeline will appear when data is available")
                )
                .frame(height: 150)
            } else {
                Chart(data) { item in
                    LineMark(
                        x: .value("Period", item.period),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(color)
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    if showPoints {
                        PointMark(
                            x: .value("Period", item.period),
                            y: .value("Count", item.count)
                        )
                        .foregroundStyle(color)
                    }
                }
                .frame(height: 150)
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                            .font(.caption)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.caption)
                    }
                }
            }
        }
    }
}

// MARK: - Quick Stats Grid
struct QuickStatsGrid: View {
    let stats: [QuickStat]

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(stats) { stat in
                QuickStatCard(stat: stat)
            }
        }
    }
}

struct QuickStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
    let color: Color

    init(title: String, value: String, icon: String, color: Color) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
    }
}

struct QuickStatCard: View {
    let stat: QuickStat

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: stat.icon)
                .font(.title3)
                .foregroundStyle(stat.color)

            Text(stat.value)
                .font(.title3)
                .fontWeight(.semibold)

            Text(stat.title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
