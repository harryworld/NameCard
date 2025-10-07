import Foundation
import SwiftData

struct WidgetDataManager {
    static let shared = WidgetDataManager()

    private let modelContainer: ModelContainer

    private init() {
        // TODO: 1. 設定 App Group
        let appGroupIdentifier = "group.com.buildwithharry.NameCard"

        // TODO: 2. 設定 SQLite 位置，存放在 App Group 內
        let storeURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)!
            .appendingPathComponent("NameCard.sqlite")

        let configuration = ModelConfiguration(url: storeURL)

        do {
            modelContainer = try ModelContainer(for: StoredContact.self, ContactCategory.self, configurations: configuration)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    // MARK: - Random Contact Widget

    func getRandomContact() -> StoredContact? {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<StoredContact>()

        do {
            let contacts = try context.fetch(descriptor)
            return contacts.randomElement()
        } catch {
            print("Failed to fetch contacts: \(error)")
            return nil
        }
    }

    // MARK: - Category Distribution Widget

    func getCategoryDistribution() -> [CategoryDistributionData] {
        let context = ModelContext(modelContainer)

        let categoryDescriptor = FetchDescriptor<ContactCategory>()
        let contactDescriptor = FetchDescriptor<StoredContact>()

        do {
            let categories = try context.fetch(categoryDescriptor)
            let contacts = try context.fetch(contactDescriptor)

            var distribution: [CategoryDistributionData] = []

            // Add categorized contacts
            for category in categories {
                let count = contacts.filter { $0.category?.id == category.id }.count
                if count > 0 {
                    distribution.append(CategoryDistributionData(
                        name: category.name,
                        count: count,
                        colorHex: category.colorHex
                    ))
                }
            }

            // Add uncategorized contacts
            let uncategorizedCount = contacts.filter { $0.category == nil }.count
            if uncategorizedCount > 0 {
                distribution.append(CategoryDistributionData(
                    name: "Uncategorized",
                    count: uncategorizedCount,
                    colorHex: "999999"
                ))
            }

            return distribution
        } catch {
            print("Failed to fetch category distribution: \(error)")
            return []
        }
    }

    func getTotalContactCount() -> Int {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<StoredContact>()

        do {
            let contacts = try context.fetch(descriptor)
            return contacts.count
        } catch {
            print("Failed to fetch contact count: \(error)")
            return 0
        }
    }
}

// MARK: - Widget Data Models

struct CategoryDistributionData: Identifiable, Codable {
    var id = UUID()
    let name: String
    let count: Int
    let colorHex: String

    var percentage: Double {
        // Percentage will be calculated when total is known
        0
    }

    func percentage(of total: Int) -> Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total) * 100
    }
}
