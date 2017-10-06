//
//  EnqueueingBox.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-08-09.
//
//

import Foundation

struct EnqueueingBox {
    
    let uuid: String
    
    let queue: String
    
    let task: Data
    
}

extension EnqueueingBox {
    
   
    init(_ task: Task) throws {
        self.uuid = task.uuid
        self.queue = task.queue
        self.task = try task.data()
    }
    
}
