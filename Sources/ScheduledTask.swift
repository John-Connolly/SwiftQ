//
//  ScheduledTask.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-07-06.
//
//

import Foundation

struct ScheduledTask {
    
    let time: String
    
    let task: Data
    
    
    init(_ task: Task, when time: Time) throws {
        let time = Date().unixTime + time.unixTime
        let data = try task.serialized()
        self.time = time.description
        self.task = data
    }
    
    init(_ periodicTask: PeriodicTask, when time: Int64) throws {
        let data = try periodicTask.serialized()
        self.time = time.description
        self.task = data
    }
    
}
