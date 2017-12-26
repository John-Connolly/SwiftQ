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
    
    init() { }
 
    func input(_ event: InputEvent<Task>) {
        
    }
    
    
}
