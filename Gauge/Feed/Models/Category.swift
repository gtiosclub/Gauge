//
//  Category.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/17/25.
//

enum Category: Hashable {
    case sports(Sports)
    case entertainment(Entertainment)
    case educational(Educational)
    case news(News)
    case lifestyle(Lifestyle)
    case arts(Arts)
    case relationships(Relationships)
    case other(Other)
    
    enum Sports: String, CaseIterable {
        case nfl = "🏈 NFL"
        case collegeFootball = "🏈 College Football"
        case mlb = "⚾ MLB"
        case collegeBaseball = "⚾ College Baseball"
        case tennis = "🎾 Tennis"
        case nba = "🏀 NBA"
        case collegeBasketball = "🏀 College Basketball"
        case mma = "🥋 MMA"
        case golf = "⛳ Golf"
        case cricket = "🏏 Cricket"
        case iceHockey = "🏒 Ice Hockey"
        case rugby = "🏉 Rugby"
        case boxing = "🥊 Boxing"
        case mixedMartialArts = "🥋 Mixed Martial Arts"
        case F1 = "🏎️ F1"
        case soccer = "⚽ Soccer"
        case swimming = "🏊 Swimming"
        case olympics = "🏅 Olympics"
        case pickleball = "🏓 Pickleball"
    }

    enum Entertainment: String, CaseIterable {
        case movies = "🎬 Movies"
        case tvShows = "📺 TV Shows"
        case movieReccomendations = "🎥 Movie Recommendations"
        case showReccomendations = "📺 Show Recommendations"
        case videoGames = "🎮 Video Games"
        case music = "🎵 Music"
        case books = "📚 Books"
        case podcasts = "🎙️ Podcasts"
        case socialMedia = "📱 Social Media"
        case webSeries = "🌐 Web Series"
        case webComics = "🖼️ Web Comics"
        case anime = "🌀 Anime"
        case videoClips = "📹 Video Clips"
        case shortFilms = "🎞️ Short Films"
        case documentaries = "🎥 Documentaries"
        case realityTV = "📺 Reality TV"
    }

    enum Educational: String, CaseIterable {
        case cs = "💻 Computer Science"
        case ai = "🤖 Artificial Intelligence"
        case math = "🔢 Math"
        case environment = "🌍 Environment"
        case health = "🏋️ Health & Fitness"
        case history = "📜 History"
        case economics = "💰 Economics"
        case chemistry = "🧪 Chemistry"
        case physics = "⚛️ Physics"
        case biology = "🧬 Biology"
        case psychology = "🧠 Psychology"
        case literature = "📖 Literature"
        case philosophy = "🤔 Philosophy"
        case foreignLanguage = "🌎 Foreign Language"
        case testPreparation = "📝 Test Preparation"
        case studyStrategies = "📚 Study Strategies"
        case engineering = "🏗️ Engineering"
        case art = "🎨 Art"
        case finance = "💵 Finance"
    }

    enum News: String, CaseIterable {
        case politics = "🏛️ Politics"
        case business = "📈 Business"
        case technology = "🖥️ Technology"
        case science = "🔬 Science"
        case worldEvents = "🌎 World Events"
        case entertainment = "🎭 Entertainment"
        case health = "🏥 Health"
        case climate = "🌱 Climate"
        case space = "🚀 Space"
        case sports = "🏆 Sports"
        case crime = "🚔 Crime"
        case education = "🏫 Education"
        case culture = "🎭 Culture"
        case stockMarket = "📉 Stock Market"
        case animals = "🐾 Animals"
        case positiveStories = "😊 Positive Stories"
    }

    enum Lifestyle: String, CaseIterable {
        case fashion = "👗 Fashion"
        case beauty = "💄 Beauty"
        case travel = "✈️ Travel"
        case skincare = "🧴 Skincare"
        case cooking = "🍳 Cooking"
        case fitness = "🏋️ Fitness"
        case mentalHealth = "🧘 Mental Health"
        case finances = "💸 Finances"
        case personalDevelopment = "🚀 Personal Development"
        case homeDecor = "🏡 Home Decor"
        case positivity = "😊 Positivity"
        case wellness = "🌿 Wellness"
        case jewelry = "💍 Jewelry"
        case homeInspiration = "🏠 Home Inspiration"
        case lifeHacks = "🛠️ Life Hacks"
        case workLifeBalance = "⚖️ Work-Life Balance"
        case productivity = "📊 Productivity"
        case minimalism = "🧳 Minimalism"
    }

