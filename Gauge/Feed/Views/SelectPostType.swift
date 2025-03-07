//
//  SelectPostType.swift
//  Gauge
//
//  Created by Krish Prasad on 3/7/25.
//

import SwiftUI

struct SelectPostType: View {
    var body: some View {
        VStack {
            HStack {
                Text("Choose type")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            Divider()
            
            HStack {
                Image(systemName: "rectangle.split.2x1")
                    .resizable()
                    .font(.title)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.gray)
                    .fontWeight(.semibold)
                
                Text("Binary")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.gray)
            }
            .padding()
            
            Divider()
            
            HStack {
                Image(systemName: "arrow.left.and.right.square")
                    .resizable()
                    .font(.title)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.gray)
                    .fontWeight(.semibold)
                
                Text("Slider")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.gray)
            }
            .padding()

            Divider()
        }
    }
}

#Preview {
    SelectPostType()
}
