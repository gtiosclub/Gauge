//
//  PostCreationView.swift
//  Gauge
//
//  Created by Krish Prasad on 3/8/25.
//

import SwiftUI

struct PostCreationView: View {
    @Binding var modalSize: CGFloat
    @Binding var showCreatePost: Bool

    @EnvironmentObject var postVM: PostFirebase
    @EnvironmentObject var userVM: UserFirebase
    @State private var currentStep: Int = 1
    @State private var currentStepTitle: String = "New Post"
    @State private var canMoveNext: Bool = false
    @State private var stepCompleted: Bool = false
    @State var skippable: Bool = false
    @State var isRight: Bool = false // boolean for switching between left and right caption
    
    @State var postQuestion: String = ""
    @State var postCategories: [Category] = []
    @State var postType: PostType?
    @State var optionsSelectedIndex: Int?
    @State var leftCaption: String = ""
    @State var rightCaption: String = ""

    
    init(modalSize: Binding<CGFloat>, showCreatePost: Binding<Bool>) {
        self._modalSize = modalSize
        self._showCreatePost = showCreatePost
    }
        
    private var totalSteps: Int = 5
    let slidingOptions: [SlidingOption] = [
        .init(left: "No", right: "Yes"),
        .init(left: "Hate", right: "Love"),
        .init(left: "Cringe", right: "Cool")
    ]
    
    
    var body: some View {
        VStack(spacing: 0) {
           HStack {
               ProgressIndicator(stepCompleted: stepCompleted, currentStep: currentStep, totalSteps: totalSteps)
                
                Spacer()
                
               Button(action: {
                   modalSize = 380
                   showCreatePost = false
               }) {
                    Circle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                                .font(.system(size: 16, weight: .medium))
                        )
                }
            }
            .padding(.horizontal)
            
            HStack {
                Text(currentStepTitle)
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .padding(.leading, 20)
                
                Spacer()
            }
            .padding(.bottom, 30)
            
            
            if currentStep == 1 {
                InputPostQuestion(questionText: $postQuestion, stepCompleted: $stepCompleted)
                    .frame(height: 200)
            } else if currentStep == 2 {
                SelectPostType(selectedPostType: $postType, stepCompleted: $stepCompleted)
            } else if currentStep == 3 {
                SelectLabelNames(slidingOptions: slidingOptions, selectedIndex: $optionsSelectedIndex, stepCompleted: $stepCompleted)
                    .padding(.horizontal, 20)
            } else if currentStep == 4 {
                TypeCaptionsView(
                    leftCaption: $leftCaption,
                    rightCaption: $rightCaption,
                    isRight: isRight,
                    stepCompleted: $stepCompleted,
                    skippable: $skippable
                )
            } else if currentStep == 5 {
                SelectCategories(
                    selectedCategories: $postCategories,
                    stepCompleted: $stepCompleted,
                    question: postQuestion,
                    responseOptions: [slidingOptions[optionsSelectedIndex ?? 0].left, slidingOptions[optionsSelectedIndex ?? 0].right]
                )
                .frame(height: 200)
            }
            
//            else if currentStep == 5 {
//                BinaryPostPreview(postQuestion: postQuestion, postCategories: postCategories, postType: postType!, responseOption1: slidingOptions[optionsSelectedIndex!].left, responseOption2: slidingOptions[optionsSelectedIndex!].right, username: userVM.user.username)
//                    .frame(height: 600)
//            }
            
            
            HStack {
                if currentStep > 1 {
                    Button(action: {
                        withAnimation {
                            if (currentStep == 5) {
                                currentStep = 4
                                currentStepTitle = "Type Captions"
                                modalSize = 300
                                if (rightCaption.count > 0) {
                                    isRight = true
                                } else {
                                    isRight = false
                                    skippable = leftCaption.isEmpty
                                }
                                return
                            }
                            
                            if (currentStep != 4) {
                                currentStep = max(currentStep - 1, 1)
                            } else {
                                if (!isRight) {
                                    currentStep = 3
                                    skippable = false
                                } else {
                                    isRight = false
                                    skippable = leftCaption.isEmpty
                                    return
                                }
                            }
                            
                            if currentStep == 1 {
                                currentStepTitle = "New Post"
                                modalSize = 380
                            } else if currentStep == 2 {
                                currentStepTitle = "Choose Type"
                                modalSize = 340
                            } else if currentStep == 3 {
                                currentStepTitle = "Pick Options"
                                modalSize = 400
                            } else if currentStep == 5 {
                                currentStepTitle = "Select Categories"
                                modalSize = 380
                            }
                            
//                            else if currentStep == 5 {
//                                currentStepTitle = "Review Post"
//                                modalSize = 800
//                                stepCompleted = true
//                            }
                        }
                    }) {
                        Circle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: 43, height: 43)
                            .overlay(
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 18, weight: .semibold))
                            )
                    }
                }
                
                if currentStep != 1 {
                    Spacer()
                }
                
                Button(action: {
//                    if (currentStep == 5) {
//                        modalSize = 380
//                        showCreatePost = false
//                        
//                        Task {
//                            await postVM.createBinaryPost(userId: userVM.user.userId, categories: postCategories, question: postQuestion, responseOption1: slidingOptions[optionsSelectedIndex!].left, responseOption2: slidingOptions[optionsSelectedIndex!].right)
//                        }
//                    }
                        
                    withAnimation {
                        if (currentStep == 3) {
                            currentStep = 4
                            currentStepTitle = "Type Captions"
                            modalSize = 300
                            isRight = false
                            skippable = leftCaption.isEmpty
                            return
                        }
                        
                        if (currentStep != 4) {
                            currentStep = max(currentStep + 1, 1)
                        } else {
                            if (isRight || skippable) {
                                currentStep = 5
                            } else {
                                isRight = true
                                skippable = false
                                stepCompleted = !rightCaption.isEmpty
                                return
                            }
                        }
                        
                        stepCompleted = false
                        
                        if currentStep == 1 {
                            currentStepTitle = "New Post"
                            modalSize = 380
                        } else if currentStep == 2 {
                            currentStepTitle = "Choose Type"
                            modalSize = 340
                        } else if currentStep == 3 {
                            currentStepTitle = "Pick Options"
                            modalSize = 400
                        } else if currentStep == 5 {
                            currentStepTitle = "Select Categories"
                            modalSize = 380
                        }
                        
//                        else if currentStep == 5 {
//                            currentStepTitle = "Review Post"
//                            if showCreatePost {
//                                modalSize = 800
//                            }
//                            stepCompleted = true
//                        }
                    }
                }) {
                    Capsule()
                        .fill(stepCompleted ? Color.darkBlue : skippable || (currentStep == 4 && !isRight) ? Color.blue : Color.lightBlue)
                        .frame(width: currentStep == 1 ? 329 : 83, height: 43)
                        .overlay(
                            HStack {
                                Text(skippable ? "Skip" : currentStep != 6 ? "Next" :  "Post")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Image(systemName: skippable ? "chevron.right.2" : currentStep != 6 ? "chevron.right" : "arrow.up")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .semibold))
                                
                            }
                        )
                }
                .disabled(currentStep == 4 && (!isRight || skippable) ? false : !stepCompleted)
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .cornerRadius(30)
    }
}