    enum Arts: String, CaseIterable {
        case music = "🎶 Music"
        case artwork = "🖼️ Artwork"
        case photography = "📷 Photography"
        case writing = "✍️ Writing"
        case design = "🎨 Design"
        case videoGames = "🎮 Video Games"
        case poetry = "📜 Poetry"
        case film = "🎥 Film"
        case painting = "🖌️ Painting"
        case crochet = "🧶 Crochet"
        case drawing = "✏️ Drawing"
        case editing = "🎞️ Editing"
        case dance = "💃 Dance"
    }

    enum Relationships: String, CaseIterable {
        case dating = "❤️ Dating"
        case relationships = "💞 Relationships"
        case parenting = "🍼 Parenting"
        case friendship = "👫 Friendship"
        case breakUp = "💔 Break Up"
        case singleLife = "😎 Single Life"
        case datingAdvice = "💌 Dating Advice"
        case longDistanceRelationships = "📞 Long Distance Relationships"
        case datingTips = "💘 Dating Tips"
        case relationshipGoals = "🎯 Relationship Goals"
        case family = "👨‍👩‍👧‍👦 Family"
        case sibling = "👫 Siblings"
        case newParent = "🍼 New Parent"
        case generalRelationshipAdivce = "🗣️ General Relationship Advice"
        case healthyRelationship = "💚 Healthy Relationship"
        case healthyFriendship = "🤝 Healthy Friendship"
        case communication = "🗨️ Communication"
        case trustIssues = "🤔 Trust Issues"
        case loveLanguages = "💬 Love Languages"
        case emotionalSupport = "🤗 Emotional Support"
    }

    enum Other: String, CaseIterable {
        case funny = "😂 Funny"
        case jokes = "🤣 Jokes"
        case lifeAdvice = "💡 Life Advice"
        case cutePets = "🐶 Cute Pets"
        case rant = "😡 Rant"
        case conspiraryTheories = "🕵️ Conspiracy Theories"
        case rememberWhen = "🔙 Remember When"
        case advice = "📝 Advice"
        case randomThoughts = "💭 Random Thoughts"
        case motivationalQuotes = "🌟 Motivational Quotes"
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
    
    static func mapStringsToCategories(returnedStrings: [String]) -> [Category] {
        var categories: [Category] = []

        for string in returnedStrings {
            if let sportsCategory = Category.Sports(rawValue: string) {
                categories.append(.sports(sportsCategory))
            } else if let entertainmentCategory = Category.Entertainment(rawValue: string) {
                categories.append(.entertainment(entertainmentCategory))
            } else if let educationalCategory = Category.Educational(rawValue: string) {
                categories.append(.educational(educationalCategory))
            } else if let newsCategory = Category.News(rawValue: string) {
                categories.append(.news(newsCategory))
            } else if let lifestyleCategory = Category.Lifestyle(rawValue: string) {
                categories.append(.lifestyle(lifestyleCategory))
            } else if let artsCategory = Category.Arts(rawValue: string) {
                categories.append(.arts(artsCategory))
            } else if let relationshipsCategory = Category.Relationships(rawValue: string) {
                categories.append(.relationships(relationshipsCategory))
            } else if let otherCategory = Category.Other(rawValue: string) {
                categories.append(.other(otherCategory))
            }
        }
        
        return categories
    }
    
    static func stringToCategory(_ string: String) -> Category? {
        var category : Category?
        
        if let sportsCategory = Category.Sports(rawValue: string) {
            category = .sports(sportsCategory)
        } else if let entertainmentCategory = Category.Entertainment(rawValue: string) {
            category = .entertainment(entertainmentCategory)
        } else if let educationalCategory = Category.Educational(rawValue: string) {
            category = .educational(educationalCategory)
        } else if let newsCategory = Category.News(rawValue: string) {
            category = .news(newsCategory)
        } else if let lifestyleCategory = Category.Lifestyle(rawValue: string) {
            category = .lifestyle(lifestyleCategory)
        } else if let artsCategory = Category.Arts(rawValue: string) {
            category = .arts(artsCategory)
        } else if let relationshipsCategory = Category.Relationships(rawValue: string) {
            category = .relationships(relationshipsCategory)
        } else if let otherCategory = Category.Other(rawValue: string) {
            category = .other(otherCategory)
        }
        
        return category
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
