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
    
    private var zippedTasks: [(String , Task.Type)] {
        let taskNames = types.map(String.init(describing:))
        return zip(taskNames, types).array
    }
    

    /// Returns the correct task type based on the zipped tasks
    func decode(data: Foundation.Data) throws -> DecoderResult {
        let json = try data.jsonDictionary(key: String.self, value: Any.self)
        
        let taskType = TaskType(json["taskType"] as? String ?? "")
        
        switch taskType {
        case .chain:
            return DecoderResult.chain(try decode(chain: json))
        default:
            return DecoderResult.task(try decode(task: json))
        }
    }
    
    
    func decode(task: [String : Any]) throws -> Task {
        let taskName = (task[.taskName] as? String) ?? ""
        
        guard let taskType = zippedTasks.filter({ $0.0 == taskName }).first?.1 else {
            throw SwiftQError.taskNotFound
        }
        
        return try taskType.init(json: JSON(task))
    }
    
    
    func decode(chain json: [String : Any]) throws -> Chain {
        guard let chain = json["chain"] as? [[String : Any]] else {
            throw SwiftQError.taskNotFound
        }
        
        let tasks = try chain.map { task -> Task in
            let name = task[.taskName] as? String ?? ""
            guard let taskType = zippedTasks.filter({ $0.0 == name }).first?.1 else {
                throw SwiftQError.taskNotFound
            }
            return try taskType.init(json: JSON(task))
        }
        
        return try Chain(tasks)
    }
    
}

enum DecoderResult {
    case chain(Chain)
    case task(Task)
}
