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
    @Environment(\.modelContext) private var modelContext

    
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
                    leftResponseOption: slidingOptions[optionsSelectedIndex!].left,
                    rightResponseOption: slidingOptions[optionsSelectedIndex!].right,
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
                    captions: [leftCaption,  rightCaption]
                )
                .frame(height: 200)
            } else if currentStep == 6 {
                BinaryPostPreview(
                    postQuestion: postQuestion,
                    postCategories: postCategories,
                    postType: postType!,
                    responseOption1: slidingOptions[optionsSelectedIndex!].left,
                    responseOption2: slidingOptions[optionsSelectedIndex!].right,
                    leftCaption: leftCaption,
                    rightCaption: rightCaption
                )
            }
            
            
            HStack {
                if currentStep > 1 {
                    Button(action: {
                        withAnimation {
                            if (currentStep == 5) {
                                if postType == .SliderPost {
                                    currentStep = 4
                                } else {
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
                            }
                            
                            if (currentStep != 4 || postType == .SliderPost) {
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
                    if (currentStep == 6) {
                        modalSize = 380
                        showCreatePost = false
                        
                        Task {
                            if postType == .BinaryPost {
                                let postTopics = await postVM.createBinaryPost(userId: userVM.user.userId, categories: postCategories, question: postQuestion, responseOption1: slidingOptions[optionsSelectedIndex!].left, responseOption2: slidingOptions[optionsSelectedIndex!].right, sublabel1: leftCaption, sublabel2: rightCaption)
                                UserResponsesManager.addCategoriesToUserResponses(modelContext: modelContext, categories: postCategories.map{$0.rawValue})
                                UserResponsesManager.addTopicsToUserResponses(modelContext: modelContext, topics: postTopics.1)
                                userVM.user.myPosts.append(postTopics.0)
                            } else if postType == .SliderPost {
                                let postTopics = await postVM.createSliderPost(userId: userVM.user.userId, categories: postCategories, question: postQuestion, lowerBoundLabel: slidingOptions[optionsSelectedIndex!].left, upperBoundLabel: slidingOptions[optionsSelectedIndex!].right)
                                UserResponsesManager.addCategoriesToUserResponses(modelContext: modelContext, categories: postCategories.map{$0.rawValue})
                                UserResponsesManager.addTopicsToUserResponses(modelContext: modelContext, topics: postTopics.1)
                                userVM.user.myPosts.append(postTopics.0)
                            }
                            
                        }
                    }
                        
                    withAnimation {
                        if (currentStep == 3) {
                            if postType == .SliderPost {
                                currentStep = 4
                            } else {
                                currentStep = 4
                                currentStepTitle = "Type Captions"
                                modalSize = 300
                                isRight = false
                                skippable = leftCaption.isEmpty
                                return
                            }
                        }
                        
                        if (currentStep != 4 || postType == .SliderPost) {
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
                        
                        if currentStep == 2 {
                            currentStepTitle = "Choose Type"
                            modalSize = 340
                        } else if currentStep == 3 {
                            currentStepTitle = "Pick Options"
                            modalSize = 400
                        } else if currentStep == 5 {
                            skippable = false
                            currentStepTitle = "Select Categories"
                            modalSize = 380
                        } else if currentStep == 6 {
                            stepCompleted = true
                            currentStepTitle = "Review Post"
                            if showCreatePost {
                                modalSize = 500
                            }
                        }
                    }
                }) {
                    Capsule()
                        .fill(skippable ? Color.blue.opacity(0.2) : stepCompleted || (currentStep == 4 && !isRight) ? Color.darkBlue :  Color.lightBlue)
                        .frame(width: currentStep == 1 || currentStep == 6 ? 329 : 83, height: 43)
                        .overlay(
                            HStack {
                                Text(skippable ? "Skip" : currentStep != 6 ? "Next" :  "Post")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(skippable ? .blue : .white)
                                
                                Image(systemName: skippable ? "chevron.right.2" : currentStep != 6 ? "chevron.right" : "arrow.up")
                                    .foregroundColor(skippable ? .blue : .white)
                                    .font(.system(size: 16, weight: .semibold))
                                
                            }
                        )
                }
                .disabled(currentStep == 4 && (!isRight || skippable) ? false : !stepCompleted)
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .onAppear(perform: {
            modalSize = 380
        })
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
        if currentStep != 6 {
            HStack(spacing: 4) {
                ForEach(1...totalSteps, id: \.self) { step in
                    Capsule()
                        .fill(stepCompleted && step == currentStep ? Color.blue : Color.gray.opacity(step == currentStep ? 0.5 : 0.2))
                        .frame(width: step == currentStep ? 32 : 12, height: 5)
                }
            }
        } else {
            Capsule()
                .fill(Color.blue)
                .frame(width: 96, height: 5)
        }
    }
}

struct BinaryPostPreview: View {
    var postQuestion: String
    var postCategories: [Category]
    var postType: PostType
    var responseOption1: String
    var responseOption2: String
    var leftCaption: String
    var rightCaption: String
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(postCategories, id: \.self) { category in
                            Text(category.rawValue)
                                .padding(10)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .background(Color(.systemGray6))
                                .foregroundColor(.black)
                                .cornerRadius(20)
                                .fixedSize()
                        }
                    }
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 15)
            .background(Color(.systemGray5))
            .cornerRadius(16)
            .padding(.horizontal)
            
            HStack {
                Text(postQuestion)
                    .lineLimit(3)
                    .bold()
                    .font(.system(size: 24.8))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.black)
                    
                Spacer()
            }
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(16)
            .padding(.horizontal, 16)
            
            HStack {
                Image(systemName: postType == .BinaryPost ? "rectangle.split.2x1" : "arrow.left.and.right.square")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.black)
                    .fontWeight(.medium)
                
                Text(postType == .BinaryPost ? "Binary" : "Slider")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
                    .fontWeight(.medium)
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(16)
            .padding(.horizontal)
            
            ZStack {
                VStack {
                    HStack {
                        Text(responseOption1)
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text(responseOption2)
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal)
                    
                    if !leftCaption.isEmpty {
                        Divider()
                            .frame(height: 3)
                            .overlay(Color.white)
                    
                        HStack {
                            Text(leftCaption)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                                .fontWeight(.medium)
                                .frame(maxWidth: 150.0, alignment: .leading)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(rightCaption)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                                .fontWeight(.medium)
                                .frame(maxWidth: 150.0, alignment: .trailing)
                                .lineLimit(1)
                        }
                        .padding(.horizontal)
                        .padding(.top, 3)
                    }
                }
                .padding(.vertical)
                .background(Color(.systemGray5))
                .cornerRadius(16)
                .padding(.horizontal)
                
                Image(systemName: "arrow.left.and.right")
                    .resizable()
                    .frame(width: 20, height: 15)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 13)
                    .foregroundStyle(Color(.systemGray5))
                    .background(Color.white)
                    .cornerRadius(60)
                    .offset(x: 0, y: leftCaption.isEmpty ? 0 : 8)
            }
        }
    }
}

#Preview {
    PostCreationView(modalSize: .constant(380), showCreatePost: .constant(true))
        .environmentObject(PostFirebase())
        .environmentObject(UserFirebase())
}
