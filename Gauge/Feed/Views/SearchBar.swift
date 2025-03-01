//
//  SearchBar.swift
//  Gauge
//
//  Created by Krish Prasad on 2/28/25.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    var onChange: (() -> Void)? = nil
    var placeholder: String = ""
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("",
                      text: $searchText,
                      prompt: Text(placeholder)
                                .foregroundColor(.gray)
                                .font(.system(size: 16, weight: .medium))
            )
            .foregroundColor(.primary)
        }
        .padding(10)
        .background(Color(.systemGray5))
        .cornerRadius(20)
    }
}

//#Preview {
//    SearchBar()
//}
