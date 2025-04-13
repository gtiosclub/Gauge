//
//  StatisticsView.swift
//  Gauge
//
//  Created by Anthony Le on 4/9/25.
//

import SwiftUI

struct StatisticsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Username Statistics")
                .font(.system(size:21))
                .fontWeight(.bold)
                .padding(.vertical, 20)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(spacing: 0) {
                // Total Votes Made
                HStack {
                    Text("Total Votes Made")
                        .font(.system(size: 17))
                        .fontWeight(.regular)
                    Spacer()
                    HStack {
                        Text("100 Votes")
                            .font(.system(size: 17))
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                }
                .padding(.vertical, 15)
                .padding(.horizontal)
                
                Divider().padding(.horizontal)
                
                // Total Takes Made
                HStack {
                    Text("Total Takes Made")
                        .font(.system(size: 17))
                        .fontWeight(.regular)
                    Spacer()
                    HStack {
                        Text("25 Takes")
                            .font(.system(size: 17))
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                }
                .padding(.vertical, 15)
                .padding(.horizontal)
                
                Divider().padding(.horizontal)
                
                // Total Votes Collected
                HStack {
                    Text("Total Votes Collected")
                        .font(.system(size: 17))
                        .fontWeight(.regular)
                    Spacer()
                    HStack {
                        Text("275 Votes")
                            .font(.system(size: 17))
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                }
                .padding(.vertical, 15)
                .padding(.horizontal)
                
                Divider().padding(.horizontal)
                
                HStack {
                    Text("Total Comments Made")
                        .font(.system(size: 17))
                        .fontWeight(.regular)
                    Spacer()
                    HStack {
                        Text("110 Comments")
                            .font(.system(size: 17))
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                }
                .padding(.vertical, 15)
                .padding(.horizontal)
                
                Divider().padding(.horizontal)
                
                HStack {
                    Text("Ratio View/Response")
                        .font(.system(size: 17))
                        .fontWeight(.regular)
                    Spacer()
                    HStack {
                        Text("0.75")
                            .font(.system(size: 17))
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                }
                .padding(.vertical, 15)
                .padding(.horizontal)
            }
            Spacer()
        }
        .background(Color.white)
        .cornerRadius(10)
        .padding([.horizontal, .bottom])
    }
}

#Preview {
    StatisticsView()
}
