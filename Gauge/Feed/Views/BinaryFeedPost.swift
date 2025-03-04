//
//  BinaryFeedPost.swift
//  Gauge
//
//  Created by HB on 2/27/25.
//

import SwiftUI

struct BinaryFeedPost: View {
    @EnvironmentObject var postVM: PostFirebase
    @EnvironmentObject var userVM: UserFirebase
    
    let post: BinaryPost
    let index: Int
    @Binding var dragAmount: CGSize
    @Binding var optionSelected: Int
    
    var computedOpacity: Binding<Double> {
        Binding<Double>(
            get: {
                return dragAmount.height > 0 || optionSelected == 0 ? 0.0 : min(abs(dragAmount.height) / 100.0, 1.0)
            },
            set: { _ in }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if index == 0 {
                HStack{
                    profileImage
                    Text(post.userId)
                        .bold()
                        .font(.system(size: 16))
                        .padding(.leading, 10)
                    
                    Text("•   \(DateConverter.timeAgo(from: post.postDateAndTime))")
                        .font(.system(size: 13))
                        .padding(.leading, 5)
                }
                
                
                //Category Boxes
                ScrollView(.horizontal) {
                    HStack {
                        let categories: [Category] = post.categories
                        
                        ForEach(categories, id: \.self) { category in
                            Text(category.rawValue)
                                .padding(.leading, 10)
                                .padding(.trailing, 10)
                                .font(.system(size: 14))
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.gray)
                                        .opacity(0.2)
                                        .frame(height: 32)
                                )
                                .padding(.top, 10)
                                .frame(minWidth: 40)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 10)
                }
                .padding(.leading, 0)
                
                VStack {
                    Text(post.question)
                        .padding(.top, 15)
                        .bold()
                        .font(.system(size: 35))
                    
                    Spacer()
                    
                    ZStack {
                        HStack {
                            Text(post.responseOption1)
                                .foregroundColor(.gray)
                                .font(.system(size: optionSelected == 1 ? 50 : 30))
                                .font(optionSelected == 1 ? .title : .title2)
                                .opacity(dragAmount.width < 0.0 ? (1.0 - (dragAmount.width / 150.0).magnitude) : 1.0)
                                .frame(width: 150.0, alignment: .leading)
                                .minimumScaleFactor(0.75)
                                .lineLimit(2)
                            
                            
                            Spacer()
                            
                            Image(systemName: "arrow.left.and.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                                .opacity(1.0 - (dragAmount.width / 100.0).magnitude)
                            
                            Spacer()
                            
                            Text(post.responseOption2)
                                .foregroundColor(.gray)
                                .font(.system(size: optionSelected == 2 ? 50 : 30))
                                .font(optionSelected == 2 ? .title : .title2)
                                .opacity(dragAmount.width > 0.0 ? (1.0 - dragAmount.width / 100.0) : 1.0)
                                .frame(width: 150.0, alignment: .trailing)
                                .minimumScaleFactor(0.75)
                                .lineLimit(2)
                        }
                        .padding(.horizontal)
                        .opacity(0.5)
                        
                        
                        HStack {
                            Spacer()
                            
                            if dragAmount.width < 0.0 {
                                HStack {
                                    Text(post.responseOption1)
                                        .font(.system(size: 30))
                                        .minimumScaleFactor(0.75)
                                        .lineLimit(2)
                                    
                                    Image(systemName: "arrow.left")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                }
                                .opacity((dragAmount.width / 100.0).magnitude)
                                .foregroundStyle(.red)
                            }
                            
                            Spacer(minLength: 20.0)
                            
                            if dragAmount.width > 0.0 {
                                HStack {
                                    Image(systemName: "arrow.right")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                    
                                    Text(post.responseOption2)
                                        .font(.system(size: 30))
                                        .minimumScaleFactor(0.75)
                                        .lineLimit(2)
                                }
                                .opacity(dragAmount.width / 100.0)
                                .foregroundStyle(.green)
                            }
                            
                            Spacer()
                        }
                    }
                }
                .background(
                    dragAmount.width < 0.0 ? (
                        Ellipse()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [.red.opacity(0.4 * ((dragAmount.width / 100.0).magnitude > 1.0 ? 1.0 : (dragAmount.width / 100.0).magnitude)), .clear]),
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 400
                                )
                            )
                            .frame(width: 600, height: 800)
                            .offset(x: -200, y: 200)
                    ) : (
                        Ellipse()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: dragAmount.width == 0.0 ? [.clear] : [.green.opacity(0.4 * ((dragAmount.width / 100.0).magnitude > 1.0 ? 1.0 : (dragAmount.width / 100.0).magnitude)), .clear]),
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 400
                                )
                            )
                            .frame(width: 600, height: 800)
                            .offset(x: 200, y: 200)
                    )
                )
                
                Spacer(minLength: 100.0)
                
                if optionSelected != 0 {
                    HStack {
                        Spacer()
                        
                        Image(systemName: "arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30 + (dragAmount.height > 0.0 ? 0.0 : dragAmount.height * -1 / 5), height: 30 + (dragAmount.height > 0.0 ? 0.0 : dragAmount.height * -1 / 5), alignment: .center)
                            .foregroundColor(dragAmount.height == 0.0 || dragAmount.height > 0 ? .gray : (optionSelected == 1 ? .red : .green))
                            .opacity(0.5)
                        
                        Spacer()
                    }
                }
                
                NavigationLink(destination: {
                    HomeView()
                }, label: {
                    Text("\(post.responseResult1 + post.responseResult2) votes")
                        .foregroundColor(.gray)
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                })
            }
        }
        .padding()
        .gradientBorder(borderWidth: 15, color: optionSelected == 1 ? .red : .green, cornerRadius: 10, opacity: computedOpacity)
    }
    
    var profileImage: some View {
        if post.profilePhoto == "" {
            AnyView(Image(systemName: "person")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .background(Circle()
                    .fill(Color.gray)
                    .frame(width:28, height: 28)
                    .opacity(0.6)
                   )
                )
        } else {
            AnyView(AsyncImage(url: URL(string: post.profilePhoto)) { image in
                image.resizable()
                    .scaledToFill()
                    .frame(width: max(120, 140))
                    .frame(height: 120)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.5), radius: 5, y: 3)
            } placeholder: {
                ProgressView() // Placeholder until the image is loaded
                    .frame(width: max(120, 140))
                    .frame(height: 120)
                    .cornerRadius(10)
            }
                )
            }
    }
}

