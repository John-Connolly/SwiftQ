//
//  DecoderStream.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-02.
//

import Foundation
import Async


final class DecoderStream: Async.Stream {
    
    typealias Input = Foundation.Data
    
    /// See OutputStream.Output
    typealias Output = Task
    
    var outputStream: BasicStream<Output> = .init()
    
    private let resources: [InitResource]
    
    init(_ types: [Task.Type]) {
        self.resources = types.map(InitResource.init)
    }
    
    public func onInput(_ input: Foundation.Data) {
        do {
            let taskName = try input.jsonDictionary(key: String.self, value: Any.self).taskName()
            let task = try decode(task: input, with: taskName)
            outputStream.onInput(task)
        } catch {
            onError(error)
        }
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
