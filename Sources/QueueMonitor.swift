//
//  QueueMonitor.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-07-04.
//
//

import Foundation

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
        timer.scheduleRepeating(deadline: .now(), interval: .milliseconds(interval), leeway: .seconds(1))
        
        timer.setEventHandler { [weak self] in
            self?.pollQueues()
        }
        
        timer.resume()
    }
    
    
    private func pollQueues() {
        queues.forEach { queue in
            queue.poll()
        }
    }
    
}


protocol Monitorable: class {
    
    func poll()
    
}
