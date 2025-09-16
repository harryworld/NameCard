import Foundation
import Charts

struct CategoryData: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
    let color: String

    init(category: ContactCategory) {
        self.name = category.name
        self.count = category.contactCount
        self.color = category.colorHex
    }
}

struct TimeSeriesData: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
    let period: String

    init(date: Date, count: Int) {
        self.date = date
        self.count = count

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        self.period = formatter.string(from: date)
    }
}

struct ContactTypeData: Identifiable {
    let id = UUID()
    let type: String
    let count: Int

    init(type: String, count: Int) {
        self.type = type
        self.count = count
    }
}

struct FieldCompletenessData: Identifiable {
    let id = UUID()
    let field: String
    let completedCount: Int
    let totalCount: Int

    var percentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount) * 100
    }

    init(field: String, completedCount: Int, totalCount: Int) {
        self.field = field
        self.completedCount = completedCount
        self.totalCount = totalCount
    }
}

extension Array where Element == StoredContact {
    func categoryDistribution(categories: [ContactCategory]) -> [CategoryData] {
        let categorizedContacts = categories.map { CategoryData(category: $0) }
        let uncategorizedCount = self.filter { $0.category == nil }.count

        var result = categorizedContacts
        if uncategorizedCount > 0 {
            result.append(CategoryData(
                category: ContactCategory(name: "Uncategorized", colorHex: "999999")
            ))
        }

        return result.filter { $0.count > 0 }
    }

    func contactsAddedOverTime() -> [TimeSeriesData] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: self) { contact in
            calendar.dateInterval(of: .month, for: contact.dateAdded)?.start ?? contact.dateAdded
        }

        return grouped.map { date, contacts in
            TimeSeriesData(date: date, count: contacts.count)
        }.sorted { $0.date < $1.date }
    }

    func fieldCompleteness() -> [FieldCompletenessData] {
        let totalCount = self.count
        guard totalCount > 0 else { return [] }

        return [
            FieldCompletenessData(
                field: "Email",
                completedCount: self.filter { !$0.email.isEmpty }.count,
                totalCount: totalCount
            ),
            FieldCompletenessData(
                field: "Phone",
                completedCount: self.filter { !$0.phone.isEmpty }.count,
                totalCount: totalCount
            ),
            FieldCompletenessData(
                field: "Organization",
                completedCount: self.filter { !$0.organization.isEmpty }.count,
                totalCount: totalCount
            ),
            FieldCompletenessData(
                field: "Website",
                completedCount: self.filter { !$0.website.isEmpty }.count,
                totalCount: totalCount
            ),
            FieldCompletenessData(
                field: "Address",
                completedCount: self.filter { !$0.address.isEmpty }.count,
                totalCount: totalCount
            )
        ]
    }
}

extension Array where Element == Person {
    func typeDistribution() -> [ContactTypeData] {
        let grouped = Dictionary(grouping: self) { $0.type }

        return grouped.map { type, people in
            ContactTypeData(type: String(type.rawValue.dropLast()), count: people.count)
        }.sorted { $0.type < $1.type }
    }
}