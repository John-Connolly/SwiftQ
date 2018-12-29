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
        return decode(task: data, with: taskName)
    }
    
    
    private func decode(task: Data, with name: String) -> Task {
        let taskType = (resources
            .first(where: { $0.name == name })?
            .type)!

        return  taskType.create(from: task)
    }
    

    
}
