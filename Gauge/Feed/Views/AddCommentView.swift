//
//  AddCommentView.swift
//  Gauge
//
//  Created by Yingqi Chen on 4/8/25.
//

import SwiftUI

struct CommentSheetView: View {
    @Binding var showAddComment: Bool
    @State private var commentText: String = ""
    @FocusState private var isFocused: Bool
    @State private var textEditorHeight: CGFloat = 40
    @EnvironmentObject var postVM: PostFirebase
    @EnvironmentObject var userVM: UserFirebase
    @Environment(\.modelContext) private var modelContext

    var post: any Post

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("New comment")
                    .font(.system(size: 16))
                
                Spacer()
                
                Button {
                    withAnimation {
                        showAddComment = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Circle())
                }
            }

            ZStack(alignment: .topLeading) {
                TextEditor(text: $commentText)
                    .focused($isFocused)
                    .frame(height: 60)
                    .padding(.horizontal, 8)
                    .cornerRadius(12)
                
                if commentText.isEmpty {
                    Text("What do you think?")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
            }

            Button {
                postVM.addComment(
                    postId: post.postId,
                    commentType: .text,
                    userId: userVM.user.userId,
                    content: commentText
                )
                UserResponsesManager.addCategoriesToUserResponses(modelContext: modelContext, categories: post.categories.map{$0.rawValue})
                commentText = ""
                showAddComment = false
            } label: {
                Text("Post")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(commentText.isEmpty ? Color.lightBlue : Color.darkBlue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .disabled(commentText.isEmpty)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .ignoresSafeArea(.keyboard)
        .onAppear {
            isFocused = true
        }
    }
}
