//
//  AsyncWorker.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-10-12.
//

import Foundation
import Dispatch

final class AsyncWorker {
    
    let dispatchQueue: DispatchQueue
    let work: () -> ()
    
    init(queue: DispatchQueue, work: @escaping () -> ()) {
        self.dispatchQueue = queue
        self.work = work
    }
    
    func run() {
        let workItem = DispatchWorkItem(block: work)
        dispatchQueue.async(execute: workItem)
    }
}
