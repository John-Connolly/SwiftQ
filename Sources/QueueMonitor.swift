//
//  QueueMonitor.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-07-04.
//
//

import Foundation
import Dispatch

final class QueueMonitor {
    
    private let queues: [Monitorable]
    
    private let dispatchQueue = DispatchQueue(label: "com.swiftq.monitor")
    
    private let timer: DispatchSourceTimer
    
    private let interval: Int
    
    
    init(queues: [Monitorable], interval: Int) {
        self.queues = queues
        self.interval = interval
        self.timer = DispatchSource.makeTimerSource(queue: dispatchQueue)
    }
    
    func run() {
        timer.schedule(deadline: .now(), repeating: .milliseconds(interval), leeway: .seconds(1))
        
        timer.setEventHandler {
            self.pollQueues()
        }
        
        timer.resume()
    }
    
    /// Polls every queue in the queues array at a set interval
    private func pollQueues() {
        queues.forEach { queue in
            queue.poll()
        }
    }
    
}


protocol Monitorable: class {
    
    func poll()
    
}
