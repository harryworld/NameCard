import SwiftUI
import SwiftData

struct PeopleListView: View {
    let people = Person.sampleData
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [ContactCategory]
    @Query private var allContacts: [StoredContact]

    @Binding var navigationPath: NavigationPath

    @State private var showingAddContact = false
    @State private var showingAddCategory = false
    @State private var showingDeleteAlert = false
    @State private var categoryToDelete: ContactCategory?
    
    var teachersSorted: [Person] {
        people.filter { $0.type == .teacher }.sorted { $0.name < $1.name }
    }
    
    var studentsSorted: [Person] {
        people.filter { $0.type == .student }.sorted { $0.name < $1.name }
    }

    var categoriesSorted: [ContactCategory] {
        categories.sorted { $0.name < $1.name }
    }

    var uncategorizedContacts: [StoredContact] {
        allContacts.filter { $0.category == nil }.sorted { $0.fullName < $1.fullName }
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                Section("Teachers") {
                    ForEach(teachersSorted) { person in
                        NavigationLink(destination: PersonDetailView(person: person)) {
                            PersonRowView(person: person)
                        }
                    }
                }
                
                Section("Students") {
                    ForEach(studentsSorted) { person in
                        NavigationLink(destination: PersonDetailView(person: person)) {
                            PersonRowView(person: person)
                        }
                    }
                }

                Section {
                    ForEach(categoriesSorted, id: \.id) { category in
                        NavigationLink(destination: CategoryContactsView(category: category)) {
                            CategoryRowView(category: category)
                        }
                    }
                    .onDelete(perform: deleteCategory)

                    if !uncategorizedContacts.isEmpty {
                        NavigationLink(destination: UncategorizedContactsView()) {
                            HStack {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 12, height: 12)

                                VStack(alignment: .leading) {
                                    Text("Uncategorized")
                                        .font(.headline)
                                    Text("\(uncategorizedContacts.count) contact\(uncategorizedContacts.count == 1 ? "" : "s")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Contacts")
                        Spacer()
                        Menu {
                            Button {
                                showingAddContact = true
                            } label: {
                                Label("Add Contact", systemImage: "person.badge.plus")
                            }

                            Button {
                                showingAddCategory = true
                            } label: {
                                Label("Add Category", systemImage: "folder.badge.plus")
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Directory")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        navigationPath.append("statistics")
                    } label: {
                        Image(systemName: "chart.bar")
                            .foregroundStyle(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddContact) {
                AddContactView()
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView()
            }
            .alert("Delete Category", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let category = categoryToDelete {
                        deleteCategoryAndMoveContacts(category)
                        categoryToDelete = nil
                    }
                }
                Button("Cancel", role: .cancel) {
                    categoryToDelete = nil
                }
            } message: {
                if let category = categoryToDelete {
                    let contactCount = category.contactCount
                    if contactCount == 0 {
                        Text("Are you sure you want to delete the \"\(category.name)\" category?")
                    } else {
                        Text("Are you sure you want to delete the \"\(category.name)\" category? \(contactCount) contact\(contactCount == 1 ? "" : "s") will be moved to Uncategorized.")
                    }
                }
            }
            .navigationDestination(for: ContactCategory.self) { category in
                // TODO: CategoryContactsView(category: category)
            }
            .navigationDestination(for: StoredContact.self) { contact in
                // TODO: StoredContactDetailView(contact: contact)
            }
            .navigationDestination(for: String.self) { destination in
                if destination == "statistics" {
                    // TODO: StatisticsView()
                }
            }
        }
    }

    private func deleteCategory(offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let category = categoriesSorted[index]
        categoryToDelete = category
        showingDeleteAlert = true
    }

    private func deleteCategoryAndMoveContacts(_ category: ContactCategory) {
        // Delete the category
        modelContext.delete(category)
        try? modelContext.save()
    }
}

struct PersonRowView: View {
    let person: Person
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(person.name)
                    .font(.headline)
                Text(person.type.rawValue.dropLast())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if person.contact != nil {
                Image(systemName: "person.crop.rectangle")
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 2)
    }
}

struct PersonDetailView: View {
    let person: Person
    
    var body: some View {
        Group {
            if let contact = person.contact {
                // Route to appropriate name card view based on person's name
                switch person.name.lowercased() {
                case "harry":
                    HarryView(contact: contact)
                case "roger":
                    RogerView(contact: contact)
                case "Zoe":
                    ZoeView(contact: contact)  
                default:
                    if let nameCard = person.nameCard {
                        AnyView(nameCard)
                    } else {
                        HarryView(contact: contact) // Default fallback
                    }
                }
            } else {
                VStack {
                    Image(systemName: "person.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.gray)
                    Text(person.name)
                        .font(.largeTitle)
                        .padding()
                    Text("No name card available")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        }
        .navigationTitle(person.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CategoryRowView: View {
    let category: ContactCategory

    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: category.colorHex))
                .frame(width: 12, height: 12)

            VStack(alignment: .leading) {
                Text(category.name)
                    .font(.headline)
                Text("\(category.contactCount) contact\(category.contactCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

struct UncategorizedContactsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allContacts: [StoredContact]
    @State private var showingAddContact = false

    private var uncategorizedContacts: [StoredContact] {
        allContacts.filter { $0.category == nil }
            .sorted { $0.fullName < $1.fullName }
    }

    var body: some View {
        List {
            if uncategorizedContacts.isEmpty {
                ContentUnavailableView(
                    "No Uncategorized Contacts",
                    systemImage: "person.slash",
                    description: Text("All contacts have been assigned to categories")
                )
            } else {
                ForEach(uncategorizedContacts) { contact in
                    NavigationLink(destination: StoredContactDetailView(contact: contact)) {
                        StoredContactRowView(contact: contact)
                    }
                }
                .onDelete(perform: deleteContacts)
            }
        }
        .navigationTitle("Uncategorized")
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
            modelContext.delete(uncategorizedContacts[index])
        }
        try? modelContext.save()
    }
}

#Preview {
    PeopleListView(navigationPath: .constant(NavigationPath()))
}
