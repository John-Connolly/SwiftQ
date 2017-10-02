//
//  Task.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-07.
//  Copyright © 2017 John Connolly. All rights reserved.
//

import Foundation

public protocol Task: Persistable {
    
    func execute() throws 
    
    var recoveryStrategy: RecoveryStrategy { get }
    
    var queue: String { get }
    
}

extension Task {
    
    
    public var recoveryStrategy: RecoveryStrategy {
        return .none
    }
    
    public var queue: String {
        return "default"
    }
    
    var uuid: String {
        return id.uuid
    }

    func createLog(with error: Error, consumer: String) throws -> Data {
        var json = try self.fullJSON()
        json[.error] = error.localizedDescription
        json[.errorAt] = Date().unixTime
        json[.consumer] = consumer
        return try json.data()
    }
    
}

protocol Loggable: class {
    
    func log(with error: Error, consumer: String) throws -> Data

}
