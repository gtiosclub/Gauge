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
    
    enum Sports: String {
        case nfl = "NFL"
        case collegeFootball = "College Football"
        case mlb = "MLB"
    }
    
    enum Entertainment: String {
        case movies = "Movies"
        case tvShows = "TV Shows"
    }
    
    enum Educational: String {
        case cs = "Computer Science"
        case math = "Math"
        case environment = "Environment"
        case health = "Health & Fitness"
    }
    
    enum News: String {
        case politics = "Politics"
        case business = "Business"
    }
    
    enum Lifestyle: String {
        case fashion = "Fashion"
        case beauty = "Beauty"
        case travel = "Travel"
    }
    
    enum Arts: String {
        case music = "Music"
        case artwork = "Artwork"
    }
    
    enum Relationships: String {
        case dating = "Dating"
        case relationships = "Relationships"
        case parenting = "Parenting"
    }
    
    enum Other: String {
        case funny = "Funny"
        case jokes = "Jokes"
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
