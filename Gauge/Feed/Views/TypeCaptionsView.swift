//
//  TypeCaptionsView.swift
//  Gauge
//
//  Created by Krish Prasad on 4/8/25.
//

import SwiftUI

struct TypeCaptionsView: View {
    @State var leftCaption: String = ""
    @State var rightCaption: String = ""
    @State var isRight: Bool = false
    @State var stepCompleted: Bool = false
    @State var skippable: Bool = false
    
    var body: some View {
        VStack {
            FadingDivider()
            HStack(spacing: 8) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("No")
                        .font(!isRight ? .caption : .title)
                        .fontWeight(!isRight ? .regular : .bold)
                        .foregroundColor(!isRight ? .red.opacity(0.5) : .lightGray)
                    if (!isRight) {
                        TextField("Caption", text: $leftCaption)
                            .multilineTextAlignment(.leading)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .onChange(of: leftCaption) { newValue in
                                stepCompleted = leftCaption.count > 0 && rightCaption.count > 0
                                skippable = leftCaption.count == 0 && rightCaption.count == 0
                            }
                    }
                }
                .padding()
                .background(!isRight ? Color.red.opacity(0.05) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.red, lineWidth: !isRight ? 1 : 0)
                )
                .cornerRadius(24)
                
                if (!isRight) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.red)
                        .font(.title2)
                }
                
                if (isRight) {
                    Image(systemName: "arrow.right")
                        .foregroundColor(.green)
                        .font(.title2)
                }
                    
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Yes")
                        .font(isRight ? .caption : .title)
                        .fontWeight(isRight ? .regular : .bold)
                        .foregroundColor(isRight ? .green.opacity(0.5) : .lightGray)
                        .mask(
                            HStack {
                                if (!isRight) {
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: .black, location: 0.0),
                                            .init(color: .black, location: 0.2),
                                            .init(color: .clear, location: 1.0)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                }
                            }
                        )
                    if (isRight) {
                        TextField("Caption", text: $rightCaption)
                            .multilineTextAlignment(.trailing)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                            .onChange(of: rightCaption) { newValue in
                                stepCompleted = leftCaption.count > 0 && rightCaption.count > 0
                                skippable = leftCaption.count == 0 && rightCaption.count == 0
                            }
                    }
                }
                .padding()
                .background(isRight ? Color.green.opacity(0.05) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.green, lineWidth: isRight ? 1 : 0)
                )
                .cornerRadius(24)
                
            }
//            .padding()
            FadingDivider()
        }
        .padding()
        .onAppear {
            stepCompleted = leftCaption.count > 0 && rightCaption.count > 0
            skippable = leftCaption.count == 0 && rightCaption.count == 0
        }
    }
}

#Preview {
    TypeCaptionsView()
}
