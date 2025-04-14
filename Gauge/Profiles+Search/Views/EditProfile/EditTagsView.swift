struct EditTagsView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    // An array of tuples with the attribute key and the title.
    let attributes: [(key: String, title: String)] = [
        ("gender", "Gender"),
        ("location", "Location"),
        ("height", "Height"),
        ("relationshipStatus", "Relationship Status"),
        ("workStatus", "Work Status"),
        ("age", "Age")
    ]
    
    var body: some View {
        List(attributes, id: \.key) { attribute in
            NavigationLink(destination: EditAttributeDetailView(attributeKey: attribute.key,
                                                                 attributeTitle: attribute.title,
                                                                 currentValue: profileViewModel.tempAttributes[attribute.key] ?? "",
                                                                 profileViewModel: profileViewModel)) {
                HStack {
                    Text(attribute.title)
                    Spacer()
                    Text(profileViewModel.tempAttributes[attribute.key] ?? "")
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("User Tags")
    }
}