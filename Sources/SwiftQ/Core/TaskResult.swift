//
//  TaskResult.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-27.
//

import Foundation

/// Represents the result of running a task in the work stream.
enum TaskResult {
    case success(Task)
    case failure(task: Task, with: Error)
    
    /// Calls handler if the task is successful
    func onSuccess(_ handler: (Task) -> ()) {
        switch self {
        case .success(let task): return handler(task)
        case .failure: return
        }
    }
    
    /// Calls handler if the task is a failure
    func onError(_ errorHandler: (Task, _ with: Error) -> ()) {
        switch self {
        case .success: return
        case .failure(let failure): return errorHandler(failure.task, failure.with)
        }
    }
    
}
