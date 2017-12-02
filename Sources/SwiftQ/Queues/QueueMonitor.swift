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
            self.monitorQueues()
        }
        
        timer.resume()
    }
    
    /// Polls every queue in the queues array at a set interval
    private func monitorQueues() {
        queues.forEach { queue in
            queue.monitor()
        }
    }
    
}


protocol Monitorable: class {
    
    func monitor()
    
}


final class ServiceDispatcher {
    
    private let eventLoop: DispatchQueue
    private let services: [Service]
    private var timers: [DispatchSourceTimer]
    
    init(services: [Service.Type]) {
        self.eventLoop = DispatchQueue(label: "com.swiftq.service.dispatcher.main")
        self.services = services.map { $0.init() }
        self.timers = []
    }
    
    func start() {
        
        timers = services.map { service -> DispatchSourceTimer in
            
            let source = DispatchSource.makeTimerSource(queue: eventLoop)
            source.schedule(deadline: .now(), repeating: service.repeating, leeway: .seconds(1))
            
            source.setEventHandler {
                
                service.event()
                
            }
            
            source.resume()

            return source
        }
        
    }
    
}


protocol Service: EmptyInitializable {
    
    var repeating: DispatchTimeInterval { get }
    
    func event() // Could call this handler?
    
}

struct MonitorService: Service {
    
    let repeating = DispatchTimeInterval.seconds(1)
    
    func event() {
        print("working")
    }
    
}


struct HeartBeatService: Service {
    
    let repeating = DispatchTimeInterval.never
    
    func event() {
        print("heart beat")
    }
    
}


protocol EmptyInitializable {
    
    init()
    
}








