//
//  Scheduler.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-27.
//

import Foundation

/// Schedules a unit of work to take place in the future, often these are repeating.
final class Scheduler {
    
    private let eventLoop: DispatchQueue
    private let processes: [Process]
    private var timers: [DispatchSourceTimer]
    private let container: Container
    
    init(services: [Process.Type], container: Container) throws {
        self.eventLoop = DispatchQueue(label: "com.swiftq.service.dispatcher.main")
        self.processes = try services.map { try $0.init() }
        self.container = container
        self.timers = []
    }
    
    func start() {
        
        timers = processes.map { process -> DispatchSourceTimer in
            
            let source = DispatchSource.makeTimerSource(queue: eventLoop)
            source.schedule(deadline: .now(), repeating: process.repeating, leeway: .seconds(1))
            
            source.setEventHandler {
                
                process.event(container: self.container)
                
            }
            
            source.resume()
            
            return source
        }
        
    }
    
}

struct MonitorService: Process {
    
    let repeating = DispatchTimeInterval.seconds(1)
    
    func event(container: Container) {
        print("working")
    }
    
}
