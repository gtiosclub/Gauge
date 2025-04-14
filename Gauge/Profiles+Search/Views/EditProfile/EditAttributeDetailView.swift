struct EditAttributeDetailView: View {
    let attributeKey: String
    let attributeTitle: String
    @State var currentValue: String
    @ObservedObject var profileViewModel: ProfileViewModel
    
    // For a mini search in location, you might add extra logic here.
    let predefinedLocations = [
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
    @State private var filteredLocations: [String] = []
    @State private var searchText: String = ""
    
    var body: some View {
        VStack {
            if attributeKey == "location" {
                TextField("Search locations", text: $searchText)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .onChange(of: searchText) { newValue in
                        if newValue.isEmpty {
                            filteredLocations = predefinedLocations
                        } else {
                            filteredLocations = predefinedLocations.filter { $0.localizedCaseInsensitiveContains(newValue) }
                        }
                    }
                    .padding()
                List(filteredLocations, id: \.self) { location in
                    Button(location) {
                        currentValue = location
                        profileViewModel.tempAttributes[attributeKey] = location
                    }
                }
            } else if attributeKey == "gender" {
                ForEach(["Male", "Female", "Other"], id: \.self) { option in
                    Button {
                        currentValue = option
                        profileViewModel.tempAttributes[attributeKey] = option
                    } label: {
                        HStack {
                            Text(option)
                            Spacer()
                            if currentValue == option {
                                Image(systemName: "checkmark")
                            }
                        }
                        .padding()
                    }
                }
            } else {
                TextField("Enter \(attributeTitle)", text: $currentValue)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: currentValue) { newValue in
                        profileViewModel.tempAttributes[attributeKey] = newValue
                    }
            }
            Spacer()
        }
        .navigationTitle(attributeTitle)
        .onAppear {
            if attributeKey == "location" {
                filteredLocations = predefinedLocations
            }
        }
    }
}