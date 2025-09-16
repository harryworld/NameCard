import Foundation
import SwiftData

struct SeedData {

    // MARK: - Categories Seed Data
    static func seedCategories() -> [ContactCategory] {
        return [
            ContactCategory(name: "Work", colorHex: "007AFF"),
            ContactCategory(name: "Family", colorHex: "FF3B30"),
            ContactCategory(name: "Friends", colorHex: "34C759"),
            ContactCategory(name: "Clients", colorHex: "FF9500"),
            ContactCategory(name: "Vendors", colorHex: "AF52DE"),
            ContactCategory(name: "Medical", colorHex: "FF2D92"),
            ContactCategory(name: "Education", colorHex: "5856D6"),
            ContactCategory(name: "Services", colorHex: "00C7BE")
        ]
    }

    // MARK: - Contacts Seed Data
    static func seedContacts(categories: [ContactCategory]) -> [StoredContact] {
        var contacts: [StoredContact] = []
        let calendar = Calendar.current

        // Work Category Contacts
        if let workCategory = categories.first(where: { $0.name == "Work" }) {
            contacts.append(contentsOf: [
                StoredContact(
                    firstName: "John",
                    lastName: "Smith",
                    title: "Software Engineer",
                    organization: "TechCorp Inc.",
                    email: "john.smith@techcorp.com",
                    phone: "+1-555-0101",
                    address: "123 Tech Street, San Francisco, CA 94102",
                    website: "https://techcorp.com",
                    department: "Engineering",
                    category: workCategory
                ),
                StoredContact(
                    firstName: "Sarah",
                    lastName: "Johnson",
                    title: "Product Manager",
                    organization: "InnovateX",
                    email: "sarah.j@innovatex.com",
                    phone: "+1-555-0102",
                    address: "456 Innovation Ave, Austin, TX 78701",
                    website: "https://innovatex.com",
                    department: "Product",
                    category: workCategory
                ),
                StoredContact(
                    firstName: "Michael",
                    lastName: "Chen",
                    title: "DevOps Engineer",
                    organization: "CloudTech Solutions",
                    email: "m.chen@cloudtech.io",
                    phone: "+1-555-0103",
                    address: "789 Cloud Lane, Seattle, WA 98101",
                    website: "https://cloudtech.io",
                    department: "Infrastructure",
                    category: workCategory
                )
            ])
        }

        // Family Category Contacts
        if let familyCategory = categories.first(where: { $0.name == "Family" }) {
            contacts.append(contentsOf: [
                StoredContact(
                    firstName: "Mom",
                    lastName: "Davis",
                    title: "",
                    organization: "",
                    email: "mom@family.com",
                    phone: "+1-555-0201",
                    address: "321 Family Street, Portland, OR 97201",
                    website: "",
                    department: "",
                    category: familyCategory
                ),
                StoredContact(
                    firstName: "Dad",
                    lastName: "Davis",
                    title: "",
                    organization: "",
                    email: "dad@family.com",
                    phone: "+1-555-0202",
                    address: "321 Family Street, Portland, OR 97201",
                    website: "",
                    department: "",
                    category: familyCategory
                ),
                StoredContact(
                    firstName: "Emma",
                    lastName: "Davis",
                    title: "",
                    organization: "",
                    email: "emma.davis@email.com",
                    phone: "+1-555-0203",
                    address: "654 College Ave, Boston, MA 02101",
                    website: "",
                    department: "",
                    category: familyCategory
                )
            ])
        }

        // Friends Category Contacts
        if let friendsCategory = categories.first(where: { $0.name == "Friends" }) {
            contacts.append(contentsOf: [
                StoredContact(
                    firstName: "Alex",
                    lastName: "Turner",
                    title: "Graphic Designer",
                    organization: "Creative Studio",
                    email: "alex.turner@gmail.com",
                    phone: "+1-555-0301",
                    address: "987 Art District, Los Angeles, CA 90210",
                    website: "https://alexturner.design",
                    department: "",
                    category: friendsCategory
                ),
                StoredContact(
                    firstName: "Jessica",
                    lastName: "Wilson",
                    title: "Marketing Specialist",
                    organization: "BrandCo",
                    email: "jess.wilson@brandco.com",
                    phone: "+1-555-0302",
                    address: "147 Marketing Blvd, New York, NY 10001",
                    website: "",
                    department: "",
                    category: friendsCategory
                )
            ])
        }

        // Clients Category Contacts
        if let clientsCategory = categories.first(where: { $0.name == "Clients" }) {
            contacts.append(contentsOf: [
                StoredContact(
                    firstName: "Robert",
                    lastName: "Anderson",
                    title: "CEO",
                    organization: "StartupVenture",
                    email: "robert@startupventure.com",
                    phone: "+1-555-0401",
                    address: "258 Startup Lane, San Jose, CA 95101",
                    website: "https://startupventure.com",
                    department: "Executive",
                    category: clientsCategory
                ),
                StoredContact(
                    firstName: "Linda",
                    lastName: "Brown",
                    title: "Operations Director",
                    organization: "MegaCorp",
                    email: "l.brown@megacorp.com",
                    phone: "+1-555-0402",
                    address: "369 Corporate Plaza, Chicago, IL 60601",
                    website: "https://megacorp.com",
                    department: "Operations",
                    category: clientsCategory
                )
            ])
        }

        // Vendors Category Contacts
        if let vendorsCategory = categories.first(where: { $0.name == "Vendors" }) {
            contacts.append(contentsOf: [
                StoredContact(
                    firstName: "David",
                    lastName: "Kim",
                    title: "Account Manager",
                    organization: "SupplyChain Pro",
                    email: "david.kim@supplychain.com",
                    phone: "+1-555-0501",
                    address: "741 Supply Street, Denver, CO 80201",
                    website: "https://supplychainpro.com",
                    department: "Sales",
                    category: vendorsCategory
                )
            ])
        }

        // Medical Category Contacts
        if let medicalCategory = categories.first(where: { $0.name == "Medical" }) {
            contacts.append(contentsOf: [
                StoredContact(
                    firstName: "Dr. Maria",
                    lastName: "Garcia",
                    title: "Primary Care Physician",
                    organization: "HealthCare Clinic",
                    email: "dr.garcia@healthcare.com",
                    phone: "+1-555-0601",
                    address: "852 Health Ave, Miami, FL 33101",
                    website: "https://healthcareclinic.com",
                    department: "Internal Medicine",
                    category: medicalCategory
                ),
                StoredContact(
                    firstName: "Dr. James",
                    lastName: "Thompson",
                    title: "Dentist",
                    organization: "Smile Dental",
                    email: "dr.thompson@smiledental.com",
                    phone: "+1-555-0602",
                    address: "963 Dental Drive, Phoenix, AZ 85001",
                    website: "https://smiledental.com",
                    department: "Dentistry",
                    category: medicalCategory
                )
            ])
        }

        // Education Category Contacts
        if let educationCategory = categories.first(where: { $0.name == "Education" }) {
            contacts.append(contentsOf: [
                StoredContact(
                    firstName: "Professor Lisa",
                    lastName: "Martinez",
                    title: "Computer Science Professor",
                    organization: "State University",
                    email: "l.martinez@stateuni.edu",
                    phone: "+1-555-0701",
                    address: "174 University Circle, Atlanta, GA 30301",
                    website: "https://stateuni.edu",
                    department: "Computer Science",
                    category: educationCategory
                )
            ])
        }

        // Services Category Contacts
        if let servicesCategory = categories.first(where: { $0.name == "Services" }) {
            contacts.append(contentsOf: [
                StoredContact(
                    firstName: "Tom",
                    lastName: "Wilson",
                    title: "Plumber",
                    organization: "Quick Fix Services",
                    email: "tom@quickfixservices.com",
                    phone: "+1-555-0801",
                    address: "285 Service Road, Houston, TX 77001",
                    website: "",
                    department: "",
                    category: servicesCategory
                )
            ])
        }

        // Add some uncategorized contacts
        contacts.append(contentsOf: [
            StoredContact(
                firstName: "Anna",
                lastName: "Taylor",
                title: "Freelance Writer",
                organization: "",
                email: "anna.taylor@writer.com",
                phone: "+1-555-0901",
                address: "396 Creative Street, Nashville, TN 37201",
                website: "https://annataylor.blog",
                department: "",
                category: nil
            ),
            StoredContact(
                firstName: "Mark",
                lastName: "Johnson",
                title: "Photographer",
                organization: "Johnson Photography",
                email: "mark@johnsonphoto.com",
                phone: "+1-555-0902",
                address: "507 Photo Lane, Minneapolis, MN 55401",
                website: "https://johnsonphoto.com",
                department: "",
                category: nil
            )
        ])

        // Set varied creation dates for timeline charts
        for (index, contact) in contacts.enumerated() {
            let daysAgo = index * 7 + Int.random(in: 0...6) // Spread over weeks with some randomness
            if let pastDate = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
                contact.dateAdded = pastDate
            }
        }

        return contacts
    }

    // MARK: - Seed Data Insertion
    static func insertSeedData(into modelContext: ModelContext) {
        // Check if data already exists
        let categoryDescriptor = FetchDescriptor<ContactCategory>()
        let contactDescriptor = FetchDescriptor<StoredContact>()

        do {
            let existingCategories = try modelContext.fetch(categoryDescriptor)
            let existingContacts = try modelContext.fetch(contactDescriptor)

            // Only insert if no data exists
            if existingCategories.isEmpty && existingContacts.isEmpty {
                let categories = seedCategories()
                let contacts = seedContacts(categories: categories)

                // Insert categories first
                for category in categories {
                    modelContext.insert(category)
                }

                // Insert contacts
                for contact in contacts {
                    modelContext.insert(contact)
                }

                try modelContext.save()
                print("✅ Seed data inserted successfully")
            } else {
                print("ℹ️ Seed data already exists, skipping insertion")
            }
        } catch {
            print("❌ Error inserting seed data: \(error)")
        }
    }
}