//
//  PostCreationView.swift
//  Gauge
//
//  Created by Krish Prasad on 3/8/25.
//

import SwiftUI

struct PostCreationView: View {
    @Binding var modalSize: CGFloat

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var postVM: PostFirebase
    @State private var currentStep: Int = 1
    @State private var currentStepTitle: String = "New Post"
    @State private var canMoveNext: Bool = false
    @State private var stepCompleted: Bool = false
    
    @State var postQuestion: String = ""
    @State var postCategories: [Category] = []
    @State var postType: PostType?
    @State var optionsSelectedIndex: Int?
    
    init(modalSize: Binding<CGFloat>) {
        self._modalSize = modalSize
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
                   dismiss()
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
            } else if currentStep == 4 {
                SelectCategories(
                    selectedCategories: $postCategories,
                    stepCompleted: $stepCompleted,
                    question: postQuestion,
                    responseOptions: [slidingOptions[optionsSelectedIndex ?? 0].left, slidingOptions[optionsSelectedIndex ?? 0].right]
                )
                .frame(height: 200)
            }
            
            
            HStack {
                if currentStep > 1 {
                    Button(action: {
                        withAnimation {
                            currentStep = max(currentStep - 1, 1)
                            
                            if currentStep == 1 {
                                currentStepTitle = "New Post"
                                modalSize = 380
                            } else if currentStep == 2 {
                                currentStepTitle = "Choose Type"
                                modalSize = 340
                            } else if currentStep == 3 {
                                currentStepTitle = "Pick Options"
                                modalSize = 380
                            } else if currentStep == 4 {
                                currentStepTitle = "Select Categories"
                                modalSize = 340
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
                    withAnimation {
                        currentStep = min(currentStep + 1, totalSteps)
                        stepCompleted = false
                        
                        if currentStep == 1 {
                            currentStepTitle = "New Post"
                            modalSize = 380
                        } else if currentStep == 2 {
                            currentStepTitle = "Choose Type"
                            modalSize = 340
                        } else if currentStep == 3 {
                            currentStepTitle = "Pick Options"
                        } else if currentStep == 4 {
                            currentStepTitle = "Select Categories"
                            modalSize = 340
                        }
                    }
                }) {
                    Capsule()
                        .fill(Color.blue)
                        .frame(width: currentStep == 1 ? 329 : 83, height: 43)
                        .overlay(
                            HStack {
                                Text("Next")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        )
                }
                .disabled(!stepCompleted)
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

#Preview {
    PostCreationView(modalSize: .constant(380))
        .environmentObject(PostFirebase())
}
