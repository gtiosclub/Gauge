//
//  LocationSelectionView.swift
//  Gauge
//
//  Created by Anthony Le on 4/3/25.
//

import SwiftUI

struct LocationSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToEmojiSelection: Bool = false
    @State private var locationSelection: String = ""
    @State private var query: String = ""
    @State private var showSuggestions: Bool = true
    @State private var isProgammaticChange: Bool = false
    @State private var toSkip: Bool = true
    
    let locations = [
        "New York, NY", "Los Angeles, CA", "Chicago, IL", "Houston, TX", "Phoenix, AZ",
        "Philadelphia, PA", "San Antonio, TX", "San Diego, CA", "Dallas, TX", "Austin, TX",
        "Jacksonville, FL", "Fort Worth, TX", "Columbus, OH", "Charlotte, NC", "San Francisco, CA",
        "Indianapolis, IN", "Seattle, WA", "Denver, CO", "Oklahoma City, OK", "Nashville, TN",
        "El Paso, TX", "Washington, DC", "Las Vegas, NV", "Boston, MA", "Portland, OR",
        "Detroit, MI", "Louisville, KY", "Memphis, TN", "Baltimore, MD", "Milwaukee, WI",
        "Albuquerque, NM", "Fresno, CA", "Tucson, AZ", "Mesa, AZ", "Sacramento, CA",
        "Atlanta, GA", "Kansas City, MO", "Colorado Springs, CO", "Raleigh, NC", "Omaha, NE",
        "Miami, FL", "Long Beach, CA", "Virginia Beach, VA", "Oakland, CA", "Minneapolis, MN",
        "Tulsa, OK", "Tampa, FL", "Arlington, TX", "New Orleans, LA", "Wichita, KS"
    ]
    
    var filteredLocations: [String] {
        locations
            .filter { $0.localizedCaseInsensitiveContains(query) }
            .sorted {
                let lhsStarts = $0.lowercased().hasPrefix(query.lowercased())
                let rhsStarts = $1.lowercased().hasPrefix(query.lowercased())
                if lhsStarts && !rhsStarts { return true }
                if !lhsStarts && rhsStarts { return false }
                return $0 < $1
            }
    }

    var body: some View {
        VStack(spacing: 0) {
            AboutYouProgressBar(progress: 2)
            
            ZStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                
                Text("About You")
                    .font(.system(size: 17, weight: .semibold))
            }
            .padding(.top, 12)
            .padding(.horizontal, 18)
            
            Spacer().frame(height: 30)

            VStack(alignment: .leading, spacing: 8) {
                Text("Where do you live?")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 20)
                
                TextField("City, State", text: $query)
                    .onChange(of: query, initial: false) { oldValue, newValue in
                        if (query == locationSelection) {
                            toSkip = false
                        } else {
                            toSkip = true
                        }
                        
                        if !isProgammaticChange {
                            showSuggestions = true
                        } else {
                            isProgammaticChange = false
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
                
                if !filteredLocations.isEmpty {
                    if showSuggestions {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(filteredLocations, id: \.self) { location in
                                    Button(action: {
                                        showSuggestions = false
                                        isProgammaticChange = true
                                        locationSelection = location
                                        query = location
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        }
                                    }) {
                                        Text(location)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.white)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    Divider()
                                }
                            }
                            .background(Color.white)
                        }
                        .frame(maxHeight: .infinity)
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button(action: {
                navigateToEmojiSelection = true
            }) {
                skipOrNextActionButton(toSkip: toSkip)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)

            Spacer().frame(height: 0)
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToEmojiSelection) {
            EmojiSelectionView()
        }
    }
}

#Preview {
    LocationSelectionView()
}
