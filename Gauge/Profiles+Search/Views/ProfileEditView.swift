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
    let userID: String
    
    // Local states
    @State private var username: String = ""
    @State private var showingPhotoOptions = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var profileImage: UIImage?
    
    var body: some View {
        VStack {
            // Navigation Bar Section
            Section {
                HStack {
                    Button("Cancel") {
                        // Dismiss or pop the view
                    }
                    Spacer()
                    Button("Save") {
                        Task {
                            if profileImage == nil {
                                let _ = await profileViewModel.removeProfilePicture(userID: userID)
                            } else if let newImage = selectedImage {
                                await profileViewModel.updateProfilePicture(userID: userID, image: newImage)
                            }
                            // add additional updates for username or other fields here
                        }
                    }
                }
                .padding(.horizontal)
            }
            
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
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
            .onChange(of: selectedImage) { newImage in
                if let newImage = newImage {
                    profileImage = newImage
                }
            }
            
            Spacer().frame(height: 50)
            
            VStack(alignment: .leading, spacing: 10) {
                // Username
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
                // Pronouns
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
                               
               // Bio
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
                               
               // User Tags
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
                               
               // Badges
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
            
            Divider()
            HStack {
                VStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                    Text("Tab Name")
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                }
                Spacer()
                VStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                    Text("Tab Name")
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                }
                Spacer()
                VStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                    Text("Profile")
                        .foregroundColor(.blue)
                        .font(.system(size: 12))
                }
            }
            .padding(.horizontal, 40)
        }
        .task {
            profileImage = await profileViewModel.getProfilePicture(userID: userID)
        }
    }
}

#Preview {
    ProfileEditView(userID: "xEZWt93AaJZPwfHAjlqMjmVP0Lz1")
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
