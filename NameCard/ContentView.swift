//
//  ContentView.swift
//  NameCard
//
//  Created by Harry Ng on 9/8/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var navigationPath = NavigationPath()

    var body: some View {
        PeopleListView(navigationPath: $navigationPath)
            .onOpenURL { url in
                handleDeepLink(url)
            }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "namecard" else {
            print("❌ Invalid deep link URL: \(url)")
            return
        }

        // Handle different deep link types
        switch url.host {
        case "contact":
            handleContactDeepLink(url)
        case "statistics":
            handleStatisticsDeepLink()
        default:
            print("❌ Unknown deep link host: \(url.host ?? "nil")")
        }
    }

    private func handleContactDeepLink(_ url: URL) {
        // Deep link format: namecard://contact/{uuid}
        let uuidString = url.lastPathComponent
        guard !uuidString.isEmpty,
              let uuid = UUID(uuidString: uuidString) else {
            print("❌ Invalid UUID in URL: \(url)")
            return
        }

        print("✅ Contact deep link received: \(uuid)")

        // Find the contact
        let descriptor = FetchDescriptor<StoredContact>(
            predicate: #Predicate { $0.id == uuid }
        )

        do {
            let contacts = try modelContext.fetch(descriptor)
            if let contact = contacts.first {
                print("✅ Found contact: \(contact.fullName)")

                // Clear existing path and navigate to contact
                navigationPath.removeLast(navigationPath.count)

                // First append category if exists, then the contact
                if let category = contact.category {
                    navigationPath.append(category)
                }
                navigationPath.append(contact)
            } else {
                print("❌ Contact not found for ID: \(uuid)")
            }
        } catch {
            print("❌ Error fetching contact: \(error)")
        }
    }

    private func handleStatisticsDeepLink() {
        // Deep link format: namecard://statistics
        print("✅ Statistics deep link received")

        // Clear existing path and navigate to statistics
        navigationPath.removeLast(navigationPath.count)
        navigationPath.append("statistics")
    }
}

#Preview {
    ContentView()
}
