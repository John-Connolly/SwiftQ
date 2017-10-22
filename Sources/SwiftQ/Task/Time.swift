//
//  Time.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-08.
//  Copyright © 2017 John Connolly. All rights reserved.
//

import Foundation

public enum Time {
    
    case seconds(Int)
    case minutes(Int)
    case days(Int)
    case weeks(Int)
    
    var unixTime: Int {
        switch self {
        case .seconds(let seconds):
            return seconds
        case .minutes(let minutes):
            return (minutes * 60)
        case .days(let days):
            return (days * 86_400)
        case .weeks(let weeks):
            return (weeks * 604_800) 
        }
    }
    
}
