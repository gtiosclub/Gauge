//
//  CustomSearchBar.swift
//  Gauge
//
//  Created by amber verma on 4/13/25.
//

import SwiftUI

struct CustomSearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search", text: $text)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)

            Image(systemName: "mic.fill")
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
