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

struct UnselectedType: View {
    var icon: String
    var name: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .font(.title)
                .frame(width: 30, height: 30)
                .foregroundColor(.gray.opacity(0.8))
                .fontWeight(.medium)
            
            Text(name)
                .font(.largeTitle)
                .foregroundColor(.gray.opacity(0.8))
                .fontWeight(.medium)
            
            Spacer()
            
            Image(systemName: "checkmark.circle")
                .foregroundColor(.gray.opacity(0.8))
        }
        .padding()
        .contentShape(Rectangle())
    }
}

struct SelectedType: View {
    var icon: String
    var name: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .font(.title)
                .frame(width: 30, height: 30)
                .foregroundColor(.black)
                .fontWeight(.medium)
            
            Text(name)
                .font(.largeTitle)
                .foregroundColor(.black)
                .fontWeight(.medium)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.black)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.gray.opacity(0.1))
                .shadow(radius: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding(.horizontal, 10)

    }
}

struct SelectPostType: View {
    @State var selectedPostType: PostType?
    
    var body: some View {
        VStack {
            HStack {
                Text("Choose type")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding(.bottom, 30)
            
            if (selectedPostType == .BinaryPost) {
                SelectedType(icon: "rectangle.split.2x1", name: "Binary")
            } else {
                
                FadingDivider()
                
                UnselectedType(icon: "rectangle.split.2x1", name: "Binary")
                    .onTapGesture {
                        withAnimation {
                            selectedPostType = .BinaryPost
                        }
                    }
            }

            if let postType = selectedPostType {
            } else {
                FadingDivider()
            }
            
            if (selectedPostType == .SliderPost) {
                SelectedType(icon: "arrow.left.and.right.square", name: "Slider")
            } else {
                UnselectedType(icon: "arrow.left.and.right.square", name: "Slider")
                    .onTapGesture {
                        withAnimation {
                            selectedPostType = .SliderPost
                        }
                    }
    
                FadingDivider()
            }


        }
    }
}

#Preview {
    SelectPostType()
}
