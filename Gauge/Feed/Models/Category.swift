//
//  Category.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/17/25.
//

enum Category {
    case sports(Sports)
    case entertainment(Entertainment)
    case educational(Educational)
    case news(News)
    case lifestyle(Lifestyle)
    case arts(Arts)
    case relationships(Relationships)
    case other(Other)
    
    enum Sports: String, CaseIterable {
        case nfl = "NFL"
        case collegeFootball = "College Football"
        case mlb = "MLB"
    }
    
    enum Entertainment: String, CaseIterable {
        case movies = "Movies"
        case tvShows = "TV Shows"
    }
    
    enum Educational: String, CaseIterable {
        case cs = "Computer Science"
        case math = "Math"
        case environment = "Environment"
        case health = "Health & Fitness"
    }
    
    enum News: String, CaseIterable {
        case politics = "Politics"
        case business = "Business"
    }
    
    enum Lifestyle: String, CaseIterable {
        case fashion = "Fashion"
        case beauty = "Beauty"
        case travel = "Travel"
    }
    
    enum Arts: String, CaseIterable {
        case music = "Music"
        case artwork = "Artwork"
    }
    
    enum Relationships: String, CaseIterable {
        case dating = "Dating"
        case relationships = "Relationships"
        case parenting = "Parenting"
    }
    
    enum Other: String, CaseIterable {
        case funny = "Funny"
        case jokes = "Jokes"
    }
    
    static var allCases: [Category] {
        return Sports.allCases.map(Category.sports) +
               Entertainment.allCases.map(Category.entertainment) +
               Educational.allCases.map(Category.educational) +
               News.allCases.map(Category.news) +
               Lifestyle.allCases.map(Category.lifestyle) +
               Arts.allCases.map(Category.arts) +
               Relationships.allCases.map(Category.relationships) +
               Other.allCases.map(Category.other)
    }

    static var allCategoryStrings: [String] {
        return allCases.map { $0.rawValue }
    }
    
    var rawValue: String {
        switch self {
        default:
            if case let .sports(val) = self { return val.rawValue }
            if case let .entertainment(val) = self { return val.rawValue }
            if case let .educational(val) = self { return val.rawValue }
            if case let .news(val) = self { return val.rawValue }
            if case let .lifestyle(val) = self { return val.rawValue }
            if case let .arts(val) = self { return val.rawValue }
            if case let .relationships(val) = self { return val.rawValue }
            if case let .other(val) = self { return val.rawValue }
            return ""
        }
    }
}
