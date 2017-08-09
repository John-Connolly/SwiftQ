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
    let value: Data
    
}

extension EnqueueingBox {
    
    init(_ chain: Chain) throws {
        self.uuid = chain.uuid
        self.queue = "default"
        self.value = try chain.serialized()
    }
    
    init(_ task: Task) throws {
        self.uuid = task.uuid
        self.queue = task.queue
        self.value = try task.serialized()
    }
    
}
