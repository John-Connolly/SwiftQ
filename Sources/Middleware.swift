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
