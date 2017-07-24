//
//  Identification.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-06-22.
//
//

import Foundation

public final class Identification {
    
    private let uuid: String
    
    private var timestamp: Int?
    
    private var attempts = 0
    
    public init() {
        self.uuid = UUID().uuidString
    }
    
    public init(_ json: JSON) throws {
        self.uuid = try json.unsafeGet("uuid")
        self.timestamp = try json.getInt("timestamp")
    }
    
    func json() -> JSON {
        var json = [String : Any]()
        json["uuid"] = uuid
        json["timestamp"] = timestamp ?? Date().unixTime
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
