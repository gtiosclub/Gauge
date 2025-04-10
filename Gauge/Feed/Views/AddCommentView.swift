//
//  AddCommentView.swift
//  Gauge
//
//  Created by Yingqi Chen on 4/8/25.
//

import SwiftUI

struct AddCommentView: View {
    @Binding var showComment: Bool
    @State private var keyboardHeight: CGFloat = 0
    var post: any Post
    
    var body: some View {
        ZStack {
            Button(action: {
                withAnimation {
                    showComment = true
                }
                
            }) {
                Text("testing")
                    .foregroundColor(.black)
            }
            
            if showComment {
                Color.black.opacity(0.4).ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    CommentSheetView(showAddComment: $showComment, post: post)
                        .transition(.move(edge: .bottom))
                        .padding(.bottom, keyboardHeight)
                        .zIndex(1)
                }
                .ignoresSafeArea(edges: .bottom)
                //.animation(.easeInOut, value: showComment)
            }
        }
        
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { notification in
                if let info = notification.userInfo,
                   let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    let screenHeight = UIScreen.main.bounds.height
                    let keyboardTop = keyboardFrame.origin.y
                    keyboardHeight = max(0, screenHeight - keyboardTop)
                }
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardHeight = 0
            }
        }
    }
}

struct CommentSheetView: View {
    @Binding var showAddComment: Bool
    @State private var commentText: String = ""
    @FocusState private var isFocused: Bool
    @State private var textHeight: CGFloat = 40
    @EnvironmentObject var postVM: PostFirebase
    @EnvironmentObject var userVM: UserFirebase
    var post: any Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("New comment")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    withAnimation {
                        showAddComment = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(Circle().fill(Color.gray.opacity(0.2)))
                }
            }
            
            ZStack(alignment: .topLeading) {
                if commentText.isEmpty {
                    Text("What do you think?")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 10)
                }
                
                GrowingTextView(text: $commentText, dynamicHeight: $textHeight)
                    .frame(height: textHeight)
                    .focused($isFocused)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }

            Button(action: {
                postVM.addComment(
                    postId: post.postId,
                    commentType: .text,
                    userId: userVM.user.userId,
                    content: commentText
                )
                commentText = ""
                showAddComment = false
            }) {
                Text("Post")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(commentText.isEmpty ? Color.gray.opacity(0.2) : Color.blue)
                    .foregroundColor(commentText.isEmpty ? .gray : .white)
                    .cornerRadius(12)
            }
            .disabled(commentText.isEmpty)
        }
        .padding()
        // ❌ Don't clip shape or add shadow here – it's done by .sheet
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }
}

struct GrowingTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var dynamicHeight: CGFloat
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        
        // Update height only when needed
        DispatchQueue.main.async {
            let size = uiView.sizeThatFits(CGSize(width: uiView.frame.width, height: .infinity))
            if self.dynamicHeight != size.height {
                self.dynamicHeight = size.height
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: GrowingTextView
        
        init(_ parent: GrowingTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

//#Preview {
//    AddCommentView()
//}