extension View {
    func gradientBorder(borderWidth: CGFloat = 20, color: Color = .red, cornerRadius: CGFloat = 10, opacity: Binding<Double>) -> some View {
        self
            // Top border overlay
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [color.opacity(opacity.wrappedValue), .clear]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: borderWidth)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius)),
                alignment: .top
            )
            // Bottom border overlay
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, color.opacity(opacity.wrappedValue)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: borderWidth)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius)),
                alignment: .bottom
            )
            // Left border overlay
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [color.opacity(opacity.wrappedValue), .clear]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: borderWidth)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius)),
                alignment: .leading
            )
            // Right border overlay
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, color.opacity(opacity.wrappedValue)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: borderWidth)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius)),
                alignment: .trailing
            )
    }
}



#Preview {
    BinaryFeedPost(post: BinaryPost(postId: "903885747", userId: "coolguy", categories: [.sports(.nfl),.sports(.soccer),.entertainment(.tvShows),.entertainment(.movies)], postDateAndTime: Date(), question: "Insert controversial binary take right here in this box; yeah, incite some intereseting discourse", responseOption1: "bad", responseOption2: "good"), index: 0, dragAmount: .constant(CGSize(width: 40.0, height: 10.0)), optionSelected: .constant(0)
    )
}

