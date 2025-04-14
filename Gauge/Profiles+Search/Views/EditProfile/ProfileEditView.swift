////
////  ProfileEditView.swift
////  Gauge
////
////  Created by Sam Orouji on 2/25/25.
////
////
import SwiftUI

struct ProfileEditView: View {
    @StateObject var profileViewModel = ProfileViewModel()
    @EnvironmentObject var userVM: UserFirebase  // Shared user data
    @Environment(\.dismiss) var dismiss
    
    // Local states for fields on the main screen:
    @State private var username: String = ""
    @State private var pronouns: String = ""
    @State private var bio: String = ""
    
    // Profile picture states:
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var profileImage: UIImage?
    
    var body: some View {
        VStack {
            // Profile picture section.
            ZStack {
                if let profileImage = profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 150, height: 150)
                }
            }
            .overlay(
                Button {
                    showingImagePicker = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 30, height: 30)
                        Image(systemName: "pencil")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .padding(8),
                alignment: .bottomTrailing
            )
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
            .onChange(of: selectedImage) { newImage in
                if let newImage = newImage {
                    profileImage = newImage
                }
            }
            
            Spacer().frame(height: 50)
            
            // Main form fields.
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Username").frame(width: 80, alignment: .leading)
                    TextField("Enter username", text: $username)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                Divider()
                HStack {
                    Text("Pronouns").frame(width: 80, alignment: .leading)
                    TextField("Enter pronouns", text: $pronouns)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                Divider()
                HStack {
                    Text("Bio").frame(width: 80, alignment: .leading)
                    TextField("Enter your bio", text: $bio)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                Divider()
            }
            .padding(.horizontal, 20)
            
            // Navigation link to EditTagsView.
            NavigationLink(destination: EditTagsView(profileViewModel: profileViewModel)) {
                HStack {
                    Text("User Tags")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            
            Spacer()
        }
        .onAppear {
            // Prepopulate fields from current user data.
             let currentUser = userVM.user
                username = currentUser.username
                pronouns = currentUser.attributes["pronouns"] ?? ""
                bio = currentUser.attributes["bio"] ?? ""
                Task {
                    profileImage = await profileViewModel.getProfilePicture(userID: currentUser.userId)
                }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Cancel button.
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Cancel")
                    }
                }
            }
            // Save button.
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    Task {
                        let userID = userVM.user.userId
                        let success = await profileViewModel.updateProfilePhotoAndAttributes(userID: userID,
                                                                                            username: username,
                                                                                            bio: bio,
                                                                                            pronouns: pronouns,
                                                                                            profileImage: selectedImage)
                        if success {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileEditView()
        .environmentObject(UserFirebase())
}


struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
