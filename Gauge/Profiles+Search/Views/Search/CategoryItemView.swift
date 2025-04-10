//
//  CategoryItemView.swift
//  Gauge
//
//  Created by Datta Kansal on 4/10/25.
//


import SwiftUI

struct CategoryItemView: View {
    let category: Category
    let isLarge: Bool
    let onCategoryTap: (Category) -> Void
    
    var body: some View {
        Button {
            onCategoryTap(category)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray5))
                    .frame(height: isLarge ? 100 : 70)
                    .frame(maxWidth: .infinity)
                
                Text(category.rawValue)
                    .foregroundColor(.black)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
