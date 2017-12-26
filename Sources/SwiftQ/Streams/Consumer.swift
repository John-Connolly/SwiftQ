////
////  Consumer.swift
////  SwiftQ
////
////  Created by John Connolly on 2017-12-02.
////
//
import Foundation
import Async
import Redis
//import SwiftRedis
//
//public final class Consumer: Async.OutputStream  {
//    
//    public typealias Output = Data
//    
//    private var outputStream: BasicStream<Output> = .init()
//    
//    let decoder: DecoderStream
//    
//
//    public init(types: [Task.Type]) {
//        self.decoder = DecoderStream(types)
//    }
//    
//    let eventLoops = (1...4).map { num -> BlockingStream in
//        let eventLoop = DispatchQueue(label: "worker.eventloop.\(num)",qos: .userInitiated)
//        return BlockingStream(on: eventLoop)
//    }
//
//    
//    public func run() {
//
//        for eventLoop in eventLoops {
//            eventLoop.run()
//        }
//        
//        let group = DispatchGroup()
//        group.enter()
//        group.wait()
//        
//        //        RunLoop.main.run()
//        //        self.stream(to: decoder).drain { task in
//        ////            print(task)
//        //
//        //            }.catch { error in
//        //              print(error)
//        //        }




//final class BlockingStream: Async.OutputStream {
//    
//    
//    /// See OutputStream.Output
//    typealias Output = RedisData
//    
//    var outputStream: BasicStream<Output> = .init()
//    
//    
//    let eventLoop: EventLoop
//    let pool: BlockedClientPool
//    let semaphore = DispatchSemaphore(value: 50)
//    
//    
//    init(on eventLoop: EventLoop) {
//        self.eventLoop = eventLoop
//        self.pool = BlockedClientPool(on: eventLoop, clients: 50)
//    }
//    
//    
//    func run() {
//        
//        repeat {
//            self.semaphore.wait()
//            
//            let data = self.pool.retain { client -> Future<RedisData> in
//                return client.run(command: "BRPOPLPUSH", arguments: ["myList","newList","0"])
//                
//            }
//            
//            data.always {
//                self.semaphore.signal()
//            }
//        } while true
//    }
//    
//
//
//public func onError(_ error: Error) {
//    outputStream.onError(error)
//}
//
//
//public func onOutput<I>(_ input: I) where I: Async.InputStream, Output == I.Input {
//    outputStream.onOutput(input)
//}
//
//
//func close() {
//    outputStream.close()
//}
//
//
//func onClose(_ onClose: ClosableStream) {
//    outputStream.onClose(onClose)
//}
//
//}
//
//
//

//final class CompletionStream {
//final class WorkStream: Async.Stream  {
//final class ErrorStream {

import Async
final class Consumer {
    
    
    let eventLoops = (1...4).map { num -> DispatchEventLoop in
        let eventLoop =  DispatchEventLoop(label: "swiftQ.eventloop.\(num)")
        return eventLoop
    }
    
    init() { }
    
    
    
}


public final class DataStream: Async.OutputStream, Async.ConnectionContext {
    
    public typealias Output = RedisData
    
    let eventLoop: EventLoop
    let client: RedisClient
    let decoder: DecoderStream
    
    
    private var downstream: AnyInputStream<Output>?
    
    /// The amount of requested output remaining
    private var requestedOutputRemaining: UInt = 0
    
    public init(on eventLoop: EventLoop) {
        self.eventLoop = eventLoop
        self.client = try! RedisClient.connect(on: eventLoop)
        self.decoder = DecoderStream()
        let _ = self.stream(to: decoder)
    }
    
    func accept() {
        eventLoop.async {
            
            self.client.run(command: "BRPOPLPUSH", arguments: ["myList","newList","0"]).do { data in
                self.downstream?.next(data)
                }.catch { _ in }
            
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
    
    func cancel() { }
    
    public func output<S>(to inputStream: S) where S: Async.InputStream, S.Input == Output {
        downstream = AnyInputStream(inputStream)
        inputStream.connect(to: self)
    }
    
    
}

final class DecoderStream: Async.Stream, Async.ConnectionContext {
    
    typealias Input = RedisData
    
    typealias Output = Task
    
    /// The upstream providing byte buffers
    var upstream: ConnectionContext?
    
    /// Use a basic output stream to implement server output stream.
    var downstream: AnyInputStream<Output>?
    
    /// Remaining downstream demand
    var downstreamDemand: UInt = 0
    
    var input: RedisData? {
        didSet {
            
        }
    }
    
    
    func input(_ event: InputEvent<RedisData>) {
        switch event {
        case .close:
            downstream?.close()
        case .connect(let upstream):
            self.upstream = upstream
        case .error(let error):
            downstream?.error(error)
        case .next(let next):
            print(next)
            //              self.downstream?.error(error)
        }
    }
    
    func connection(_ event: ConnectionEvent) {
        switch event {
        case .cancel:
            self.downstreamDemand = 0
        case .request(let demand):
            self.downstreamDemand += demand
        }
        
        guard downstreamDemand > 0, input != nil else {
            upstream?.request()
            return
        }
        
        //        do {
        //            try transform()
        //        } catch {
        //            self.downstream?.error(error)
        //        }
    }
    
    func output<S>(to inputStream: S) where S : Async.InputStream, Output == S.Input {
        self.downstream = AnyInputStream(inputStream)
        inputStream.connect(to: self)
    }
    
}



