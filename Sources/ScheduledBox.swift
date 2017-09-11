//
//  ScheduledTask.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-07-06.
//
//

import Foundation

struct ScheduledBox:  ZSettable {
    
    let score: String
    
    let uuid: String
    
    let task: Data
    
    
    init(_ task: Task, when time: Time) throws {
        let time = Date().unixTime + time.unixTime
        let data = try task.serialized()
        self.uuid = task.id.uuid
        self.score = time.description
        self.task = data
    }
    

}

protocol Boxable {
    
    var task: Data { get }
    
}
