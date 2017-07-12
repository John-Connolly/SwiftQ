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
    
}
