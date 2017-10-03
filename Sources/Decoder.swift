//
//  Decoder.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-06-22.
//
//

import Foundation

struct Decoder {
    
    let types:  [Task.Type]
    
    private let zippedTasks: [(String , Task.Type)]
    
    
    init(types: [Task.Type]) {
        self.types = types
        let taskNames = types.map(String.init(describing:))
        self.zippedTasks = zip(taskNames, types).array
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
        let taskType = zippedTasks.filter { keyValue in
            return keyValue.0 == name
            }.first?.1
        
        return try taskType.map { type in
            return try type.init(data: task)
            }.or(throw: SwiftQError.taskNotFound)
    }
    
    
    func decode(chain json: [String : Any]) throws -> Chain {
        throw SwiftQError.unimplemented
    }
    
}



enum DecoderResult {
    case chain(Chain)
    case task(Task)
}
