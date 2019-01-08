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
    private let resources: [String : Task.Type]
    
    init(types: [Task.Type]) {
        self.types = types
        let keyValues = types.map { (String(describing: $0), $0) }
        self.resources = Dictionary(uniqueKeysWithValues: keyValues)
    }

    func taskName(from dict: [String: Any]) throws -> String {
        return try (dict["name"] as? String).or(throw: SwiftQError.taskNotFound)
    }

    func decode(data: Foundation.Data) throws -> Task {
        let json = try data.jsonDictionary(key: String.self, value: Any.self)
        let name = try taskName(from: json)
        return try decode(task: data, with: name)
    }

    private func decode(task: Data, with name: String) throws -> Task {
        let taskType = try resources[name].or(throw: SwiftQError.taskNotFound)
        return try taskType.create(from: task)
    }

}
