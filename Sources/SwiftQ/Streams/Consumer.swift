////
////  Consumer.swift
////  SwiftQ
////
////  Created by John Connolly on 2017-12-02.
////
//
import Foundation
import Async

final class Consumer {
    
    private let dataStream: DataStream
    private let decoder: DecoderStream
    private let workStream: WorkStream
    private let completionStream: CompletionStream
    
    /// Have a App class that creates one consumer per OS thread.  Each consumer has an event loop
    /// this prevents the need for locking.
    init(_ configuration: Configuration, on eventLoop: EventLoop) throws {
        self.dataStream = try DataStream(with: configuration, on: eventLoop)
        self.decoder = DecoderStream(configuration.tasks)
        self.workStream = WorkStream()
        self.completionStream = CompletionStream()
        
       dataStream
        .stream(to: decoder)
        .stream(to: workStream)
        .output(to: completionStream)
    }
    
}
