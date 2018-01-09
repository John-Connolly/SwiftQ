//
//  Queue.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-26.
//

import Foundation
import Async

final class Queue: Async.Stream {
    
    typealias Input = Task
    
    typealias Output = Task
    
    
    func input(_ event: InputEvent<Input>) {
        
    }
    
    func output<S>(to inputStream: S) where S : Async.InputStream, Output == S.Input {
    
    }
    
    func enqueue(_ task: Task) {
        
    }
    
    func enqueue(contentsOf tasks: [Task]) {
        
    }
    
    
}

protocol QueueType {
    associatedtype Item
    func enqueue(_ task: Item)
    func enqueue(contentsOf tasks: [Item])
    func dequeue() -> Item
}
