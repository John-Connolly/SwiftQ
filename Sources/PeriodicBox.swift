//
//  PeriodicBox.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-08-08.
//
//

import Foundation

struct PeriodicBox: Boxable {
    
    let time: String
    
    let uuid: String
    
    let task: Data
    
    init(_ periodicTask: PeriodicTask) throws {
        let data = try periodicTask.serialized()
        self.uuid = periodicTask.id.uuid
        self.time = periodicTask.frequency.nextTime.description
        self.task = data
    }
    
}
