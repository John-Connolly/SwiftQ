//
//  Persistable.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-11.
//  Copyright © 2017 John Connolly. All rights reserved.
//

import Foundation

public protocol Persistable: class {
    
    var id: Storage { get }
    
    func json() throws -> JSON
    
    init(json: JSON) throws
    
    var taskType: TaskType { get }
    
}

extension Persistable {
    
    var name: String {
        return String(describing: self)
            .components(separatedBy: ".")
            .last ?? String(describing: self)
    }
    
    func serialized() throws -> Data {
        return try fullJSON().data()
    }
    
    // TODO: - Rename
    func fullJSON() throws -> [String : Any] {
        var json = self.id.json().json
        json[.args] = try self.json().json
        json[.taskName] = self.name
        json["taskType"] = self.taskType.rawValue
        return json
    }
    
    public var taskType: TaskType {
        return .task
    }
    
}
