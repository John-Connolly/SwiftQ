//
//  CompletionStream.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-26.
//

import Foundation
import Async
import Redis

final class CompletionStream: Async.InputStream {
    
    typealias Input = TaskResult
    
    private var upstream: ConnectionContext?
    
    init() { }
    
    func input(_ event: InputEvent<TaskResult>) {
        switch event {
        case .close: break
        case .connect(let upstream):
            self.upstream = upstream
            upstream.request()
        case .error(let error):
            Logger.log("Uncaught Error: \(error)", level: .warning)
        case .next(let result):
            result.onSuccess(onSuccess)
            result.onError(onError)
            upstream?.request()
        }
    }
    
    func onSuccess(task: Task) {
        
    }
    
    func onError(task: Task, with error: Error) {
        
    }
    
}
