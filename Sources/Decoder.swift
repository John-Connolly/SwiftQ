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
    
    /// Returns the correct task type based on the zipped tasks
    func decode(data: Foundation.Data) throws -> DecoderResult {
        let json = try data.jsonDictionary(key: String.self, value: Any.self)
        let storage = json["storage"] as? [String: Any]
        
        guard let taskName = storage?["name"] as? String else {
            throw SwiftQError.taskNotFound
        }
        
        let task = try decode(task: data, with: taskName)
        
        return DecoderResult.task(task)
    }
    
    
    func decode(task: Data, with name: String) throws -> Task {
        let taskType = resources
            .filter { $0.name == name }
            .first?
            .type
    
        return try taskType
            .map { try $0.init(data: task) }
            .or(throw:  SwiftQError.taskNotFound)
    }
    

}

struct InitResource {
    
    let name: String
    let type: Task.Type
    
    init(_ type: Task.Type) {
        self.name = String(describing: type)
        self.type = type
    }
    
}


enum DecoderResult {
    case task(Task)
}
