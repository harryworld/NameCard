import SwiftUI
import SwiftData
import Charts

struct CategoryContactsView: View {
    let category: ContactCategory
    @Environment(\.modelContext) private var modelContext

    @Query private var allContacts: [StoredContact]
    @State private var showingAddContact = false

    private var categoryContacts: [StoredContact] {
        allContacts.filter { $0.category?.id == category.id }
            .sorted { $0.fullName < $1.fullName }
    }

    var body: some View {
        List {
            if !categoryContacts.isEmpty {
                Section {
                    CategoryStatsSection(contacts: categoryContacts, category: category)
                } header: {
                    Text("Analytics")
                }
            }

            Section {
                if categoryContacts.isEmpty {
                    ContentUnavailableView(
                        "No Contacts",
                        systemImage: "person.slash",
                        description: Text("Add contacts to \(category.name) category")
                    )
                } else {
                    ForEach(categoryContacts) { contact in
                        NavigationLink(destination: StoredContactDetailView(contact: contact)) {
                            StoredContactRowView(contact: contact)
                        }
                    }
                    .onDelete(perform: deleteContacts)
                }
            } header: {
                Text("Contacts (\(categoryContacts.count))")
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddContact = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddContact) {
            AddContactView()
        }
    }

    private func deleteContacts(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(categoryContacts[index])
        }
        try? modelContext.save()
    }
}

struct StoredContactRowView: View {
    let contact: StoredContact

    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: contact.category?.colorHex ?? "007AFF"))
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 2) {
                Text(contact.fullName)
                    .font(.headline)

                if !contact.title.isEmpty {
                    Text(contact.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !contact.organization.isEmpty {
                    Text(contact.organization)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            VStack {
                if !contact.email.isEmpty {
                    Image(systemName: "envelope")
                        .foregroundStyle(.blue)
                        .font(.caption)
                }
                if !contact.phone.isEmpty {
                    Image(systemName: "phone")
                        .foregroundStyle(.green)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

struct CategoryStatsSection: View {
    let contacts: [StoredContact]
    let category: ContactCategory

    var body: some View {
        VStack(spacing: 16) {
            // Contacts added over time for this category
            ContactsTimelineChart(contacts: contacts, category: category)

            // Field completeness for this category
            CategoryFieldCompletenessChart(contacts: contacts)
        }
        .padding(.vertical, 8)
    }
}

struct ContactsTimelineChart: View {
    let contacts: [StoredContact]
    let category: ContactCategory

    private var timelineData: [TimeSeriesData] {
        contacts.contactsAddedOverTime()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Contacts Added Over Time")
                .font(.subheadline)
                .fontWeight(.medium)

            if timelineData.isEmpty {
                Text("No timeline data available")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(height: 100)
            } else {
                Chart(timelineData) { item in
                    LineMark(
                        x: .value("Period", item.period),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(Color(hex: category.colorHex))
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    PointMark(
                        x: .value("Period", item.period),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(Color(hex: category.colorHex))
                }
                .frame(height: 100)
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                            .font(.caption2)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.caption2)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct CategoryFieldCompletenessChart: View {
    let contacts: [StoredContact]

    private var completenessData: [FieldCompletenessData] {
        contacts.fieldCompleteness()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Information Completeness")
                .font(.subheadline)
                .fontWeight(.medium)

            if completenessData.isEmpty {
                Text("No field data available")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(height: 80)
            } else {
                Chart(completenessData) { item in
                    BarMark(
                        x: .value("Percentage", item.percentage),
                        y: .value("Field", item.field)
                    )
                    .foregroundStyle(.cyan.opacity(0.7))
                }
                .frame(height: 120)
                .chartXAxis {
                    AxisMarks(position: .bottom) { value in
                        AxisValueLabel {
                            if let percentage = value.as(Double.self) {
                                Text("\(Int(percentage))%")
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                            .font(.caption2)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
