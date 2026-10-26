//
//  Formatting.swift
//  UNICOM
//
//  Created by Mac-LAB on 10/27/26.
//
import Foundation

extension Date {
    // Parses Postgres timestamps like 2026-10-27T05:00:00.123456+00:00
    static func fromSupabase(_ s: String) -> Date? {
        let withFraction = ISO8601DateFormatter()
        withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = withFraction.date(from: s) { return d }

        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        if let d = plain.date(from: s) { return d }

        // Trim microseconds down to milliseconds and retry
        if let dot = s.firstIndex(of: "."),
           let tz = s[dot...].firstIndex(where: { $0 == "+" || $0 == "-" || $0 == "Z" }) {
            let fraction = s[s.index(after: dot)..<tz].prefix(3)
            let trimmed = String(s[..<dot]) + "." + fraction + String(s[tz...])
            return withFraction.date(from: trimmed)
        }
        return nil
    }

    // "Just now", "5m", "3h", "2d", "Oct 15"
    var shortAgo: String {
        let seconds = Int(Date().timeIntervalSince(self))
        if seconds < 60 { return "Just now" }
        if seconds < 3600 { return "\(seconds / 60)m" }
        if seconds < 86400 { return "\(seconds / 3600)h" }
        if seconds < 604800 { return "\(seconds / 86400)d" }
        return formatted(.dateTime.month(.abbreviated).day())
    }

    // "9:24 AM", "Yesterday", "Mon", "Oct 15"
    var chatLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) { return formatted(date: .omitted, time: .shortened) }
        if calendar.isDateInYesterday(self) { return "Yesterday" }
        if let days = calendar.dateComponents([.day], from: self, to: Date()).day, days < 7 {
            return formatted(.dateTime.weekday(.abbreviated))
        }
        return formatted(.dateTime.month(.abbreviated).day())
    }
}

