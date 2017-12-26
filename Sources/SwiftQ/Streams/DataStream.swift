//
//  DataStream.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-26.
//

import Foundation
import Async
import Redis

public final class DataStream: Async.OutputStream, Async.ConnectionContext {
    
    public typealias Output = RedisData
    
    private let eventLoop: EventLoop
    private let client: RedisClient
    
    private var downstream: AnyInputStream<Output>?
    
    /// The amount of requested output remaining
    private var requestedOutputRemaining: UInt = 0
    
    public init(on eventLoop: EventLoop) {
        self.eventLoop = eventLoop
        self.client = try! RedisClient.connect(on: eventLoop)
    }
    
    private func accept() {
        eventLoop.async {
            
            self.client.run(command: "BRPOPLPUSH", arguments: ["myList","newList","0"]).do { data in
                self.downstream?.next(data)
                
                }.catch { error in
                    self.downstream?.error(error)
            }
            
        }
    }
    
    public func connection(_ event: ConnectionEvent) {
        switch event {
        case.request(let count):
            self.request(count)
        case .cancel:
            self.cancel()
        }
    }
    
    func request(_ count: UInt) {
        accept()
    }
    
    // Nothing really to clean up.
    func cancel() {
        print("Data Stream Connection Canceled.")
        
    }
    
    public func output<S>(to inputStream: S) where S: Async.InputStream, S.Input == Output {
        downstream = AnyInputStream(inputStream)
        inputStream.connect(to: self)
    }
    
    
}
