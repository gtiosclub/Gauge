import SwiftUI

struct TagsView: View {
    @Environment(\.dismiss) private var dismiss
    
    let tags: [(title: String, value: String, placeholder: String)] = [
        ("Gender", "gender", "username's gender"),
        ("Location", "Atlanta", "username's location"),
        ("Height", "5'9", "username's height"),
        ("Relationship Status", "Single", "username's relationship status"),
        ("Work Status", "In College", "username's work status"),
        ("Age", "20", "username's age")
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tags, id: \.title) { tag in
                    NavigationLink(destination: TagEditView(title: tag.title, value: tag.value, placeholder: tag.placeholder)) {
                        HStack {
                            Text(tag.title)
                            Spacer()
                            Text(tag.value)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct TagsView_Previews: PreviewProvider {
    static var previews: some View {
        TagsView()
    }
}
