//
//  DateConverter.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/20/25.
//
import Foundation

class DateConverter {
    static func convertStringToDate(_ stringDate: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: stringDate)
    }
    
    static func convertDateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    static func timeAgo(from date: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: date, to: Date()) ?? "Just now"
    }
    
    static func calcDateScore(postDate: Date) -> Int {
        
        let diffInDays = Calendar.current.dateComponents([.day], from: postDate, to: Date()).day ?? 31
        let diffInHours = Calendar.current.dateComponents([.hour], from: postDate, to: Date()).hour ?? 31
//        let decayFactor = 0.2
        if(diffInDays > 30) {
            return 0
        }
        if(diffInDays == 30) {
            return 1
        }
//        print(diffInHours)
        if (diffInHours < 24) {
            let diffInMins = Calendar.current.dateComponents([.minute], from: postDate, to: Date()).minute ?? 60
            //let diffInHours = Calendar.current.dateComponents([.hour], from: postDate, to: Date()).day ?? 24
//            print(diffInMins)
            if(diffInMins < 5) {
                return 30;
            }
            // decay between 0 - 24 hours  (value minutes more ):

            let score = 20 + (10 * exp(-0.009 * (Double(diffInMins)/10)))
            return  Int(floor(score))
        }
        
        if(diffInDays < 7) {
            let score = 10 + (10 * exp(-0.2 * Double(diffInDays)))
            return  Int(floor(score))
        }
        let score = 1 + (9 * exp(-0.07 * (Double(diffInDays)-7)))
        return Int(floor(score))
    }

}
