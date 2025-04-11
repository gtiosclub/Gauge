//
//  SelectPostType.swift
//  Gauge
//
//  Created by Krish Prasad on 3/7/25.
//

import SwiftUI

struct FadingDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 1)
            .mask(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black, .black, .clear]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .padding(.horizontal)
    }
}

struct PostTypeOption: View {
    let icon: String
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(isSelected ? .black : .gray.opacity(0.8))
                .fontWeight(.medium)
            
            Text(name)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .black : .gray.opacity(0.8))
                .fontWeight(.medium)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(isSelected ? .black : .gray.opacity(0.8))
                .opacity(isSelected ? 1.0 : 0.0)
                .background(
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(isSelected ? .black : .gray.opacity(0.8))
                        .opacity(isSelected ? 0.0 : 1.0)
                )
        }
        .padding(.vertical, 20)
        .padding(.horizontal, isSelected ? 20 : 0)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(isSelected ? Color.gray.opacity(0.08) : Color.clear)
                .shadow(radius: isSelected ? 5 : 0)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(isSelected ? Color.gray : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: action)

    }
}

struct SelectPostType: View {
    @Binding var selectedPostType: PostType?
    @Binding var stepCompleted: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            if selectedPostType != .BinaryPost {
                FadingDivider()
            } else {
                Color.clear
                    .frame(height: 1)
            }
            
            PostTypeOption(
                icon: "rectangle.split.2x1",
                name: "Binary",
                isSelected: selectedPostType == .BinaryPost,
                action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPostType = .BinaryPost
                        stepCompleted = true
                    }
                    
                }
            )

            if selectedPostType == nil {
                FadingDivider()
            } else {
                Color.clear
                    .frame(height: 1)
            }
            
            PostTypeOption(
                icon: "arrow.left.and.right.square",
                name: "Slider",
                isSelected: selectedPostType == .SliderPost,
                action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPostType = .SliderPost
                        stepCompleted = true
                    }
                }
            )
            
            if selectedPostType != .SliderPost {
                FadingDivider()
            } else {
                Color.clear
                    .frame(height: 1)
            }
        }
        .padding(.horizontal)
        .onAppear {
            stepCompleted = selectedPostType != nil
        }
    }
}

#Preview {
//    SelectPostType()
}
