import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [ContactCategory]
    @Query private var allContacts: [StoredContact]

    let people = Person.sampleData

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Contact Distribution by Category
                CategoryDistributionChart(
                    data: allContacts.categoryDistribution(categories: categories)
                )

                // Contacts Added Over Time
                ContactsOverTimeChart(
                    data: allContacts.contactsAddedOverTime()
                )

                // Teachers vs Students
                PersonTypeDistributionChart(
                    data: people.typeDistribution()
                )

                // Field Completeness
                FieldCompletenessChart(
                    data: allContacts.fieldCompleteness()
                )

                // Summary Stats
                SummaryStatsView(
                    totalContacts: allContacts.count,
                    totalCategories: categories.count,
                    teachersCount: people.filter { $0.type == .teacher }.count,
                    studentsCount: people.filter { $0.type == .student }.count
                )
            }
            .padding()
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct CategoryDistributionChart: View {
    let data: [CategoryData]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact Distribution")
                .font(.headline)
                .foregroundStyle(.primary)

            if data.isEmpty {
                ContentUnavailableView(
                    "No Contacts",
                    systemImage: "chart.pie",
                    description: Text("Add some contacts to see distribution")
                )
                .frame(height: 200)
            } else {
                Chart(data) { item in
                    SectorMark(
                        angle: .value("Count", item.count),
                        innerRadius: .ratio(0.4),
                        angularInset: 1.5
                    )
                    .foregroundStyle(Color(hex: item.color))
                    .opacity(0.8)
                }
                .frame(height: 200)
                .chartLegend(position: .bottom, alignment: .center)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ContactsOverTimeChart: View {
    let data: [TimeSeriesData]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contacts Added Over Time")
                .font(.headline)
                .foregroundStyle(.primary)

            if data.isEmpty {
                ContentUnavailableView(
                    "No Time Data",
                    systemImage: "chart.line.uptrend.xyaxis",
                    description: Text("Contact history will appear here")
                )
                .frame(height: 200)
            } else {
                Chart(data) { item in
                    BarMark(
                        x: .value("Period", item.period),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(.blue.gradient)
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct PersonTypeDistributionChart: View {
    let data: [ContactTypeData]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Teachers vs Students")
                .font(.headline)
                .foregroundStyle(.primary)

            if data.isEmpty {
                ContentUnavailableView(
                    "No Directory Data",
                    systemImage: "person.2",
                    description: Text("Directory information will appear here")
                )
                .frame(height: 200)
            } else {
                Chart(data) { item in
                    SectorMark(
                        angle: .value("Count", item.count),
                        innerRadius: .ratio(0.5)
                    )
                    .foregroundStyle(item.type == "Teacher" ? .green : .orange)
                    .opacity(0.8)
                }
                .frame(height: 200)
                .chartLegend(position: .bottom, alignment: .center)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct FieldCompletenessChart: View {
    let data: [FieldCompletenessData]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact Information Completeness")
                .font(.headline)
                .foregroundStyle(.primary)

            if data.isEmpty || data.allSatisfy({ $0.totalCount == 0 }) {
                ContentUnavailableView(
                    "No Contact Data",
                    systemImage: "chart.bar.horizontal",
                    description: Text("Contact field data will appear here")
                )
                .frame(height: 200)
            } else {
                Chart(data) { item in
                    BarMark(
                        x: .value("Percentage", item.percentage),
                        y: .value("Field", item.field)
                    )
                    .foregroundStyle(.cyan.gradient)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(position: .bottom) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let percentage = value.as(Double.self) {
                                Text("\(Int(percentage))%")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct SummaryStatsView: View {
    let totalContacts: Int
    let totalCategories: Int
    let teachersCount: Int
    let studentsCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.headline)
                .foregroundStyle(.primary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(title: "Total Contacts", value: "\(totalContacts)", icon: "person.fill", color: .blue)
                StatCard(title: "Categories", value: "\(totalCategories)", icon: "folder.fill", color: .green)
                StatCard(title: "Teachers", value: "\(teachersCount)", icon: "graduationcap.fill", color: .orange)
                StatCard(title: "Students", value: "\(studentsCount)", icon: "person.crop.square.fill", color: .purple)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// Build an in-memory SwiftData container and seed sample data for charts
let container: ModelContainer = {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: StoredContact.self, ContactCategory.self,
        configurations: configuration
    )
    let context = container.mainContext

    // Sample categories
    let friends = ContactCategory(name: "Friends", colorHex: "FF3B30")
    let work = ContactCategory(name: "Work", colorHex: "34C759")
    let family = ContactCategory(name: "Family", colorHex: "007AFF")

    context.insert(friends)
    context.insert(work)
    context.insert(family)

    // Sample contacts (some categorized, one uncategorized)
    let contacts: [StoredContact] = [
        StoredContact(
            firstName: "Alice",
            lastName: "Smith",
            title: "Engineer",
            organization: "Acme Corp",
            email: "alice@acme.com",
            phone: "555-1111",
            address: "1 Infinite Loop, Cupertino, CA",
            website: "https://acme.com",
            department: "R&D",
            category: work
        ),
        StoredContact(
            firstName: "Bob",
            lastName: "Johnson",
            title: "Designer",
            organization: "Freelance",
            email: "",
            phone: "555-2222",
            address: "",
            website: "",
            department: "",
            category: friends
        ),
        StoredContact(
            firstName: "Carol",
            lastName: "Lee",
            title: "Teacher",
            organization: "Springfield High",
            email: "carol.lee@school.edu",
            phone: "",
            address: "123 School St",
            website: "",
            department: "Math",
            category: family
        ),
        // Uncategorised contact to exercise the "Uncategorized" bucket
        StoredContact(
            firstName: "David",
            lastName: "Ng",
            title: "",
            organization: "",
            email: "david@example.com",
            phone: "",
            address: "",
            website: "",
            department: "",
            category: nil
        )
    ]

    contacts.forEach { context.insert($0) }

    return container
}()

struct WrappedPieView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [ContactCategory]
    @Query private var allContacts: [StoredContact]

    var body: some View {
        CategoryDistributionChart(
            data: allContacts.categoryDistribution(categories: categories)
        )
    }
}

#Preview("Pie Chart") {
    WrappedPieView()
        .modelContainer(container)
}

struct WrappedBarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [ContactCategory]
    @Query private var allContacts: [StoredContact]

    var body: some View {
        ContactsOverTimeChart(
            data: allContacts.contactsAddedOverTime()
        )
    }
}

#Preview("Bar Chart") {
    WrappedBarView()
        .modelContainer(container)
}

#Preview("Statistics (Seeded)") {
    StatisticsView()
        .modelContainer(container)
}
