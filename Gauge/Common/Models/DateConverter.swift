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
}
