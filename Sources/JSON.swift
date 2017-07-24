//
//  JSON.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-07-09.
//
//

import Foundation

public struct JSON {
    
    let json: [String : Any]
    
    public init(_ json: [String : Any]) {
        self.json = json
    }
    
    public init() {
        self.json = [ : ]
    }
    
    public func get<T>(key: String) throws -> T {
        guard let args = json["args"] as? [String : Any] else {
            throw SwiftQError.initializationFailure(json)
        }
        
        guard let value = args[key] as? T else {
            throw SwiftQError.initializationFailure(json)
        }
        
        return value
    }
    
    /// Used only for Identification
    func unsafeGet<T>(_ key: String) throws -> T {
        guard let value = json[key] as? T else {
            throw SwiftQError.initializationFailure(json)
        }
        return value
    }
    
    
    /// https://bugs.swift.org/browse/SR-4599?jql=text%20~%20%22JSONSerialization%22
    /// JSONSerialization behaves differently on linux
    func getInt(_ key: String) throws -> Int {
        guard let value = json[key] else {
            throw SwiftQError.initializationFailure(json)
        }
        
        switch value {
        case let value as Int:
            return value
        case let value as Int8:
            return Int(value)
        case let value as Int16:
            return Int(value)
        case let value as Int32:
            return Int(value)
        case let value as Int64:
            return Int(value)
        case let value as UInt:
            return Int(value)
        case let value as UInt8:
            return Int(value)
        case let value as UInt16:
            return Int(value)
        case let value as UInt32:
            return Int(value)
        case let value as UInt64:
            return Int(value)
        default:
            throw SwiftQError.initializationFailure(json)
        }
    }
    
}
