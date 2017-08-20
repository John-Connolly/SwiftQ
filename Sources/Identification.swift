//
//  Identification.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-06-22.
//
//

import Foundation

public final class Identification {
    
    let uuid: String
    
    private var createdAt: Int?
    
    private var attempts = 0
    
    public init() {
        self.uuid = UUID().uuidString
    }
    
    public init(_ json: JSON) throws {
        self.uuid = try json.unsafeGet(JSONKey.uuid.rawValue)
        self.createdAt = try json.getInt(JSONKey.createdAt.rawValue)
    }
    
    func json() -> JSON {
        var json = [String : Any]()
        json[.uuid] = uuid
        json[.createdAt] = createdAt ?? Date().unixTime
        return JSON(json)
    }
    
}

public enum TaskType: String {
    
    case chain
    case task
    case chainable
    case injectable
    case linkable
    case schedulable
    case periodic
    
    
    init(_ type: String) {
        self = TaskType.init(rawValue: type) ?? .task
    }
}
