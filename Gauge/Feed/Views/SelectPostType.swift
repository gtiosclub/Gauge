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
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                .foregroundColor(isSelected ? .black : .gray.opacity(0.8))
        }
        .padding()
        .padding(.horizontal, isSelected ? 10 : 0)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(isSelected ? Color.gray.opacity(0.1) : Color.clear)
                .shadow(radius: isSelected ? 5 : 0)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(isSelected ? Color.gray : Color.clear, lineWidth: 1)
        )
        .onTapGesture(perform: action)
        .contentShape(Rectangle())

    }
}

struct SelectPostType: View {
    @State var selectedPostType: PostType?
    
    var body: some View {
        VStack {
            HStack {
                Text("Choose type")
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding(.bottom, 20)
            
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
                    withAnimation {
                        selectedPostType = .BinaryPost
                    }
                }
            )

            if selectedPostType == nil {
                FadingDivider()
            }
            
            PostTypeOption(
                icon: "arrow.left.and.right.square",
                name: "Slider",
                isSelected: selectedPostType == .SliderPost,
                action: {
                    withAnimation {
                        selectedPostType = .SliderPost
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
    }
}

#Preview {
    SelectPostType()
}
