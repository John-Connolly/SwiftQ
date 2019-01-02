//
//  SwiftQ + Dictionary.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-26.
//
//

import Foundation

extension Dictionary {
    
    func data() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self)
    }
    
}

extension Dictionary where Key: ExpressibleByStringLiteral {
    
    subscript(key: JSONKey) -> Value? {
        get {
            return self[key.rawValue as! Key]
        }
        set {
            self[key.rawValue as! Key] = newValue
        }
    }

    // FIXME
    func taskName() throws -> String {
        let storage = self as? [String: Any]
        return try storage
            .flatMap { $0[.name] as? String }
            .or(throw: SwiftQError.taskNotFound)
    }
    
}
