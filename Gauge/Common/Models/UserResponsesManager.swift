//
//  UserResponsesManager.swift
//  Gauge
//
//  Created by Shreeya Garg on 4/13/25.
//
import SwiftData
import Foundation

class UserResponsesManager {

    // Increase category value to user responses (for positive interactions)
    static func addCategoriesToUserResponses(modelContext: ModelContext, categories: [String]) {
        let descriptor = FetchDescriptor<UserResponses>()
        
        do {
            if let userResponse = try modelContext.fetch(descriptor).first {
                userResponse.addToUserCategories(categories: categories)
                try modelContext.save()
                print("✅ Added categories to UserResponses: \(categories)")
            } else {
                let newResponse = UserResponses()
                newResponse.addToUserCategories(categories: categories)
                modelContext.insert(newResponse)
                try modelContext.save()
                print("✅ Created new UserResponses with categories: \(categories)")
            }
        } catch {
            print("❌ Error updating UserResponses: \(error)")
        }
    }
    
    // Decrease category value from user responses (for negative interactions)
    static func removeCategoriesFromUserResponses(modelContext: ModelContext, categories: [String]) {
        let descriptor = FetchDescriptor<UserResponses>()
        
        do {
            if let userResponse = try modelContext.fetch(descriptor).first {
                userResponse.removeFromUserCategories(categories: categories)
                try modelContext.save()
                print("✅ Removed categories from UserResponses: \(categories)")
            } else {
                let newResponse = UserResponses()
                newResponse.removeFromUserCategories(categories: categories)
                modelContext.insert(newResponse)
                try modelContext.save()
                print("✅ Created new UserResponses with negative categories: \(categories)")
            }
        } catch {
            print("❌ Error updating UserResponses: \(error)")
        }
    }
    
    // Get the current user responses (useful for other operations)
    static func getCurrentUserResponses(modelContext: ModelContext) -> UserResponses? {
        let descriptor = FetchDescriptor<UserResponses>()
        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            print("❌ Error fetching UserResponses: \(error)")
            return nil
        }
    }
}
