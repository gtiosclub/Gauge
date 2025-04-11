//
//  CategorySelectionView.swift
//  Gauge

import SwiftUI

struct CategoryGroup: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subcategories: [String]
}

private extension Category {
    static var groups: [CategoryGroup] {
        [
            CategoryGroup(title: "Sports",        subcategories: Sports.allCases.map { $0.rawValue }),
            CategoryGroup(title: "Entertainment", subcategories: Entertainment.allCases.map { $0.rawValue }),
            CategoryGroup(title: "Educational",   subcategories: Educational.allCases.map { $0.rawValue }),
            CategoryGroup(title: "News",          subcategories: News.allCases.map { $0.rawValue }),
            CategoryGroup(title: "Lifestyle",     subcategories: Lifestyle.allCases.map { $0.rawValue }),
            CategoryGroup(title: "Arts",          subcategories: Arts.allCases.map { $0.rawValue }),
            CategoryGroup(title: "Relationships", subcategories: Relationships.allCases.map { $0.rawValue }),
            CategoryGroup(title: "Other",         subcategories: Other.allCases.map { $0.rawValue })
        ]
    }
}

struct CategorySelectionView: View {
    @EnvironmentObject var authVM: AuthenticationVM

    @State private var selectedCategories: Set<String> = []
    @State private var expandedGroup: CategoryGroup? = nil
    @State private var searchText: String = ""
    @State private var showMaxAlert = false

    private let gridColumns = [GridItem(.adaptive(minimum: 160), spacing: 16)]
    private let chipColumns = [GridItem(.adaptive(minimum: 110), spacing: 8, alignment: .leading)]
    private let cardHeight: CGFloat = 200
    private let maxSelection = 20

    private var filteredGroups: [CategoryGroup] {
        guard !searchText.isEmpty else { return Category.groups }
        return Category.groups.compactMap { group in
            let filteredSubs = group.subcategories.filter { $0.localizedCaseInsensitiveContains(searchText) }
            if group.title.localizedCaseInsensitiveContains(searchText) {
                return group
            } else if !filteredSubs.isEmpty {
                return CategoryGroup(title: group.title, subcategories: filteredSubs)
            } else {
                return nil
            }
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header

                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        ForEach(filteredGroups) { group in
                            CollapsedGroupCard(group: group,
                                               chipColumns: chipColumns,
                                               selected: $selectedCategories,
                                               cardHeight: cardHeight,
                                               maxSelection: maxSelection,
                                               showMaxAlert: $showMaxAlert) {
                                withAnimation(.spring()) { expandedGroup = group }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)
                    .padding(.bottom, 140)
                }
            }
            .blur(radius: expandedGroup == nil ? 0 : 3)

            if let group = expandedGroup {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(.spring()) { expandedGroup = nil } }

                ExpandedGroupCard(group: group,
                                   chipColumns: chipColumns,
                                   selected: $selectedCategories,
                                   maxSelection: maxSelection,
                                   showMaxAlert: $showMaxAlert) {
                    withAnimation(.spring()) { expandedGroup = nil }
                }
                .padding(.horizontal, 24)
                .transition(.scale)
                .zIndex(1)
            }

            VStack { Spacer(); nextButton }.padding()
        }
        .onAppear { selectedCategories = authVM.tempUserData.selectedCategories }
        .alert("Maximum of 20 categories reached", isPresented: $showMaxAlert) {
            Button("OK", role: .cancel) {}
        }
    }

    private var header: some View {
        VStack(spacing: 16) {
            ProgressBar(progress: 5, steps: 6)
                .padding(.top, 8)

            HStack {
                Button { authVM.onboardingState = .bio } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("About You").font(.headline).bold()
                Spacer()
                Image(systemName: "chevron.left").opacity(0)
            }

            Text(selectedCategories.count < 3 ?
                 "Choose \(3 - selectedCategories.count) more categories you like." :
                 "You can choose more categories if you like.")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            CategorySearchBar(text: $searchText)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }

    private var nextButton: some View {
        Button {
            authVM.tempUserData.selectedCategories = selectedCategories
            authVM.onboardingState = .attributes
        } label: {
            Text("Next")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedCategories.count < 3 ? Color.gray.opacity(0.4) : Color.blue)
                .cornerRadius(12)
        }
        .disabled(selectedCategories.count < 3)
    }
}

private struct CollapsedGroupCard: View {
    let group: CategoryGroup
    let chipColumns: [GridItem]
    @Binding var selected: Set<String>
    let cardHeight: CGFloat
    let maxSelection: Int
    @Binding var showMaxAlert: Bool
    let onExpand: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(group.title).font(.headline)
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.gray)
            }

            LazyVGrid(columns: chipColumns, alignment: .leading, spacing: 8) {
                ForEach(group.subcategories.prefix(12), id: \ .self) { chip in
                    CategoryChip(title: chip,
                                 isSelected: selected.contains(chip)) {
                        toggle(chip)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: cardHeight, maxHeight: cardHeight)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .onTapGesture(perform: onExpand)
    }

    private func toggle(_ chip: String) {
        if selected.contains(chip) {
            selected.remove(chip)
        } else if selected.count < maxSelection {
            selected.insert(chip)
        } else {
            showMaxAlert = true
        }
    }
}

private struct ExpandedGroupCard: View {
    let group: CategoryGroup
    let chipColumns: [GridItem]
    @Binding var selected: Set<String>
    let maxSelection: Int
    @Binding var showMaxAlert: Bool
    let onCollapse: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(group.title).font(.headline)
                Spacer()
                Button(action: onCollapse) {
                    Image(systemName: "chevron.down").font(.title3).foregroundColor(.gray)
                }
            }

            LazyVGrid(columns: chipColumns, alignment: .leading, spacing: 8) {
                ForEach(group.subcategories, id: \ .self) { chip in
                    CategoryChip(title: chip,
                                 isSelected: selected.contains(chip)) {
                        toggle(chip)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 8)
    }

    private func toggle(_ chip: String) {
        if selected.contains(chip) {
            selected.remove(chip)
        } else if selected.count < maxSelection {
            selected.insert(chip)
        } else {
            showMaxAlert = true
        }
    }
}

private struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Text(title)
            .font(.subheadline)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .onTapGesture(perform: action)
    }
}

struct CategorySearchBar: View {
    @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Search", text: $text).foregroundColor(.primary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    CategorySelectionView().environmentObject(AuthenticationVM())
}
