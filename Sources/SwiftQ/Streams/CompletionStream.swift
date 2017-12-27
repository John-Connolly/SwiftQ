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
 
    typealias Input = Task
    
    private var upstream: ConnectionContext?
    
    init() { }
    
    func input(_ event: InputEvent<Task>) {
        switch event {
        case .close: break
        case .connect(let upstream):
            self.upstream = upstream
            upstream.request()
        case .error(let error):
            print("Uncaught Error: \(error)")
        case .next(_):
            upstream?.request()
        }
    }
    
    
}
