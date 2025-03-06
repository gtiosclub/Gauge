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
    @EnvironmentObject var userVM: UserFirebase  // Shared environment object for user data
    @Environment(\.dismiss) var dismiss          // To dismiss the view
    
    // Local states
    @State private var username: String = ""
    @State private var showingPhotoOptions = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var profileImage: UIImage?
    
    var body: some View {
        VStack {
            // Profile Image and Photo Options
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
                    showingPhotoOptions = true
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
            .confirmationDialog(
                "Do you want to change your profile picture?",
                isPresented: $showingPhotoOptions,
                titleVisibility: .visible
            ) {
                Button("Choose from library") {
                    showingImagePicker = true
                }
                Button("Remove current picture", role: .destructive) {
                    profileImage = nil
                    selectedImage = nil
                }
                Button("Cancel", role: .cancel) { }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
            .onChange(of: selectedImage) { oldImage, newImage in
                if let newImage = newImage {
                    profileImage = newImage
                }
            }
            
            Spacer().frame(height: 50)
            
            // Form Content
            VStack(alignment: .leading, spacing: 10) {
                // Username Field
                HStack(spacing: 20) {
                    Text("Username")
                        .frame(width: 80, alignment: .leading)
                    TextField("new username", text: $username)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.primary)
                }
                .padding(.leading, 20)
                .padding(.vertical, 5)
                Divider()
                // Pronouns Field
                HStack(spacing: 20) {
                    Text("Pronouns")
                        .frame(width: 80, alignment: .leading)
                    TextField("Pronouns", text: $username)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.primary)
                }
                .padding(.leading, 20)
                .padding(.vertical, 5)
                Divider()
                // Bio Field
                HStack(spacing: 20) {
                    Text("Bio")
                        .frame(width: 80, alignment: .leading)
                    TextField("a short bio that describes the user", text: $username)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.primary)
                }
                .padding(.leading, 20)
                .padding(.vertical, 5)
                Divider()
                // User Tags NavigationLink
                HStack {
                    Text("User Tags")
                    Spacer()
                    NavigationLink(destination: Text("User Tags Screen")) {
                        HStack {
                            Text("4")
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
                Divider()
                // Badges NavigationLink
                HStack {
                    Text("Badges")
                    Spacer()
                    NavigationLink(destination: Text("Badges Screen")) {
                        HStack {
                            Text("5")
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            
        }
        .task {
            profileImage = await profileViewModel.getProfilePicture(userID: userVM.user.userId)
        }

        .navigationBarBackButtonHidden(true)
        .toolbar {
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

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    Task {
                        if profileImage == nil {
                            let _ = await profileViewModel.removeProfilePicture(userID: userVM.user.userId)
                        } else if let newImage = selectedImage {
                            if let newPhotoURL = await profileViewModel.updateProfilePicture(userID: userVM.user.userId, image: newImage) {
                                userVM.user.profilePhoto = newPhotoURL
                            }
                        }
                        dismiss()
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
