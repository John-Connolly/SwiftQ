//
//  PeriodicBox.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-08-08.
//
//

import Foundation

struct PeriodicBox: ZSettable {
    
    let score: String
    
    let uuid: String
    
    let task: Data
    
    init(_ periodicTask: PeriodicTask) throws {
        let data = try periodicTask.data()
        self.uuid = periodicTask.storage.uuid
        self.score = periodicTask.frequency.nextTime.description
        self.task = data
    }
    
}

protocol ZSettable: Boxable {
    
    var uuid: String { get }
    
    var score: String { get }
}
