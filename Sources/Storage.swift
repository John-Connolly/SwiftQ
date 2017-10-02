//
//  Identification.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-06-22.
//
//

import Foundation

public final class Storage {
    
    let uuid: String
    
    private var createdAt: Int?
    
    private var retryCount = 0
    
    public init() {
        self.uuid = UUID().uuidString
    }
    
    public init(_ json: JSON) throws {
        self.uuid = try json.unsafeGet(JSONKey.uuid.rawValue)
        self.createdAt = try json.getInt(JSONKey.createdAt.rawValue)
        self.retryCount = try json.getInt(JSONKey.retryCount.rawValue)
    }
    
    func json() -> JSON {
        var json = [String : Any]()
        json[.uuid] = uuid
        json[.createdAt] = createdAt ?? Date().unixTime
        json[.retryCount] = retryCount
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
