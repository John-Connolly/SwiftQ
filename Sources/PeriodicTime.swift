//
//  PeriodicTime.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-07-12.
//
//

import Foundation

public enum PeriodicTime {
    
    case secondly(Int64)
    case minutely(Int64)
    case daily(minute: Int64, hour: Int64)
    case weekly(minute: Int64, hour: Int64, day: Day)
    
    
    var unixTime: Int64 {
        switch self {
        case .secondly(let seconds):
            return seconds
        case .minutely(let minutes):
            return (minutes * 60)
        case .daily(let minute, let hour):
            return (minute * 60) + (hour * 3600)
        case .weekly(let minute, let hour, let day):
            return (minute * 60) + (hour * 3600) + (day.rawValue * 86_400)
        }
    }
    
    
    var nextTime: Int64 {
        switch self {
        case .secondly(let seconds):
            return seconds
        case .minutely(let minutes):
            return (minutes * 60)
        case .daily(_,_):
            let isPast = self.isPast(time: startOfDay().unixTime + unixTime)
            let dateToAdd = isPast ? tomorrow() : startOfDay()
            return dateToAdd.unixTime + unixTime
        case .weekly(let minute, let hour, let day):
            if day.rawValue == today() {
                let time = startOfDay().unixTime + (minute * 60) + (hour * 3600)
                let isPast = self.isPast(time: time)
                if !isPast {
                    return time
                }
            }
            let nextDay = next(day).unixTime + (minute * 60) + (hour * 3600)
            return  nextDay
        }
    }
    
    
    func startOfDay() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        let components = calendar.dateComponents(unitFlags, from: Date())
        return calendar.date(from: components)!
    }
    
    
    func isPast(time: Int64) -> Bool {
        return Date().unixTime >= time
    }
    
    
    func tomorrow() -> Date {
        return startOfDay().addingTimeInterval(TimeInterval(86_400))
    }
    
    
    func today() -> Int64 {
        let components = Calendar(identifier: .gregorian).dateComponents([.weekday], from: Date())
        return Int64(components.weekday!)
    }
    
    
    func next(_ day: Day) -> Date {
        let components = Calendar(identifier: .gregorian).dateComponents([.weekday], from: Date())
        let currentWeekday = components.weekday!
        
        let delta = day.rawValue - Int64(currentWeekday)
        let adjustedDelta = delta <= 0 ? delta + 7 : delta
        
        return addDays(adjustedDelta)
    }
    
    
    func addDays(_ days: Int64) -> Date {
        return startOfDay().addingTimeInterval(TimeInterval(days * 86_400))
    }
    
    
}

public enum Day: Int64 {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}
