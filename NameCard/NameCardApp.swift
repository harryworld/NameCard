//
//  NameCardApp.swift
//  NameCard
//
//  Created by Harry Ng on 9/8/25.
//

import SwiftUI
import SwiftData

@main
struct NameCardApp: App {
    // Shared model container for app and widgets
    static let sharedModelContainer: ModelContainer = {
        // TODO: App Group
        let appGroupIdentifier = "group.com.buildwithharry.NameCard"

        // TODO: SQLite
        let storeURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)!
            .appendingPathComponent("NameCard.sqlite")

        let configuration = ModelConfiguration(url: storeURL)

        do {
            return try ModelContainer(for: StoredContact.self, ContactCategory.self, configurations: configuration)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    insertSeedDataIfNeeded()
                }
        }
        .modelContainer(NameCardApp.sharedModelContainer)
    }

    private func insertSeedDataIfNeeded() {
        let modelContext = ModelContext(NameCardApp.sharedModelContainer)
        SeedData.insertSeedData(into: modelContext)
    }
}