struct ProgressIndicator: View {
    var stepCompleted: Bool
    var currentStep: Int
    var totalSteps: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...totalSteps, id: \.self) { step in
                Capsule()
                    .fill(stepCompleted && step == currentStep ? Color.blue : Color.gray.opacity(step == currentStep ? 0.5 : 0.2))
                    .frame(width: step == currentStep ? 32 : 12, height: 5)
            }
        }
    }
}

struct BinaryPostPreview: View {
    var postQuestion: String
    var postCategories: [Category]
    var postType: PostType
    var responseOption1: String
    var responseOption2: String
    var username: String
    var profilePhoto: String = ""
    
    let profilePhotoSize: CGFloat = 30
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                //Profile Photo
                if profilePhoto != "", let url = URL(string: profilePhoto) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: profilePhotoSize, height: profilePhotoSize)
                                .clipShape(Circle())
                        case .failure, .empty:
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: profilePhotoSize, height: profilePhotoSize)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: profilePhotoSize, height: profilePhotoSize)
                        .foregroundColor(.gray)
                }
                
                Text(username)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(white: 0.4))
                
                Text("• 0m ago")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(white: 0.6))
                

                
            }
            .frame(alignment: .leading)
            .padding(.leading)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(postCategories, id: \.self) { category in
                        Text(category.rawValue)
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .font(.system(size: 14))
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.gray)
                                    .opacity(0.2)
                                    .frame(height: 32)
                            )
                            .padding(.top, 10)
                            .frame(minWidth: 40)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    

                }
                .padding(.bottom, 10)
                .padding(.leading)
            }
            
            VStack {
                Text(postQuestion)
                    .padding(.top, 15)
                    .padding(.horizontal)
                    .bold()
                    .font(.system(size: 35))
                    .frame(alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.black)
                
                Spacer()
                
                ZStack {
                    HStack {
                        Text(responseOption1)
                            .foregroundColor(.gray)
                            .font(.system(size: 30))
                            .font(.title)
                            .opacity(0.5)
                            .frame(width: 150.0, alignment: .leading)
                            .minimumScaleFactor(0.75)
                            .lineLimit(2)
                        
                        
                        Spacer()
                        
                        Image(systemName: "arrow.left.and.right")
                            .resizable()
                            .scaledToFit()
                            .opacity(0.5)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text(responseOption2)
                            .foregroundColor(.gray)
                            .font(.system(size: 30))
                            .font(.title)
                            .opacity(0.5)
                            .frame(width: 150.0, alignment: .trailing)
                            .minimumScaleFactor(0.75)
                            .lineLimit(2)
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 100)
                
                Text("0 votes")
                    .foregroundColor(.gray)
                    .scaledToFit()
                    .opacity(0.7)
                
                Spacer()
            }
        }
    }
}

#Preview {
    PostCreationView(modalSize: .constant(380), showCreatePost: .constant(true))
        .environmentObject(PostFirebase())
        .environmentObject(UserFirebase())
}
