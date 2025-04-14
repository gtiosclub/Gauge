//
//  SliderFeedPost.swift
//  Gauge
//
//  Created by Austin Huguenard on 4/10/25.
//

import SwiftUI

struct SliderFeedPost: View {
    @EnvironmentObject var userVM: UserFirebase
    let post: SliderPost
    @Binding var optionSelected: Int
    @Binding var dragAmount: CGSize
    
    var computedOpacity: Binding<Double> {
        Binding<Double>(
            get: {
                return dragAmount.height > 0 || optionSelected == 3 ? 0.0 : min(abs(dragAmount.height) / 100.0, 1.0)
            },
            set: { _ in }
        )
    }

    var body: some View {
        VStack(alignment: .leading) {
            Spacer(minLength: 30)
                .frame(height: 30)

            ProfileUsernameDateView(dateTime: post.postDateAndTime, userId: post.userId)
                .padding(.leading)

            ScrollView(.horizontal) {
                HStack {
                    ForEach(post.categories, id: \.self) { category in
                        Text(category.rawValue)
                            .padding(.horizontal, 10)
                            .font(.system(size: 14))
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.gray)
                                    .opacity(0.2)
                                    .frame(height: 32)
                            )
                            .padding(.top, 10)
                    }
                }
                .padding(.bottom, 10)
                .padding(.leading)
            }

            Text(post.question)
                .padding(.top, 15)
                .bold()
                .font(.system(size: 35))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.black)
                .padding(.horizontal)
                .frame(height: 150)

            Spacer(minLength: 0.0)

            OptionSliderView(
                currentIndex: $optionSelected, dragAmount: $dragAmount
            )
            .padding(.horizontal)
            
            HStack {
                Text(post.lowerBoundLabel)
                    .foregroundColor(optionSelected < 3 ? .darkRed : .gray)
                    .fontWeight(.bold)
                    .font(.system(size: optionSelected < 3 ? 25.0 + CGFloat(3 - optionSelected) * 5.0 : 25.0))
                    .font(.title)
                    .opacity(optionSelected < 3 ? 0.6 + Double(3 - optionSelected) * 0.1 : 0.6)
                    .frame(width: 150.0, alignment: .leading)
                    .lineLimit(1)
                
                Spacer()
                
                Text(post.upperBoundLabel)
                    .foregroundColor(optionSelected > 3 ? .darkGreen : .gray)
                    .fontWeight(.bold)
                    .font(.system(size: optionSelected > 3 ? 25.0 + CGFloat(optionSelected - 3) * 5.0 : 25.0))
                    .font(.title)
                    .opacity(optionSelected > 3 ? 0.6 + Double(optionSelected - 3) * 0.1 : 0.6)
                    .frame(width: 150.0, alignment: .trailing)
                    .lineLimit(1)
            }
            .padding(.horizontal, 20)
            .frame(height: 50)

            Spacer()
                .frame(height: 80)
            
            HStack {
                Spacer()
                
                Image(systemName: "arrow.up")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30 + (dragAmount.height > 0.0 ? 0.0 : dragAmount.height * -1 / 5), height: 30 + (dragAmount.height > 0.0 ? 0.0 : dragAmount.height * -1 / 5), alignment: .center)
                    .foregroundColor(dragAmount.height == 0.0 || dragAmount.height > 0 ? .gray : (optionSelected < 3 ? .darkRed : .darkGreen))
                    .opacity(optionSelected == 3 ? 0.0 : (dragAmount.height == 0.0 || dragAmount.height > 0 ? 0.5 : 1.0))
                
                Spacer()
            }
            
            NavigationLink(destination: {
                HomeView()
            }, label: {
                Text("\(post.calculateResponses().reduce(0, +)) votes")
                    .foregroundColor(.gray)
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
            })
            
            HStack {
                Spacer()
                
                StackedProfiles(
                    userIds: Array(post.responses
                        .map { $0.userId }
                        .filter { userVM.user.friends.contains($0)}.prefix(5)),
                    startCompacted: false
                )
                
                Spacer()
            }
            
            Spacer(minLength: 50.0)
                .frame(height: 50.0)
        }
        .frame(width: UIScreen.main.bounds.width)
        .gradientBorder(borderWidth: 40, color: optionSelected < 3 ? .darkRed : .darkGreen, cornerRadius: 20, opacity: computedOpacity)
//        .onAppear {
//            optionSelected = 3
//        }
    }
}

//#Preview {
//    SliderFeedPost()
//}
