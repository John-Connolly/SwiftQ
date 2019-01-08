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
    
    private let resources: [InitResource] // TODO: make a dictionary!
    
    init(types: [Task.Type]) {
        self.types = types
        self.resources = types.map(InitResource.init)
    }

    func taskName(from dict: [String: Any]) throws -> String {
        return try (dict["name"] as? String).or(throw: SwiftQError.taskNotFound)
    }

    func decode(data: Foundation.Data) throws -> Task {
        let json = try data.jsonDictionary(key: String.self, value: Any.self)
        let name = try taskName(from: json)
        return decode(task: data, with: name)
    }

    private func decode(task: Data, with name: String) -> Task {
        let taskType = (resources
            .first(where: { $0.name == name })?
            .type)!

        return try! taskType.create(from: task)
    }
    

    
}
