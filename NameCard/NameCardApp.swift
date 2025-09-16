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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    insertSeedDataIfNeeded()
                }
        }
        .modelContainer(for: [StoredContact.self, ContactCategory.self])
    }

    private func insertSeedDataIfNeeded() {
        guard let modelContainer = try? ModelContainer(for: StoredContact.self, ContactCategory.self) else {
            print("Failed to create model container")
            return
        }

        let modelContext = ModelContext(modelContainer)
        SeedData.insertSeedData(into: modelContext)
    }
}
