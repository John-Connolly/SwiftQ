//
//  Decoder.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-06-22.
//
//

import Foundation

struct Decoder {
    
    private let types:  [Task.Type]
    
    private let resources: [InitResource]
    
    
    init(types: [Task.Type]) {
        self.types = types
        self.resources = types.map(InitResource.init)
    }
    
    /// Returns the correct task based on the task name in storage
    func decode(data: Foundation.Data) throws -> Task {
        let taskName = try data.jsonDictionary(key: String.self, value: Any.self).taskName()
        return try decode(task: data, with: taskName)
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
