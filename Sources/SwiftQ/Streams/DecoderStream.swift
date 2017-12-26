//
//  DecoderStream.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-02.
//

import Foundation
import Async

final class DecoderStream: Async.Stream, Async.ConnectionContext {
    
    typealias Input = Data
    
    typealias Output = Task
    
    var upstream: ConnectionContext?
    
    var downstream: AnyInputStream<Output>?
    
    /// Remaining downstream demand
    var downstreamDemand: UInt = 0
    
    private let resources: [InitResource]
    
    init(_ types: [Task.Type]) {
        self.resources = types.map(InitResource.init)
    }
    
    func input(_ event: InputEvent<Data>) {
        switch event {
        case .close:
            downstream?.close()
        case .connect(let upstream):
            self.upstream = upstream
        case .error(let error):
            downstream?.error(error)
        case .next(let next):
            
            do {
                let task = try transform(next)
                downstream?.next(task)
            } catch {
                self.downstream?.error(error)
            }
            
        }
    }
    
    func connection(_ event: ConnectionEvent) {
        switch event {
        case .cancel:
            self.downstreamDemand = 0
        case .request(let demand):
            self.downstreamDemand += demand
        }
        
        guard downstreamDemand > 0 else {
            upstream?.request()
            return
        }
        // Not sure what to do here.
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
    
    private func transform(_ input: Foundation.Data) throws -> Task {
        let taskName = try input.jsonDictionary(key: String.self, value: Any.self).taskName()
        return try decode(task: input, with: taskName)
    }
    
    private func decode(task: Data, with name: String) throws -> Task {
        let taskType = resources
            .filter { $0.name == name }
            .first?
            .type
        return try taskType
            .map { try $0.init(data: task) }
            .or(throw:  SwiftQError.taskNotFound)
    }
    
}
