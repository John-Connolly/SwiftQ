//
//  Middleware.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-08-08.
//
//

import Foundation

/// There is no guarantee about which thread the middleware
/// function will be called from
public protocol Middleware {
    
    func before(task: Task)
    
    func after(task: Task)
    
    func after(task: Task, with error: Error)
    
}

final class MiddlewareCollection {
    
    private let middleware: [Middleware]
    
    init(_ middleware: [Middleware]) {
        self.middleware = middleware
    }
    
    func before(task: Task) {
        self.middleware.forEach { middleware in
            middleware.before(task: task)
        }
    }
    
    func after(task: Task) {
        self.middleware.forEach { middleware in
            middleware.after(task: task)
        }
    }
    
    func after(task: Task, with error: Error) {
        self.middleware.forEach { middleware in
            middleware.after(task: task, with: error)
        }
    }
    
}
