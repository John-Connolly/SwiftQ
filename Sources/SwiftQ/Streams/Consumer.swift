//
//  Consumer.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-02.
//

import Foundation
import Async
import Redis
import SwiftRedis

public final class Consumer: Async.OutputStream  {
    
    public typealias Output = Data
    
    private var outputStream: BasicStream<Output> = .init()
    
    let decoder: DecoderStream
    

    public init(types: [Task.Type]) {
        self.decoder = DecoderStream(types)
    }
    
    let eventLoops = (1...4).map { num -> BlockingStream in
        let eventLoop = DispatchQueue(label: "worker.eventloop.\(num)",qos: .userInitiated)
        return BlockingStream(on: eventLoop)
    }

    
    public func run() {

        for eventLoop in eventLoops {
            eventLoop.run()
        }
        
        let group = DispatchGroup()
        group.enter()
        group.wait()
        
        //        RunLoop.main.run()
        //        self.stream(to: decoder).drain { task in
        ////            print(task)
        //
        //            }.catch { error in
        //              print(error)
        //        }
        
        
        
    }
    
    
    public func onOutput<I>(_ input: I) where I: Async.InputStream, Output == I.Input {
        outputStream.onOutput(input)
    }
    
    public func onClose(_ onClose: ClosableStream) {
        outputStream.onClose(onClose)
    }
    
    public func close() {
        outputStream.close()
    }
    
}

final class WorkStream: Async.Stream  {
    
    typealias Input = Task
    
    /// See OutputStream.Output
    typealias Output = Task
    
    var outputStream: BasicStream<Output> = .init()
    
    
    public func onInput(_ input: Task) {
        do {
            try input.execute()
        } catch {
            
        }
    }
    
    public func onError(_ error: Error) {
        outputStream.onError(error)
    }
    
    
    public func onOutput<I>(_ input: I) where I: Async.InputStream, Output == I.Input {
        outputStream.onOutput(input)
    }
    
    
    func close() {
        outputStream.close()
    }
    
    
    func onClose(_ onClose: ClosableStream) {
        outputStream.onClose(onClose)
    }
    
}


final class BlockingStream: Async.OutputStream {
    
    
    /// See OutputStream.Output
    typealias Output = RedisData
    
    var outputStream: BasicStream<Output> = .init()
    
    
    let eventLoop: EventLoop
    let pool: BlockedClientPool
    let semaphore = DispatchSemaphore(value: 50)
    
    
    init(on eventLoop: EventLoop) {
        self.eventLoop = eventLoop
        self.pool = BlockedClientPool(on: eventLoop, clients: 50)
    }
    
    
    func run() {
        
        repeat {
            self.semaphore.wait()
            
            let data = self.pool.retain { client -> Future<RedisData> in
                return client.run(command: "BRPOPLPUSH", arguments: ["myList","newList","0"])
                
            }
            
            data.always {
                self.semaphore.signal()
            }
        } while true
    }
    


public func onError(_ error: Error) {
    outputStream.onError(error)
}


public func onOutput<I>(_ input: I) where I: Async.InputStream, Output == I.Input {
    outputStream.onOutput(input)
}


func close() {
    outputStream.close()
}


func onClose(_ onClose: ClosableStream) {
    outputStream.onClose(onClose)
}

}



final class CompletionStream {
    
}



final class ErrorStream {
    
}

final class WorkerAsync {
    
    let eventLoop: EventLoop
    let pool: BlockedClientPool
    
    init(on eventLoop: EventLoop, pool: BlockedClientPool) {
        self.eventLoop = eventLoop
        self.pool = pool
    }
    
    
}


public struct LoopIterator<Base: Collection>: IteratorProtocol {
    private let collection: Base
    private var index: Base.Index
    
    /// Create a new Loop Iterator from a collection.
    public init(collection: Base) {
        self.collection = collection
        self.index = collection.startIndex
    }
    
    /// Get the next item in the loop iterator.
    public mutating func next() -> Base.Iterator.Element? {
        guard !collection.isEmpty else {
            return nil
        }
        
        let result = collection[index]
        collection.formIndex(after: &index) // (*) See discussion below
        if index == collection.endIndex {
            index = collection.startIndex
        }
        return result
    }
}
