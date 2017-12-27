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
    
    public typealias Output = Data
    
    private let eventLoop: EventLoop
    // TODO: Might have to have pool of blocked clients.
    private let client: RedisAdaptor
    
    private var downstream: AnyInputStream<Output>?
    
    /// The amount of requested output remaining
    private var requestedOutputRemaining: UInt = 0
    
    public init(with configuration: Configuration, on eventLoop: EventLoop) throws {
        self.eventLoop = eventLoop
        self.client = try RedisAdaptor(with: configuration.redisConfig, connections: 1, on: eventLoop)
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
    
    // TODO: Have real errors.
    private func accept() {
        eventLoop.async {
            
            let task = self.client
                .execute(command: .brpoplpush(q1: "myList", q2: "newList", timeout: 0))
                .flatMap(to: RedisResponse.self) { response  in
                    return try response.string
                        .flatMap { resp in
                            self.client.execute(command: .get(key: resp))
                        }
                        .or(throw: SwiftQError.unimplemented)
            }
            
            task.do { response in
                
                guard let data = response.data else {
                    self.downstream?.error(SwiftQError.unimplemented)
                    return
                }
                
                self.downstream?.next(data)
                
                }.catch { error in
                    self.downstream?.error(error)
            }
            
        }
    }
    
}
